// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:math' show sqrt, pow;

import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;

@Bind()
class GeometryException implements Exception {
  final String message;

  const GeometryException(this.message);
}

@Bind()
abstract class Geometry {
  LatLngBounds get bounds;
  LatLng get center;
}

@Bind()
class Polygon extends Geometry {
  final List<LatLng> _nodes;

  Polygon(Iterable<LatLng> nodes) : _nodes = List.of(nodes) {
    if (_nodes.isNotEmpty && _nodes.last == _nodes.first) _nodes.removeLast();
    if (_nodes.length < 3)
      throw GeometryException('A polygon must have at least three nodes.');
  }

  @override
  LatLngBounds get bounds => LatLngBounds.fromPoints(_nodes);

  @override
  LatLng get center => LatLng(
      (bounds.south + bounds.north) / 2, (bounds.west + bounds.east) / 2);

  bool contains(LatLng point) {
    if (!bounds.contains(point)) return false;
    final intersections = _intersectionLongitudes(point.latitude);
    assert(intersections.isNotEmpty);
    if (intersections.contains(point.longitude)) return true;
    final count = intersections.where((x) => x < point.longitude).length;
    // if (point == LatLng(1.5, 2.4))
    //   print('for 2.4, intersections: $intersections');
    return count % 2 == 1;
  }

  bool containsPolygon(Polygon poly) {
    if (!bounds.containsBounds(poly.bounds)) return false;
    for (final p in poly._nodes) if (!contains(p)) return false;
    // TODO: check that vertices do not intersect.
    return true;
  }

  LatLng findPointOnSurface() {
    final c = center;
    final lat = c.latitude;
    final intersections = _intersectionLongitudes(lat);
    assert(intersections.isNotEmpty);

    // First check if the polygon contains its center.
    if (!intersections.contains(c.longitude)) {
      final count = intersections.where((x) => x < c.longitude).length;
      if (count % 2 == 1) return c;
    }

    // If center is outside the polygon, find a point inside.
    intersections.sort();
    double lon = intersections.first;
    double len = 0.0;
    for (int i = 0; i + 1 < intersections.length; i += 2) {
      final slen = intersections[i + 1] - intersections[i];
      if (slen > len) {
        len = slen;
        lon = (intersections[i + 1] + intersections[i]) / 2;
      }
    }
    return LatLng(lat, lon);
  }

  List<double> _intersectionLongitudes(double latitude) {
    final xs = <double>[];
    final indexes = <int>[];
    for (int i = 0; i < _nodes.length; i++) {
      final prev = i > 0 ? i - 1 : _nodes.length - 1;
      final x1 = _nodes[prev].longitude;
      final y1 = _nodes[prev].latitude;
      final x2 = _nodes[i].longitude;
      final y2 = _nodes[i].latitude;
      if (y1 == latitude) {
        xs.add(x1);
        final prev0 = prev == 0 ? _nodes.length - 1 : prev - 1;
        final y0 = _nodes[prev0].latitude;
        // For the bottom of the rhombus, add it the second time.
        if ((y2 > latitude) == (y0 > latitude)) xs.add(x1);
        // TODO: fails on y2 == lat or y0 == lat.
      }
      // NB: (x2, y2) is not included
      if (y1 != latitude && y2 != latitude) {
        if ((y1 > latitude) != (y2 > latitude)) {
          final d = (x2 - x1) / (y2 - y1);
          xs.add(d * (latitude - y1) + x1);
          indexes.add(i);
        }
      }
    }
    assert(xs.length % 2 == 0);
    return xs;
  }

  @override
  String toString() => 'Polygon($_nodes)';
}

@Bind()
class Envelope implements Polygon {
  final LatLngBounds _bounds;

  const Envelope(this._bounds);

  @override
  List<double> _intersectionLongitudes(double latitude) {
    throw UnimplementedError();
  }

  @override
  List<LatLng> get _nodes => throw UnimplementedError();

  @override
  LatLngBounds get bounds => _bounds;

  @override
  LatLng get center => LatLng(
      (bounds.south + bounds.north) / 2, (bounds.west + bounds.east) / 2);

  @override
  bool contains(LatLng point) => _bounds.contains(point);

  @override
  bool containsPolygon(Polygon poly) => _bounds.containsBounds(poly.bounds);

  @override
  LatLng findPointOnSurface() => center;

  @override
  String toString() => 'Envelope(${_bounds.southWest}, ${_bounds.northEast})';
}

@Bind()
class MultiPolygon implements Polygon {
  final List<Polygon> outer = [];
  final List<Polygon> inner = [];

  MultiPolygon(Iterable<Polygon> polygons) {
    // TODO: sort
    outer.addAll(polygons);
  }

