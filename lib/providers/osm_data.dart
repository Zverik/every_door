import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/helpers/payment_tags.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/road_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:sqflite/utils/utils.dart';

final osmDataProvider = ChangeNotifierProvider((ref) => OsmDataHelper(ref));

class OsmDataHelper extends ChangeNotifier {
  final Ref _ref;
  int _length = 0;
  int _obsoleteLength = 0;
  Set<StreetAddress> _addressesWithFloors = {};

  OsmDataHelper(this._ref) {
    _updateLength();
  }

  /// Number of OSM elements in the database.
  int get length => _length;
  int get obsoleteLength => _obsoleteLength;

  /// Removes super-obsolete OSM elements from the database.
  Future<int> _purgeElements(DateTime before) async {
    final database = await _ref.read(databaseProvider).database;
    // Keep elements that are referenced from the changes table.
    int count = await database.delete(
      OsmElement.kTableName,
      where: 'downloaded is not null and downloaded < ? '
          'and osmid not in (select osmid from ${OsmChange.kTableName})',
      whereArgs: [before.millisecondsSinceEpoch],
    );
    await _updateLength();
    return count;
  }

  Future<int> getObsoleteDataCount([DateTime? before]) async {
    final database = await _ref.read(databaseProvider).database;
    final beforeTimestamp =
        before ?? DateTime.now().subtract(kSuperObsoleteData);
    final result = await database.query(
      OsmElement.kTableName,
      columns: ['count(*)'],
      where: 'downloaded is not null and downloaded < ? '
          'and osmid not in (select osmid from ${OsmChange.kTableName})',
      whereArgs: [beforeTimestamp.millisecondsSinceEpoch],
    );
    return firstIntValue(result) ?? 0;
  }

  /// Removes super-obsolete elements and areas from the database.
  Future<int> purgeData([bool all = false]) async {
    final beforeTimestamp =
        all ? DateTime.now() : DateTime.now().subtract(kSuperObsoleteData);
    final count = await _purgeElements(beforeTimestamp);
    await _ref.read(downloadedAreaProvider).purgeAreas(beforeTimestamp);
    await _ref.read(roadNameProvider).purgeNames(beforeTimestamp);
    return count;
  }

