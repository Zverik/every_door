import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/payment_tags.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:sqflite/utils/utils.dart';

final osmDataProvider = ChangeNotifierProvider((ref) => OsmDataHelper(ref));

class OsmDataHelper extends ChangeNotifier {
  final Ref _ref;
  int _length = 0;

  OsmDataHelper(this._ref) {
    _updateLength();
  }

  /// Number of OSM elements in the database.
  int get length => _length;

  /// Removes super-obsolete OSM elements from the database.
  Future<int> _purgeElements() async {
    final database = await _ref.read(databaseProvider).database;
    final beforeTimestamp =
        DateTime.now().subtract(kSuperObsoleteData).millisecondsSinceEpoch;
    // Keep elements that are referenced from the changes table.
    int count = await database.delete(
      OsmElement.kTableName,
      where: 'downloaded is not null and downloaded < ? '
          'and osmid not in (select osmid from ${OsmChange.kTableName})',
      whereArgs: [beforeTimestamp],
    );
    await _updateLength();
    return count;
  }

  Future<bool> hasObsoleteData() async {
    final database = await _ref.read(databaseProvider).database;
    final beforeTimestamp =
        DateTime.now().subtract(kSuperObsoleteData).millisecondsSinceEpoch;
    final result = await database.query(
      OsmElement.kTableName,
      columns: ['count(*)'],
      where: 'downloaded is not null and downloaded < ? '
          'and osmid not in (select osmid from ${OsmChange.kTableName})',
      whereArgs: [beforeTimestamp],
    );
    return (firstIntValue(result) ?? 0) > 0;
  }

  /// Removes super-obsolete elements and areas from the database.
  Future<int> purgeData() async {
    final count = await _purgeElements();
    await _ref.read(downloadedAreaProvider).purgeAreas();
    return count;
  }

  Future _updateLength() async {
    final database = await _ref.read(databaseProvider).database;
    final result = await database
        .rawQuery("select count(*) as cnt from ${OsmElement.kTableName}");
    _length = result.first['cnt'] as int;
    notifyListeners();
  }

  /// Saves all the downloaded elements and the bounding box to the database.
  Future storeElements(
      Iterable<OsmElement> elements, LatLngBounds? bounds) async {
    final database = await _ref.read(databaseProvider).database;
    await database.transaction((txn) async {
      // Delete objects in the area, to account for deletions.
      if (bounds != null) {
        await txn.delete(
          OsmElement.kTableName,
          where: 'lat >= ? and lat <= ? and lon >= ? and lon <= ?',
          whereArgs: [bounds.south, bounds.north, bounds.west, bounds.east],
        );
      }
      // Yeah, 1000 inserts, but what can we do. Too many arguments.
      for (final element in elements) {
        await txn.insert(
          OsmElement.kTableName,
          element.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    if (bounds != null) await _ref.read(downloadedAreaProvider).addArea(bounds);
    await _updateLength();
  }

  List<OsmChange> _wrapInChange(Iterable<OsmElement> elements) {
    final changes = _ref.read(changesProvider);
    return elements
            .map((e) => changes.changeFor(e))
            .where((change) => !change.deleted)
            .toList() +
        changes.getNew();
  }

  /// Restores objects from the database.
  Future<List<OsmChange>> getElements(LatLng center, int radius) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(center.latitude, center.longitude,
        radius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: 'geohash in ($placeholders)',
      whereArgs: hashes,
    );
    return _wrapInChange(rows.map((e) => OsmElement.fromJson(e)));
  }

  bool isBuildingOrAddressPoint(Map<String, String> tags) {
    if (tags.containsKey('building')) return true;
    const kMetaTags = {'source', 'note'};
    return tags.keys
        .every((k) => k.startsWith('addr:') || kMetaTags.contains(k));
  }

  Future<List<StreetAddress>> getAddressesAround(LatLng location,
      {int limit = 4, bool includeAmenities = true}) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kVisibilityRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and tags like '%addr:%'",
      whereArgs: hashes,
    );
    final elements = rows.map((row) => OsmElement.fromJson(row)).toList();
    if (!includeAmenities)
      elements.removeWhere((e) => !isBuildingOrAddressPoint(e.tags));

    const distance = DistanceEquirectangular();
    final Map<StreetAddress, double> addresses = {};
    for (final e in elements) {
      final hash = StreetAddress.fromTags(e.tags, e.center);
      if (hash.isNotEmpty) {
        double dist = distance(location, e.center!);
        double? oldDist = addresses[hash];
        if (oldDist == null || oldDist > dist) addresses[hash] = dist;
      }
    }

    final results = addresses.keys.toList();
    results.sort((a, b) => addresses[a]!.compareTo(addresses[b]!));
    if (results.length > limit) return results.sublist(0, limit);
    return results;
  }

  Future<List<Floor>> getFloorsAround(LatLng location,
      [StreetAddress? address]) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kVisibilityRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where:
          "geohash in ($placeholders) and (tags like '%addr:floor%' or tags like '%level%')",
      whereArgs: hashes,
    );
    final elements = rows.map((row) => OsmElement.fromJson(row));
    final elementTags = elements.map((row) => row.tags).toList();

