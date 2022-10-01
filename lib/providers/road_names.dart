import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:proximity_hash/proximity_hash.dart';
import 'dart:math' show max;

final roadNameProvider = Provider((ref) => RoadNameProvider(ref));

class RoadNameProvider {
  final Ref _ref;

  RoadNameProvider(this._ref);

  Future storeNames(Iterable<RoadNameRecord> names) async {
    if (names.isEmpty) return;
    final database = await _ref.read(databaseProvider).database;
    await database.transaction((txn) async {
      // First delete obsolete names.
      final geohashes = names.map((n) => n.geohash).toSet().toList();
      const kChunk = 500;
      for (int i = 0; i < geohashes.length; i += kChunk) {
        final end = (i + 1) * kChunk;
        final chunk = geohashes.sublist(
            i * kChunk, end > geohashes.length ? geohashes.length : end);
        final placeholders =
            List.generate(chunk.length, (index) => "?").join(",");
        await txn.delete(
          RoadNameRecord.kTableName,
          where: 'geohash in ($placeholders)',
          whereArgs: chunk,
        );
      }

      // Then insert new names.
      final batch = txn.batch();
      for (final name in names) {
        batch.insert(RoadNameRecord.kTableName, name.toJson());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Removes super-obsolete elements from the database.
  Future<int> purgeNames(DateTime before) async {
    final database = await _ref.read(databaseProvider).database;
    int count = await database.delete(
      RoadNameRecord.kTableName,
      where: 'downloaded < ?',
      whereArgs: [before.millisecondsSinceEpoch],
    );
    return count;
  }

  Future<List<String>> getNamesAround(LatLng location,
      {double? radius, int limit = 3}) async {
    final effRadius = max(radius ?? kFarVisibilityRadius.toDouble(), 101.0);

    // Merge two sources for road names.
    final names = await _getNamesFromAddresses(location, effRadius);
    final names2 = await _getNamesFromRoads(location, effRadius);
    for (final e in names2.entries) {
      // Prioritizing streets from closer addresses.
      final dist = max(e.value, 100.0 + e.value / 1000.0);
      if ((names[e.key] ?? 10000.0) > dist) names[e.key] = dist;
    }

    // Sort by distance
    final entries = names.entries.where((e) => e.value <= effRadius).toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries.map((e) => e.key).take(limit).toList();
  }

  Future<Map<String, double>> _getNamesFromAddresses(
      LatLng location, double radius) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        radius.toDouble(), kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      OsmElement.kTableName,
      where: "geohash in ($placeholders) and tags like '%addr:street%'",
      whereArgs: hashes,
    );
    final elements = rows.map((row) => OsmElement.fromJson(row)).toList();

    // Add addresses from edited objects.
    const distance = DistanceEquirectangular();
    final changedElements = _ref
        .read(changesProvider)
        .all()
        .where((element) =>
            distance(location, element.location) <= radius &&
            element['addr:street'] != null)
        .map((e) => e.toElement(newId: -1));
    elements.addAll(changedElements);

    // Find the minimal distance for each road name.
    final nameDistance = <String, double>{};
    for (final el in elements) {
      final name = el.tags['addr:street'];
      if (name != null) {
        final dist = distance(location, el.center!);
        if ((nameDistance[name] ?? 10000.0) > dist) nameDistance[name] = dist;
      }
    }
    return nameDistance;
  }

  Future<Map<String, double>> _getNamesFromRoads(
      LatLng location, double radius) async {
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        radius.toDouble(), kRoadNameGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      RoadNameRecord.kTableName,
      where: "geohash in ($placeholders)",
      whereArgs: hashes,
    );
    final roadNames = rows.map((row) => RoadNameRecord.fromJson(row)).toList();

    const distance = DistanceEquirectangular();
    final nameDistance = <String, double>{};
    for (final rn in roadNames) {
      final dist = distance(location, rn.center);
      if ((nameDistance[rn.name] ?? 10000.0) > dist)
        nameDistance[rn.name] = dist;
    }
    return nameDistance;
  }
}
