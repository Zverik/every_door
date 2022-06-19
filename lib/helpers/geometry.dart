import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;

class GeometryException implements Exception {
  final String message;

  const GeometryException(this.message);
}

abstract class Geometry {
  LatLngBounds get bounds;
  LatLng get center;
}

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

class LineString extends Geometry {
  final List<LatLng> _nodes;

  LineString(Iterable<LatLng> nodes) : _nodes = List.of(nodes) {
    if (_nodes.length < 2)
      throw GeometryException('A path must have at least two nodes.');
  }

  @override
  LatLngBounds get bounds => LatLngBounds.fromPoints(_nodes);

  @override
  // TODO: proper center on the line
  LatLng get center => bounds.center;

  @override
  String toString() => 'LineString($_nodes)';
}
