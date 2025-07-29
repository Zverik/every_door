import 'dart:math' as m;

import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;

/// A tile is three integer numbers in a coat: (x, y) point and a zoom.
/// This class has service methods to convert from and to coordinates.
class Tile extends m.Point<int> {
  final int zoom;

  const Tile(super.x, super.y, this.zoom);

  Tile.fromPoint(m.Point<int> point, this.zoom) : super(point.x, point.y);

  /// Returns a list of tiles at [zoom] that this tile covers at a higher zoom.
  /// For example, for a tile (0, 0, 0) it can return four tiles at zoom 1:
  /// (0, 0, 1), (0, 1, 1), (1, 0, 1), and (1, 1, 1).
  ///
  /// Also works for a lower zoom, e.g. returns (1, 2, 2) for (3, 4, 3).
  List<Tile> subTiles([int? zoom]) {
    zoom ??= this.zoom + 1;
    if (zoom == this.zoom) return [this];

    if (zoom < this.zoom) {
      final factor = 1 << (this.zoom - zoom);
      return [Tile((x / factor).floor(), (y / factor).floor(), zoom)];
    }

    final factor = 1 << (zoom - this.zoom);
    final baseX = x * factor;
    final baseY = y * factor;

    return List.generate(factor, (i) => i)
        .expand((i) =>
            List.generate(factor, (j) => Tile(baseX + i, baseY + j, zoom!)))
        .toList();
  }

  LatLngBounds tileBounds() {
    return LatLngBounds(tileOrigin(), (this + m.Point(1, 1)).tileOrigin());
  }

  LatLng tileOrigin() => _tileOrigin(this, 1 << zoom);

  @override
  Tile operator +(m.Point<int> other) {
    return Tile(x + other.x, y + other.y, zoom);
  }

  @override
  bool operator ==(Object other) =>
      other is Tile && x == other.x && y == other.y && zoom == other.zoom;

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
    final y =
        ((1 - m.log(m.tan(lat) + 1 / m.cos(lat)) / m.pi) / 2 * zoom2).floor();
    return Tile(x.clamp(0, zoom2 - 1), y.clamp(0, zoom2 - 1), zoom);
  }

  LatLngBounds tileBounds(m.Point<int> tile) {
    return LatLngBounds(tileOrigin(tile), tileOrigin(tile + m.Point(1, 1)));
  }

  LatLng tileOrigin(m.Point<int> tile) => _tileOrigin(tile, zoom2);
}

LatLng _tileOrigin(m.Point<int> tile, int zoom2) {
  final lon0 = tile.x / zoom2 * 360.0 - 180.0;
  final n = m.pi - 2 * m.pi * tile.y / zoom2;
  final lat0 = 180 / m.pi * m.atan(0.5 * (m.exp(n) - m.exp(-n)));
  return LatLng(lat0, lon0);
}
