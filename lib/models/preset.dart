// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:convert';
import 'package:country_coder/country_coder.dart';
import 'package:every_door/fields/name.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';

enum PresetType { normal, nsi, fixme, taginfo }

class Preset {
  final List<PresetField> fields; // Always open
  final List<PresetField> moreFields; // Open when set or requested
  final Map<String, dynamic>? fieldData; // For plugins to cache
  final bool onArea; // Can this preset be used on a area?
  final Map<String, String> addTags; // Added when preset is chosen
  final Map<String, String?> removeTags; // Removed when preset is replaced
  final String id;
  final String name;
  final String? _subtitle;
  final MultiIcon? icon;
  final LocationSet? locationSet;
  final PresetType type;
  final bool noStandard; // For plugins, do not extract standard fields

  // Hope we don't resort to using this
  static const defaultPreset = Preset(
    id: 'default',
    name: 'Amenity',
    fields: [NamePresetField(key: 'name', label: 'Name', placeholder: '')],
    addTags: {},
  );

  const Preset({
    required this.id,
    this.fields = const [],
    this.moreFields = const [],
    this.onArea = true,
    required this.addTags,
    this.removeTags = const {},
    required this.name,
    String? subtitle,
    this.icon,
    this.locationSet,
    this.fieldData,
    this.type = PresetType.normal,
    this.noStandard = false,
  }) : _subtitle = subtitle;

  factory Preset.fixme(String title, {String? subtitle}) {
    return Preset(
      id: 'fixme $title',
      fields: const [],
      moreFields: const [],
      onArea: true,
      addTags: {
        'amenity': 'fixme',
        'fixme': 'type',
        'fixme:type': title,
      },
      removeTags: const {},
      name: title,
      subtitle: subtitle ?? 'fixme',
      icon: null,
      locationSet: null,
      type: PresetType.fixme,
    );
  }

  factory Preset.poi(Map<String, dynamic> row) {
    final key = row['key'] as String;
    final value = row['value'] as String;
    final name = value
        .split('_')
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');

    return Preset(
      id: 'taginfo $key=$value',
      fields: const [],
      onArea: true,
      addTags: {key: value},
      name: name,
      icon: null,
      type: PresetType.taginfo,
    );
  }

  static Map<String, String?> decodeTags(Map<String, dynamic>? tags) {
    if (tags == null) return const {};
    return tags.map(
        (key, value) => MapEntry(key, value == '*' ? null : value.toString()));
  }

  static Map<String, String> decodeTagsSkipNull(Map<String, dynamic>? tags) {
    tags = decodeTags(tags);
    if (tags.isNotEmpty) {
      tags.removeWhere((key, value) => value == null);
    }
    return tags.cast<String, String>();
  }

  factory Preset.fromJson(Map<String, dynamic> data) {
    // Note: does not fill fields.
    return Preset(
      id: data['name'],
      onArea: data['can_area'] == 1,
      addTags: decodeTagsSkipNull(
          data['add_tags'] != null ? jsonDecode(data['add_tags']) : null),
      removeTags: decodeTagsSkipNull(
          data['remove_tags'] != null ? jsonDecode(data['remove_tags']) : null),
      icon: _resolveIcon(data['imageURL'] ?? data['icon'])
          ?.withTooltip(data['loc_name'] ?? data['name']),
      locationSet: data['locations'] == null
          ? null
          : LocationSet.fromJson(jsonDecode(data['locations'])),
      name: data['loc_name'],
    );
  }

  static MultiIcon? _resolveIcon(Object? url) {
    if (url == null || url is! String) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return MultiIcon(imageUrl: url);
    }

    final dashPos = url.indexOf('-');
    if (dashPos > 0) {
      final typ = url.substring(0, dashPos);
      final icon = url.substring(dashPos + 1);
      if (typ == 'maki') {
        return MultiIcon(
            imageUrl:
                'https://raw.githubusercontent.com/mapbox/maki/refs/heads/main/icons/$icon.svg');
      } else if (typ == 'temaki') {
        return MultiIcon(
            imageUrl:
                'https://raw.githubusercontent.com/rapideditor/temaki/refs/heads/main/icons/$icon.svg');
      } else if (typ == 'roentgen') {
        return MultiIcon(
            imageUrl:
                'https://raw.githubusercontent.com/openstreetmap/iD/refs/heads/develop/svg/roentgen/$icon.svg');
      } else if (typ == 'fas') {
        return MultiIcon(
            imageUrl:
                'https://raw.githubusercontent.com/openstreetmap/iD/refs/heads/develop/svg/fontawesome/$url.svg');
      }
    }

    return null;
  }

  factory Preset.fromNSIJson(Map<String, dynamic> data) {
    return Preset(
      id: data['id'],
      name: data['name'],
      subtitle: data['preset_ref'],
      addTags: decodeTagsSkipNull(jsonDecode(data['tags'])),
      locationSet: data['locations'] == null
          ? null
          : LocationSet.fromJson(jsonDecode(data['locations'])),
      type: PresetType.nsi,
    );
  }

  String get subtitle {
    if (_subtitle != null) return _subtitle;
    final key = getMainKey(addTags);
    if (key == null) return '';
    return '$key=${addTags[key]}';
  }

  bool get isGeneric => addTags.isEmpty || addTags.entries.first.value == "*";

  Preset withFields(List<PresetField> fields, List<PresetField> moreFields) {
    return Preset(
      id: id,
      fields: fields,
      moreFields: moreFields,
      fieldData: fieldData,
      onArea: onArea,
      addTags: addTags,
      removeTags: removeTags,
      name: name,
      subtitle: _subtitle,
      icon: icon,
      type: type,
      noStandard: noStandard,
    );
  }

  Preset withSubtitle(String subtitle) {
    return Preset(
      id: id,
      fields: fields,
      moreFields: moreFields,
      fieldData: fieldData,
      onArea: onArea,
      addTags: addTags,
      removeTags: removeTags,
      name: name,
      subtitle: subtitle,
      icon: icon,
      type: type,
      noStandard: noStandard,
    );
  }

  void doAddTags(OsmChange change) {
    final mainKey = getMainKey(addTags);
    addTags.forEach((key, value) {
      if (value == '*') return;
      // Prevent changing tag values that have been entered by hand.
      // We don't know that for sure for old objects though.
      if (change[key] != null &&
          (!change.isNew && change.changedTag(key)) &&
          mainKey != key) return;
      change[key] = value;
    });
  }

  void doRemoveTags(OsmChange change) {
    final tags = removeTags.isEmpty ? addTags : removeTags;
    tags.forEach((key, value) {
      if (change[key] != null) {
        if (value == '*' || value == change[key]) change.removeTag(key);
      }
    });
  }

  @override
  bool operator ==(Object other) => other is Preset && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Preset(id="$id", name="$name", can_area=$onArea, type=$type)';
}