  @override
  LatLngBounds get bounds => LatLngBounds.fromPoints([
        for (final p in outer) ...[p.bounds.northWest, p.bounds.southEast]
      ]);

  @override
  LatLng get center => LatLng(
      (bounds.south + bounds.north) / 2, (bounds.west + bounds.east) / 2);

  @override
  bool contains(LatLng point) {
    return outer.any((p) => p.contains(point)) &&
        !inner.any((p) => p.contains(point));
  }

  @override
  LatLng findPointOnSurface() {
    // TODO: implement findPointOnSurface
    throw UnimplementedError();
  }

  @override
  List<LatLng> get _nodes => throw UnimplementedError();

  @override
  List<double> _intersectionLongitudes(double latitude) {
    throw UnimplementedError();
  }

  @override
  bool containsPolygon(Polygon poly) {
    if (!outer.any((element) => element.containsPolygon(poly))) return false;
    // Welp, not going to do a proper implementation
    throw UnimplementedError();
  }

  @override
  String toString() =>
      'MultiPolygon(${outer.length} outer, ${inner.length} inner)';
}

@Bind()
class LineString extends Geometry {
  final List<LatLng> nodes;
  LatLngBounds? _cachedBounds;

  LineString(Iterable<LatLng> nodes) : nodes = List.of(nodes, growable: false) {
    if (this.nodes.length < 2)
      throw GeometryException('A path must have at least two nodes.');
  }

  @override
  LatLngBounds get bounds {
    _cachedBounds ??= LatLngBounds.fromPoints(nodes);
    return _cachedBounds!;
  }

  @override
  // TODO: proper center on the line
  LatLng get center => bounds.center;

  double getLengthInMeters() {
    double length = 0.0;
    final distance = DistanceEquirectangular();
    for (int i = 1; i < nodes.length; i++) {
      length += distance(nodes[i - 1], nodes[i]);
    }
    return length;
  }

  LatLng closestPoint(LatLng point) {
    num minDist = double.infinity;
    LatLng point = nodes[0];

    for (int i = 1; i < nodes.length; i++) {
      final x = point.longitude;
      final y = point.latitude;
      final x1 = nodes[i - 1].longitude;
      final y1 = nodes[i - 1].latitude;
      final x2 = nodes[i].longitude;
      final y2 = nodes[i].latitude;
      final dx = x2 - x1;
      final dy = y2 - y1;

      final dot = (x - x1) * dx + (y - y1) * dy;
      final len = dx * dx + dy * dy;
      double t = -1;
      if (len > 0.0) t = dot / len;

      double ix;
      double iy;
      if (t <= 0)
        (ix, iy) = (x1, y1);
      else if (t >= 1)
        (ix, iy) = (x2, y2);
      else
        (ix, iy) = (x1 + t * dx, y1 + t * dy);

      final d = pow(x - ix, 2) + pow(y - iy, 2);
      if (d < minDist) {
        minDist = d;
        point = LatLng(iy, ix);
      }
    }

    return point;
  }

  double distanceToPoint(LatLng point, {bool inMeters = true}) {
    // I am lazy hence this is a StackOverflow-inspired code.
    final closest = closestPoint(point);
    if (inMeters) {
      final distance = DistanceEquirectangular();
      return distance(point, closest);
    } else {
      return sqrt(pow(point.longitude - closest.longitude, 2) +
          pow(point.latitude - closest.latitude, 2));
    }
  }

  bool _segmentsIntersect(LatLng a1, LatLng a2, LatLng b1, LatLng b2) {
    // Copied from https://stackoverflow.com/a/24392281/1297601
    final a = a1.longitude;
    final b = a1.latitude;
    final c = a2.longitude;
    final d = a2.latitude;
    final p = b1.longitude;
    final q = b1.latitude;
    final r = b2.longitude;
    final s = b2.latitude;

    double det, gamma, lambda;
    det = (c - a) * (s - q) - (r - p) * (d - b);
    if (det == 0) {
      return false;
    } else {
      lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det;
      gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det;
      return (0 <= lambda && lambda <= 1) && (0 <= gamma && gamma <= 1);
    }
  }

  bool intersects(LineString other) {
    if (!bounds.isOverlapping(other.bounds)) return false;
    for (int i = 1; i < nodes.length; i++) {
      // Iterating over segments.
      for (int j = 1; j < other.nodes.length; j++) {
        // Iterating over other line segments. Yes, O(n²).
        if (_segmentsIntersect(
            nodes[i - 1], nodes[i], other.nodes[j - 1], other.nodes[j]))
          return true;
      }
    }
    return false;
  }

  @override
  String toString() => 'LineString($nodes)';
}
