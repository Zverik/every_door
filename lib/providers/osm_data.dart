import 'dart:async';
import 'dart:collection';

import 'package:every_door/helpers/counter.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/geometry/circle_bounds.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/helpers/location_object.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/helpers/tags/payment_tags.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/road_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:sqflite/utils/utils.dart';

final osmDataProvider = ChangeNotifierProvider((ref) => OsmDataHelper(ref));

class OsmDataHelper extends ChangeNotifier {
  static final _logger = Logger('OsmDataHelper');
  final Ref _ref;
  int _length = 0;
  int _obsoleteLength = 0;
  Set<StreetAddress> _addressesWithFloors = {};
  bool capitalizeNames = kCapitalizeNames;
  List<Floor> floorNumbering = [];

  OsmDataHelper(this._ref) {
    _updateLength();
    _updateCapitalizeNames();
    updateFloorNumbering();
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
    _updateCapitalizeNames();
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
    _updateCapitalizeNames();
    updateFloorNumbering();
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

  /// Queries a single element from the downloaded objects
  /// and returns an [OsmChange] for it, even if it was deleted.
  Future<OsmChange?> getElement(OsmId id) async {
    final database = await _ref.read(databaseProvider).database;
    final rows = await database.query(
      OsmElement.kTableName,
      where: 'osmid = ?',
      whereArgs: [id.toString()],
    );
    if (rows.isEmpty) return null;
    final changes = _ref.read(changesProvider);
    return changes.changeFor(OsmElement.fromJson(rows.first));
  }

  bool isBuildingOrAddressPoint(Map<String, String> tags) {
    if (tags.containsKey('building')) return true;
    const kMetaTags = {'source', 'note'};
    return tags.keys
        .every((k) => k.startsWith('addr:') || kMetaTags.contains(k));
  }

  Future<List<OsmElement>> _getAddressedElementsAround(LatLng location,
      {int radius = kVisibilityRadius}) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        radius.toDouble(), kGeohashPrecision);
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

