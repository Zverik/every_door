import 'dart:math' show Point;

import 'package:every_door/helpers/tile_calculator.dart';
import 'package:flutter_map/flutter_map.dart'
    show TileCoordinates, LatLngBounds;

class DiscreteTileRange {
  /// Bounds are inclusive
  final Point<int> min;
  final Point<int> max;
  final int zoom;

  const DiscreteTileRange._(this.zoom, this.min, this.max);

  factory DiscreteTileRange(int zoom, Point<int> a, Point<int> b) {
    final int minX;
    final int maxX;
    if (a.x > b.x) {
      minX = b.x;
      maxX = a.x;
    } else {
      minX = a.x;
      maxX = b.x;
    }
    final int minY;
    final int maxY;
    if (a.y > b.y) {
      minY = b.y;
      maxY = a.y;
    } else {
      minY = a.y;
      maxY = b.y;
    }
    return DiscreteTileRange._(
        zoom, Point<int>(minX, minY), Point<int>(maxX, maxY));
  }

  factory DiscreteTileRange.fromBounds(int zoom, LatLngBounds bounds) {
    final calc = TileCalculator(zoom);
    final c1 = calc.locationToTile(bounds.northWest);
    final c2 = calc.locationToTile(bounds.southEast);
    return DiscreteTileRange(zoom, c1, c2);
  }

  int get width => max.x - min.x + 1;
  int get height => max.y - min.y + 1;
  int get count => width * height;

  LatLngBounds toBounds() {
    final calc = TileCalculator(zoom);
    return LatLngBounds(
      calc.tileOrigin(min),
      calc.tileOrigin(max + Point(1, 1)),
    );
  }

  Iterable<TileCoordinates> get coordinates sync* {
    for (var j = min.y; j <= max.y; j++) {
      for (var i = min.x; i <= max.x; i++) {
        yield TileCoordinates(i, j, zoom);
      }
    }
  }

  Iterable<Tile> get tiles sync* {
    for (var j = min.y; j <= max.y; j++) {
      for (var i = min.x; i <= max.x; i++) {
        yield Tile(i, j, zoom);
      }
    }
  }

  @override
  String toString() => 'DiscreteTileRange($min, $max)';
}
