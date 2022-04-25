import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import "package:unorm_dart/unorm_dart.dart" as unorm;
import 'package:latlong2/latlong.dart' show LatLng;

final termsProvider = Provider((ref) => TermsProvider(ref));

class TermsProvider {
  final Ref _ref;

  TermsProvider(this._ref);

  static const kTableName = 'terms';
  static const kTableFields = [
    'change_id text primary key',
    'preset_name text',
    'terms text',
  ];

  Future updateRecords(List<OsmChange> elements) async {
    final presetProv = _ref.read(presetProvider);
    final database = await _ref.read(databaseProvider).database;
    for (final element in elements) {
      final tags = element.getFullTags();
      final preset = await presetProv.getPresetForTags(tags);
      String? presetName;
      if (preset != Preset.defaultPreset) {
        presetName = preset.id;
      }
      final keywords = <String>{};
      for (final k in tags.entries) {
        if (k.key.contains('name') || k.key == 'operator' || k.key == 'brand') {
          final words = k.value.split(RegExp(r'\W+'));
          keywords.addAll(
              words.map((w) => _normalize(w)).where((w) => w.length >= 3));
        }
      }
      await database.insert(
        kTableName,
        {
          'change_id': element.databaseId,
          'preset_name': presetName,
          'terms': keywords.map((e) => '>' + e).join(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  String _normalize(String s) {
    var combining = RegExp(r"[\u0300-\u036F]");
    return unorm.nfkd(s.toLowerCase().trim()).replaceAll(combining, '');
  }

  Future<List<OsmChange>> findChanges(String query, LatLng location,
      {Locale? locale,
      int maxResults = 12,
      double maxDistance = 1000.0}) async {
    final presets = await _ref.read(presetProvider).getPresetsAutocomplete(
          query,
          locale: locale,
          location: location,
          includeNSI: false,
        );
    final database = await _ref.read(databaseProvider).database;

    // For multiple words, we make query like
    // "terms like '>first%' or terms like '>second%'".
    final words = query
        .split(' ')
        .map((s) => _normalize(s))
        .where((s) => s.length >= 2)
        .map((s) => '>$s%')
        .toList();
    final queryParts = words.map((_) => 'terms like ?').join(' or ');

    List<dynamic> response;
    if (presets.isEmpty) {
      if (words.isEmpty) return const [];
      response = await database.query(kTableName,
          columns: ['change_id'], where: queryParts, whereArgs: words);
    } else {
      response = await database.query(kTableName,
          columns: ['change_id'],
          where: '$queryParts or preset_name = ?',
          whereArgs: words + [presets.first.id]);
    }

    List<OsmChange> changes = _ref
        .read(changesProvider.notifier)
        .fetch(response.map((row) => row['change_id'] as String));

    // Sort by distance.
    const distance = DistanceEquirectangular();
    changes = changes
        .where((el) => distance(location, el.location) <= maxDistance)
        .toList();
    changes.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));
    if (changes.length > maxResults) changes = changes.sublist(0, maxResults);
    return changes;
  }

  Future<Map<OsmChange, Preset>> getPresetsFor(List<OsmChange> changes,
      {Locale? locale}) async {
    final presetProv = _ref.read(presetProvider);
    final database = await _ref.read(databaseProvider).database;
    final placeholders = List.filled(changes.length, '?').join(',');
    final response = await database.query(
      kTableName,
      columns: ['change_id', 'preset_name'],
      where: 'change_id in $placeholders and preset_name is not null',
      whereArgs: changes.map((c) => c.databaseId).toList(),
    );
    final presetNames =
        response.map((row) => row['preset_name'] as String).toList();
    final dbIdToPresetName = {
      for (int i = 0; i < response.length; i++)
        response[i]['change_id'] as String: i
    };
    final presets =
        await presetProv.getPresetsById(presetNames, locale: locale);
    final result = <OsmChange, Preset>{};
    for (final change in changes) {
      if (dbIdToPresetName.containsKey(change.databaseId))
        result[change] = presets[dbIdToPresetName[change.databaseId]!];
    }
    return result;
  }
}