  Future _updateLength() async {
    final database = await _ref.read(databaseProvider).database;
    final result = await database
        .rawQuery("select count(*) as cnt from ${OsmElement.kTableName}");
    _length = firstIntValue(result) ?? 0;
    _obsoleteLength = await getObsoleteDataCount();
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
          whereArgs: [
            bounds.south * kCoordinatePrecision,
            bounds.north * kCoordinatePrecision,
            bounds.west * kCoordinatePrecision,
            bounds.east * kCoordinatePrecision,
          ],
        );
      }

      final batch = txn.batch();
      for (final element in elements) {
        batch.insert(
          OsmElement.kTableName,
          element.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    if (bounds != null) await _ref.read(downloadedAreaProvider).addArea(bounds);
    await _updateLength();
  }

  List<OsmChange> _wrapInChange(Iterable<OsmElement> elements,
      [bool addNew = true]) {
    final changes = _ref.read(changesProvider);
    final result = elements
        .map((e) => changes.changeFor(e))
        .where((change) => !change.deleted)
        .toList();
    if (addNew) result.addAll(changes.getNew());
    return result;
  }

  Future<List<OsmChange>> _queryElements(List<String> hashes) async {
    if (hashes.isEmpty) return [];
    final database = await _ref.read(databaseProvider).database;
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: 'geohash in ($placeholders)',
      whereArgs: hashes,
    );
    return _wrapInChange(rows.map((e) => OsmElement.fromJson(e)));
  }

  /// Restores objects from the database.
  Future<List<OsmChange>> getElements(LatLng center, int radius) async {
    final hashes = createGeohashes(center.latitude, center.longitude,
        radius.toDouble(), kGeohashPrecision);
    return await _queryElements(hashes);
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

    // Add addresses from edited objects (nvm duplicates).
    const distance = DistanceEquirectangular();
    final changedElements = _ref
        .read(changesProvider)
        .all()
        .where((element) =>
            distance(location, element.location) <= kVisibilityRadius &&
            element['addr:housenumber'] != null)
        .map((e) => e.toElement(newId: -1));
    elements.addAll(changedElements);

    // Removed non-buildings if requested.
    if (!includeAmenities)
      elements.removeWhere((e) => !isBuildingOrAddressPoint(e.tags));

    // Hash addresses by distance.
    final Map<StreetAddress, double> addresses = {};
    for (final e in elements) {
      final hash = StreetAddress.fromTags(e.tags, e.center);
      if (hash.isNotEmpty) {
        double dist = distance(location, e.center!);
        double? oldDist = addresses[hash];
        if (oldDist == null || oldDist > dist) addresses[hash] = dist;
      }
    }

    // Return N closest addresses.
    final results = addresses.keys.toList();
    results.sort((a, b) => addresses[a]!.compareTo(addresses[b]!));
    if (results.length > limit) return results.sublist(0, limit);
    return results;
  }

  Future updateAddressesWithFloors() async {
    _addressesWithFloors.clear();

    final database = await _ref.read(databaseProvider).database;
    final rows = await database.query(OsmElement.kTableName,
        where: "tags like '%\"addr:floor\"%' or tags like '%\"level\"%'");
    final elements = rows.map((row) => OsmElement.fromJson(row)).toList();

    final changedElements = _ref
        .read(changesProvider)
        .all()
        .where((element) => element['addr:housenumber'] != null)
        .map((e) => e.toElement(newId: -1));
    elements.addAll(changedElements);

    final floors = <StreetAddress, Set<Floor>>{};
    for (final el in elements) {
      final addr = StreetAddress.fromTags(el.tags);
      if (addr.isEmpty) continue;
      final newFloors = MultiFloor.fromTags(el.tags);
      if (newFloors.isNotEmpty) {
        if (floors.containsKey(addr))
          floors[addr]!.addAll(newFloors.floors);
        else
          floors[addr] = Set.of(newFloors.floors);
      }
    }

    _addressesWithFloors = floors.entries
        .where((e) => e.value.length >= 2)
        .map((e) => e.key)
        .toSet();
  }

  bool hasMultipleFloors(StreetAddress address) =>
      _addressesWithFloors.contains(address);

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
        final newFloors = MultiFloor.fromTags(tags);
        floors.addAll(newFloors.floors);
      }
    }
    // Floor.collapse(floors);

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
        .where((e) => e.value >= minCount && e.value >= 2)
        .map((e) => e.key)
        .toSet();

    // If no results, use the default.
    if (result.isEmpty) {
      result.addAll(_ref
          .read(editorSettingsProvider)
          .defaultPayment
          .map((e) => 'payment:$e'));
    }

    // Ensure visa is listed alongside mastercard.
    if (result.contains('payment:visa')) result.add('payment:mastercard');
    if (result.contains('payment:mastercard')) result.add('payment:visa');
    return result;
  }

  Future<OsmChange?> findPossibleDuplicate(OsmChange amenity) async {
    final mainKey = getMainKey(amenity.getFullTags());
    if (mainKey == null) return null;

    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(
        amenity.location.latitude,
        amenity.location.longitude,
        kDuplicateSearchRadius.toDouble(),
        kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and (tags like '%$mainKey%')",
      whereArgs: hashes,
    );
    final elements = _wrapInChange(
        rows
            .map((row) => OsmElement.fromJson(row))
            .where((e) => e.tags[mainKey] == amenity[mainKey]),
        false);

    // Which names are we looking for.
    final names = <String>{};
    amenity.getFullTags().forEach((key, value) {
      if (key.startsWith('name') || key == 'operator') {
        final v = normalizeString(value);
        if (v.length >= 3) names.add(v);
      }
    });

    // Filter elements that have similar name tags.
    elements.retainWhere((element) {
      for (final key in element.getFullTags().keys) {
        if (key.startsWith('name') || key == 'operator') {
          final v = normalizeString(element[key]!);
          if (v.length >= 3) {
            for (final n in names) {
              if (n.contains(v) || v.contains(n)) return true;
            }
          }
        }
      }
      return false;
    });
    if (elements.isEmpty) return null;

    // Sort by distance and return the closest.
    const distance = DistanceEquirectangular();
    elements.sort((a, b) => distance(amenity.location, a.location)
        .compareTo(distance(amenity.location, b.location)));
    return elements.first;
  }

  Future<Map<String, int>> getComboOptionsCount(String key) async {
    final database = await _ref.read(databaseProvider).database;
    final rows = await database.query(
      OsmElement.kTableName,
      where: "tags like ?",
      whereArgs: ['%"$key%'],
    );

    // Iterate over objects and count values.
    final counter = <String, int>{};
    for (final row in rows) {
      final element = OsmElement.fromJson(row);
      if (key.endsWith(':')) {
        element.tags.forEach((k, _) {
          if (k.startsWith(key)) {
            final v = k.substring(key.length);
            counter[v] = (counter[v] ?? 0) + 1;
          }
        });
      } else {
        final v = element.tags[key];
        if (v != null) counter[v] = (counter[v] ?? 0) + 1;
      }
    }

    // This map is great for sorting over it.
    return counter;
  }

  Future<List<OsmChange>> downloadMap(LatLngBounds bounds) async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.downloading;
    try {
      final api = _ref.read(osmApiProvider);
      final roadNames = <RoadNameRecord>{};
      final List<OsmElement> elements =
          await api.map(bounds, roadNames: roadNames);
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.updatingDatabase;
      await storeElements(elements, bounds);
      await _ref.read(roadNameProvider).storeNames(roadNames);
      updateAddressesWithFloors();
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
    } on Exception {
      try {
        return await downloadMap(boundsFromRadius(location, kSmallRadius));
      } on Exception catch (e) {
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
