import 'dart:math' as m;

import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;

class Tile extends m.Point<int> {
  final int zoom;

  const Tile(super.x, super.y, this.zoom);

  Tile.fromPoint(m.Point<int> point, this.zoom) : super(point.x, point.y);

  LatLngBounds tileBounds() {
    return LatLngBounds(tileOrigin(), (this + m.Point(1, 1)).tileOrigin());
  }

  LatLng tileOrigin() {
    final zoom2 = 1 << zoom;
    final lon0 = x / zoom2 * 360.0 - 180.0;
    final n = m.pi - 2 * m.pi * y / zoom2;
    final lat0 = 180 / m.pi * m.atan(0.5 * (m.exp(n) - m.exp(-n)));
    return LatLng(lat0, lon0);
  }

  @override
  Tile operator +(m.Point<int> other) {
    return Tile(x + other.x, y + other.y, zoom);
  }

  @override
  bool operator ==(Object other) => other is Tile && x == other.x && y == other.y && zoom == other.zoom;

  @override
  int get hashCode => Object.hash(x, y, zoom);

  @override
  String toString() => 'Tile($x, $y, $zoom)';
}

class TileCalculator {
  final int zoom;
  final int zoom2;

  const TileCalculator(this.zoom) : zoom2 = 1 << zoom;

  Tile locationToTile(LatLng location) {
    final x = (((location.longitude + 180) / 360) * zoom2).floor();
    final lat = location.latitudeInRad;
    final y = ((1 - m.log(m.tan(lat) + 1 / m.cos(lat)) / m.pi) / 2 * zoom2).floor();
    return Tile(x.clamp(0, zoom2 - 1), y.clamp(0, zoom2 - 1), zoom);
  }

  LatLngBounds tileBounds(m.Point<int> tile) {
    return LatLngBounds(tileOrigin(tile), tileOrigin(tile + m.Point(1, 1)));
  }

  LatLng tileOrigin(m.Point<int> tile) {
    final lon0 = tile.x / zoom2 * 360.0 - 180.0;
    final n = m.pi - 2 * m.pi * tile.y / zoom2;
    final lat0 = 180 / m.pi * m.atan(0.5 * (m.exp(n) - m.exp(-n)));
    return LatLng(lat0, lon0);
  }
}