    // Add all new changes with floors
    const distance = DistanceEquirectangular();
    final changedElements = _ref.read(changesProvider).all().where(
        (element) => distance(location, element.location) <= kVisibilityRadius);
    elementTags.addAll(changedElements.map((e) => e.getFullTags()));

    final floors = <Floor>{};
    for (final tags in elementTags) {
      final addr = StreetAddress.fromTags(tags);
      if (address == null ||
          (addr.isEmpty && address.isEmpty) ||
          (addr == address)) {
        final floor = Floor.fromTags(tags);
        if (floor.isNotEmpty) floors.add(floor);
      }
    }
    Floor.collapse(floors);

    final results = List.of(floors);
    results.sort();
    return results;
  }

  Future<List<String>> getOpeningHoursAround(LatLng location,
      {int limit = 10}) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kVisibilityRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and tags like '%opening_hours%'",
      whereArgs: hashes,
    );

    // Keep only amenities with opening_hours.
    final elements = rows
        .map((row) => OsmElement.fromJson(row))
        .where((element) => element.tags.containsKey('opening_hours'))
        .toList();

    // Sort by distance and keep the few closest amenities.
    const distance = DistanceEquirectangular();
    elements.sort((a, b) =>
        distance(location, a.center!).compareTo(distance(location, b.center!)));
    if (elements.length > limit) elements.removeRange(limit, elements.length);

    return elements
        .map((e) => e.tags['opening_hours'])
        .whereType<String>()
        .toList();
  }

  Future<Set<String>> getCardPaymentOptions(LatLng location) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kVisibilityRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and (tags like '%payment:%')",
      whereArgs: hashes,
    );
    final elements = rows.map((row) => OsmElement.fromJson(row));
    final elementTags = elements.map((row) => row.tags).toList();

    // Add all new changes with floors
    const distance = DistanceEquirectangular();
    final changedElements = _ref.read(changesProvider).all().where(
        (element) => distance(location, element.location) <= kVisibilityRadius);
    elementTags.addAll(changedElements.map((e) => e.getFullTags()));

    final kCardOptions = kCardPaymentOptions.map((e) => 'payment:$e').toSet();

    // Count all payment:XXX=yes tags.
    int count = 0;
    final tagCount = <String, int>{};
    for (final tags in elementTags) {
      final paymentTags = tags.entries
          .where((tag) => tag.value == 'yes' && kCardOptions.contains(tag.key))
          .map((e) => e.key);
      if (paymentTags.isNotEmpty) {
        count++;
        for (var key in paymentTags) {
          tagCount[key] = (tagCount[key] ?? 0) + 1;
        }
      }
    }

    // List all payment options that appear at least on 1/3 of objects.
    final minCount = (count / 3).ceil();
    final result = tagCount.entries
        .where((e) => e.value >= minCount)
        .map((e) => e.key)
        .toSet();

    // Ensure visa is listed alongside mastercard.
    if (result.isEmpty) result.add('payment:visa');
    if (result.contains('payment:visa')) result.add('payment:mastercard');
    if (result.contains('payment:mastercard')) result.add('payment:visa');
    return result;
  }

  Future<List<OsmChange>> downloadMap(LatLngBounds bounds) async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.downloading;
    try {
      final api = _ref.read(osmApiProvider);
      final List<OsmElement> elements = await api.map(bounds);
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.updatingDatabase;
      await storeElements(elements, bounds);
      AlertController.show('Download successful',
          'Downloaded ${elements.length} amenities.', TypeAlert.success);

      // No need to wrap in changes, since we don't use the result anyway.
      // return _wrapInChange(elements);
      return elements.map((e) => OsmChange(e)).toList();
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }

  Future<List<OsmChange>> downloadAround(LatLng location) async {
    try {
      return await downloadMap(boundsFromRadius(location, kBigRadius));
    } on Exception catch (e) {
      print(e);
      try {
        return await downloadMap(boundsFromRadius(location, kSmallRadius));
      } on Exception catch (e) {
        print(e);
        AlertController.show('Download failed', e.toString(), TypeAlert.error);
        return [];
      }
    }
  }

  Future updateElement(OsmElement element) async {
    final database = await _ref.read(databaseProvider).database;
    await database.insert(
      OsmElement.kTableName,
      element.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _updateLength();
  }

  Future deleteElement(OsmElement element) async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      OsmElement.kTableName,
      where: 'osmid = ?',
      whereArgs: [element.id.toString()],
    );
    await _updateLength();
  }
}
