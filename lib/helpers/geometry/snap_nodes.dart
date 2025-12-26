// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;

class SnapResult {
  final LatLng newLocation;
  final OsmElement newElement;

  const SnapResult(this.newLocation, this.newElement);

  @override
  String toString() => 'SnapResult($newLocation, $newElement)';
}

class _DistanceResult {
  final double distance;
  final int nodeIdx;
  final LatLng projected;

  const _DistanceResult(
      {required this.distance, required this.nodeIdx, required this.projected});

  @override
  String toString() =>
      '_DistanceResult(distance: $distance, nodeIdx: $nodeIdx, projected: $projected';
}

class Snapper {
  static final _distance = DistanceEquirectangular();
  static const eps = 0.001; // 1/1000 of a segment length

  double _projectOnSegment(LatLng p, LatLng a, LatLng b) {
    final A = p.longitude - a.longitude;
    final B = p.latitude - a.latitude;
    final C = b.longitude - a.longitude;
    final D = b.latitude - a.latitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    if (lenSq != 0) return dot / lenSq;
    return -1;
  }

  double testProject(LatLng p, LatLng a, LatLng b) =>
      _projectOnSegment(p, a, b);

  LatLng _interpolate(LatLng a, LatLng b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  _DistanceResult? _distanceToWay(LatLng location, OsmElement way,
      {bool noEdges = false}) {
    if (!way.isGeometryValid) return null;
    final nodes = way.nodes!.map((n) => way.nodeLocations![n]!).toList();

    double? distance;
    int? nodeIdx;
    LatLng? closest;
    for (int i = 1; i < nodes.length; i++) {
      final t = _projectOnSegment(location, nodes[i - 1], nodes[i]);
      if (noEdges && (t < eps || t >= 1.0 - eps)) continue;
      final projected = _interpolate(nodes[i - 1], nodes[i], t);
      final d = _distance(location, projected);
      if (distance == null || d < distance) {
        distance = d;
        nodeIdx = i;
        closest = projected;
      }
    }

    return distance == null
        ? null
        : _DistanceResult(
            distance: distance,
            nodeIdx: nodeIdx!,
            projected: closest!,
          );
  }

  double? distanceToWay(LatLng location, OsmElement way,
      {bool noEdges = false}) {
    return _distanceToWay(location, way, noEdges: noEdges)?.distance;
  }

  OsmElement? closestWay(LatLng location, Iterable<OsmElement> ways,
      {double maxDistance = 1000.0, bool noEdges = false}) {
    OsmElement? closest;
    double distance = maxDistance;
    for (final way in ways) {
      final d = _distanceToWay(location, way, noEdges: noEdges)?.distance;
      if (d != null && d < distance) {
        closest = way;
        distance = d;
      }
    }
    return closest;
  }

  SnapResult? snap(int nodeId, LatLng location, OsmElement way) {
    // 1. Find the segment (node number) to join to.
    final closest = _distanceToWay(location, way, noEdges: true);
    if (closest == null) return null;

    // 2. Insert the node id and location into the way geometry.
    final newNodes = List.of(way.nodes!);
    final newLocations = Map.of(way.nodeLocations!);
    newLocations[nodeId] = closest.projected;
    newNodes.insert(closest.nodeIdx, nodeId);

    // 3. Return the new location and the new way.
    return SnapResult(
      closest.projected,
      way.copyWith(nodes: newNodes, nodeLocations: newLocations),
    );
  }

  SnapResult? snapToClosest(
      {required int nodeId,
      required LatLng location,
      required Iterable<OsmElement> ways,
      double maxDistance = 10.0}) {
    final closest =
        closestWay(location, ways, maxDistance: maxDistance, noEdges: true);
    if (closest == null) return null;
    return snap(nodeId, location, closest);
  }

  /// Groups locations into small bounding boxes.
  /// Not exactly part of a snapper, but it belongs to the same process.
  List<LatLngBounds> groupIntoSmallBounds(Iterable<LatLng> points,
      {double maxEdge = 0.003, double radius = 0.001}) {
    List<LatLngBounds> bounds = [];
    for (final point in points) {
      final newRect = LatLngBounds(
        LatLng(point.latitude - radius, point.longitude - radius),
        LatLng(point.latitude + radius, point.longitude + radius),
      );

      // First check if it can be inserted into any bounds
      bool found = false;
      for (final b in bounds) {
        final b2 = LatLngBounds(b.southWest, b.northEast);
        b2.extendBounds(newRect);
        if (b2.north - b2.south <= maxEdge && b2.east - b2.west <= maxEdge) {
          b.extendBounds(newRect);
          found = true;
          break;
        }
      }

      // If we could not find a suitable one, add a new one.
      if (!found) bounds.add(newRect);
    }
    return bounds;
  }

  List<List<OsmChange>> _splitSingleChangeGroup(
      List<OsmChange> changes, double minGap) {
    final lats = changes.map((c) => c.location.latitude).toList();
    lats.sort();
    double maxGap = minGap;
    int latGapPos = -1;
    for (int i = 1; i < lats.length; i++) {
      if (lats[i] - lats[i - 1] > maxGap) {
        maxGap = lats[i] - lats[i - 1];
        latGapPos = i;
      }
    }

    final lons = changes.map((c) => c.location.longitude).toList();
    lons.sort();
    int lonGapPos = -1;
    for (int i = 1; i < lons.length; i++) {
      if (lons[i] - lons[i - 1] > maxGap) {
        maxGap = lons[i] - lons[i - 1];
        lonGapPos = i;
      }
    }

    if (lonGapPos < 0 && latGapPos < 0) return [changes];
    const eps = 1e-8;
    return [
      changes
          .where((c) => lonGapPos >= 0
              ? c.location.longitude < lons[lonGapPos] - eps
              : c.location.latitude < lats[latGapPos] - eps)
          .toList(),
      changes
          .where((c) => lonGapPos >= 0
              ? c.location.longitude >= lons[lonGapPos] - eps
              : c.location.latitude >= lats[latGapPos] - eps)
          .toList(),
    ];
  }

  /// Split changes into boxes with a minimum gap between them.
  List<List<OsmChange>> splitChanges(List<OsmChange> changes,
      {double minGap = 0.05}) {
    final result = [changes];
    bool didSplit = true;
    while (didSplit) {
      didSplit = false;
      final newParts = <List<OsmChange>>[];
      for (int i = 0; i < result.length; i++) {
        final split = _splitSingleChangeGroup(result[i], minGap);
        if (split.length > 1) {
          result[i] = split.first;
          newParts.add(split.last);
          didSplit = true;
        }
      }
      result.addAll(newParts);
    }
    return result;
  }
}
