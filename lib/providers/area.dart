import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/circle_bounds.dart';
import 'package:every_door/models/osm_area.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

final downloadedAreaProvider =
    ChangeNotifierProvider((ref) => AreaProvider(ref));

final areaStatusProvider = FutureProvider((ref) async {
  final area = ref.watch(downloadedAreaProvider);
  final location = ref.watch(effectiveLocationProvider);
  final bbox = boundsFromRadius(location, kVisibilityRadius);
  final status = await area.getAreaStatus(bbox);
  return status;
});

enum AreaStatus {
  missing,
  obsolete,
  fresh,
}

class AreaProvider extends ChangeNotifier {
  final Ref _ref;

  AreaProvider(this._ref);

  Future addArea(LatLngBounds bounds) async {
    final database = await _ref.read(databaseProvider).database;
    final area = OsmDownloadedArea(bounds, DateTime.now());
    await database.insert(OsmDownloadedArea.kTableName, area.toJson());
    notifyListeners();
  }

  Future purgeAreas(DateTime before) async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      OsmDownloadedArea.kTableName,
      where: 'downloaded < ?',
      whereArgs: [before.millisecondsSinceEpoch],
    );
    notifyListeners();
  }

  Future<List<LatLngBounds>> getAllAreas({bool withObsolete = false}) async {
    final database = await _ref.read(databaseProvider).database;
    final rows = await database.query(OsmDownloadedArea.kTableName);
    Iterable<OsmDownloadedArea> areas =
        rows.map((r) => OsmDownloadedArea.fromJson(r));
    if (!withObsolete) areas = areas.where((area) => !area.isObsolete);
    return areas.map((area) => area.bounds).toList();
  }

  Future<AreaStatus> getAreaStatus(LatLngBounds bounds) async {
    final database = await _ref.read(databaseProvider).database;
    final areas = await database.query(
      OsmDownloadedArea.kTableName,
      where: 'min_lat < ? and min_lon < ? and max_lat > ? and max_lon > ?',
      whereArgs: [bounds.north, bounds.east, bounds.south, bounds.west],
    );

    List<LatLngBounds> uncoveredFresh = [bounds];
    List<LatLngBounds> uncoveredObsolete = [bounds];
    for (final row in areas) {
      final area = OsmDownloadedArea.fromJson(row);
      uncoveredObsolete = _removePartFromList(uncoveredObsolete, area.bounds);
      if (!area.isObsolete) {
        uncoveredFresh = _removePartFromList(uncoveredFresh, area.bounds);
      }
    }
    if (uncoveredFresh.isEmpty) return AreaStatus.fresh;
    if (uncoveredObsolete.isEmpty) return AreaStatus.obsolete;
    return AreaStatus.missing;
  }

  List<LatLngBounds> _removePartFromList(
      List<LatLngBounds> base, LatLngBounds part) {
    return base.expand((element) => _removePart(element, part)).toList();
  }

  /// Removed "part" from "base", returning up to four envelopes.
  List<LatLngBounds> _removePart(LatLngBounds base, LatLngBounds part) {
    if (!part.isOverlapping(base)) return [base];

    List<LatLngBounds> result = [];
    if (part.north < base.north && part.north > base.south) {
      // Top part
      result.add(LatLngBounds(LatLng(part.north, base.west), base.northEast));
    }
    if (part.south > base.south && part.south < base.north) {
      // Bottom
      result.add(LatLngBounds(base.southWest, LatLng(part.south, base.east)));
    }
    if (part.west > base.west && part.west < base.east) {
      // Left
      result.add(LatLngBounds(base.southWest, LatLng(base.north, part.west)));
    }
    if (part.east < base.east && part.east > base.west) {
      // Right
      result.add(LatLngBounds(LatLng(base.south, part.east), base.northEast));
    }
    return result;
  }
}