    return elements;
  }

  Future<List<StreetAddress>> getAddressesAround(LatLng location,
      {int limit = 4, bool includeAmenities = true}) async {
    final elements = await _getAddressedElementsAround(location);

    // Removed non-buildings if requested.
    if (!includeAmenities)
      elements.removeWhere((e) => !isBuildingOrAddressPoint(e.tags));

    // Hash addresses by distance.
    const distance = DistanceEquirectangular();
    final Map<StreetAddress, double> addresses = {};
    for (final e in elements) {
      final hash = StreetAddress.fromTags(e.tags, location: e.center);
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

  Future<bool> isUniqueAddress(StreetAddress address, LatLng location) async {
    final elements = await _getAddressedElementsAround(location);
    final addresses = Counter(elements
        .map((e) => StreetAddress.fromTags(e.tags))
        .where((a) => a.isNotEmpty));
    return addresses[address] == 1;
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

  /// Returns common floors for level=0, level=1 and level=2.
  /// If lower levels are missing or ambiguous, higher levels not returned.
  Future<List<Floor>> updateFloorNumbering([LatLng? location]) async {
    // TODO: this performs very slow, making the app slow on saving.
    final database = await _ref.read(databaseProvider).database;
    final hashes = location == null
        ? const []
        : createGeohashes(location.latitude, location.longitude,
            kLocalFloorsRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: hashes.isEmpty
          ? "tags like '%addr:floor%'"
          : "geohash in ($placeholders) and tags like '%addr:floor%'",
      whereArgs: hashes,
    );
    final elements = rows.map((row) => OsmElement.fromJson(row));
    final elementTags = elements.map((row) => row.tags).toList();

    // Add all new changes with floors
    final changedElements = _ref.read(changesProvider).all();
    elementTags.addAll(changedElements.map((e) => e.getFullTags()));

    // Count addr:floor values for levels=0..kMaxFloor.
    final floors = <int, Counter<String>>{};
    const kMaxFloor = 1;
    for (final tags in elementTags) {
      final newFloors = MultiFloor.fromTags(tags);
      for (final floor in newFloors.floors) {
        final level = floor.level?.roundToDouble();
        if (level != null && floor.floor != null) {
          if (level == floor.level && level <= kMaxFloor && level >= 0) {
            final intLevel = level.toInt();
            if (!floors.containsKey(intLevel))
              floors[intLevel] = Counter<String>();
            floors[intLevel]!.add(floor.floor!);
          }
        }
      }
    }

    // Iterate over levels and check that floors are unambiguous enough.
    final result = <Floor>[];
    for (int i = 0; i <= kMaxFloor; i++) {
      if (!floors.containsKey(i)) break;
      final firstTwo = floors[i]!.mostOccurent(2).toList();
      if (firstTwo.first.count < 3) break;
      // 3 vs 1 ok, 6 vs 2 etc.
      if (firstTwo.length > 1 && firstTwo[1].count * 3 > firstTwo.first.count)
        break;
      result.add(Floor(level: i.toDouble(), floor: firstTwo.first.item));
    }

    floorNumbering = result;
    return result;
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
    final elements = LocationObjectSet(rows
        .map((row) => OsmElement.fromJson(row))
        .where((element) => element.tags.containsKey('opening_hours'))
        .map((e) => LocationObject(e.center!, e.tags['opening_hours']!)));

    elements.sortByDistance(location, unique: true);
    return elements.take(limit);
  }

  Future<List<String>> getPostcodesAround(LatLng location,
      {int limit = 3}) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kVisibilityRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and tags like '%addr:postcode%'",
      whereArgs: hashes,
    );

    // Keep only amenities with opening_hours.
    final elements = LocationObjectSet(rows
        .map((row) => OsmElement.fromJson(row))
        .where((element) => element.tags.containsKey('addr:postcode'))
        .map((e) => LocationObject(e.center!, e.tags['addr:postcode']!)));

    // Add all new changes with postcodes
    const distance = DistanceEquirectangular();
    final changedElements = _ref.read(changesProvider).all().where((element) =>
        distance(location, element.location) <= kVisibilityRadius &&
        element['addr:postcode'] != null);
    elements.addAll(changedElements
        .map((e) => LocationObject(e.location, e['addr:postcode']!)));

    elements.sortByDistance(location, unique: true);
    return elements.take(limit);
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
    final tagCount = Counter<String>();
    for (final tags in elementTags) {
      final paymentTags = tags.entries
          .where((tag) => tag.value == 'yes' && kCardOptions.contains(tag.key))
          .map((e) => e.key);
      if (paymentTags.isNotEmpty) {
        count++;
        tagCount.addAll(paymentTags);
      }
    }

    // List all payment options that appear at least on 1/3 of objects.
    final result = tagCount
        .mostOccurentItems(cutoff: count < 6 ? 2 : (count / 3).ceil())
        .toSet();

    return result;
  }

  Future<bool> _updateCapitalizeNames([LatLng? location]) async {
    final database = await _ref.read(databaseProvider).database;
    final List<String> hashes = location == null
        ? const []
        : createGeohashes(location.latitude, location.longitude,
            kBigRadius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: placeholders.isEmpty
          ? "tags like '%\"name\"%'"
          : "geohash in ($placeholders) and tags like '%\"name\"%'",
      whereArgs: hashes,
    );
    // Get names from the found elements.
    final elements = rows.map((row) => OsmElement.fromJson(row));
    final names =
        elements.map((el) => OsmChange(el)['name']).whereType<String>();
    // Split in words and keep those that have at least two.
    final kNotWord = RegExp(r'\P{Letter}+', unicode: true);
    final split = names
        .map((n) => n.split(kNotWord).where((s) => s.isNotEmpty))
        .where((el) => el.length >= 2)
        .map((el) => el.skip(1));

    // Count number of capitalized words.
    final words = split.expand((w) => w).toList(); // do the processing
    final kCapitalized = RegExp(r'^\p{Lu}(?:$|\p{Ll})', unicode: true);
    final kNotCapitalized = RegExp(r'^\p{Ll}', unicode: true);
    final cap =
        words.where((w) => kCapitalized.matchAsPrefix(w) != null).length;
    final noncap =
        words.where((w) => kNotCapitalized.matchAsPrefix(w) != null).length;

    // We need at least 3 named amenities to decide.
    _logger.fine(
        'Found $cap capitalized and $noncap non-capitalized names in ${words.length} words.');
    if (cap + noncap < 3) return kCapitalizeNames;
    capitalizeNames = cap > noncap;
    return capitalizeNames;
  }

  Future<OsmChange?> findPossibleDuplicate(OsmChange amenity) async {
    final mainKey = clearPrefixNull(amenity.mainKey);
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

  Future<int> _downloadMap(LatLngBounds bounds) async {
    final api = _ref.read(osmApiProvider);
    final roadNames = <RoadNameRecord>{};
    final List<OsmElement> elements =
        await api.map(bounds, roadNames: roadNames);
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.updatingDatabase;
    await storeElements(elements, bounds);
    await _ref.read(roadNameProvider).storeNames(roadNames);
    updateAddressesWithFloors();
    return elements.length;
  }

  Future<int> downloadAround(LatLng location) async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.downloading;
    try {
      return await _downloadMap(boundsFromRadius(location, kBigRadius));
    } on OsmApiError {
      return await _downloadMap(boundsFromRadius(location, kSmallRadius));
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }

  Future<int> downloadInBounds(LatLngBounds bounds) async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.downloading;
    final boxes = ListQueue<LatLngBounds>(1);
    boxes.add(bounds);
    int downloaded = 0;
    try {
      while (boxes.isNotEmpty) {
        final box = boxes.removeFirst();
        try {
          downloaded += await _downloadMap(box);
        } on OsmApiError {
          // Split the box in four and add to the queue.
          final center = box.center;
          boxes.addAll([
            LatLngBounds(box.southEast, center),
            LatLngBounds(box.southWest, center),
            LatLngBounds(box.northEast, center),
            LatLngBounds(box.northWest, center),
          ]);
        }
      }
    } on Exception catch (e) {
      _logger.severe('Error while bulk downloading OSM data: $e');
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
    return downloaded;
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
