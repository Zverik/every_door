// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:math' show Point;

import 'package:every_door/helpers/geometry/tile_range.dart';
import 'package:every_door/helpers/tile_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_drawing/path_drawing.dart';

class TileBoundsGrid extends StatefulWidget {
  final int tileZoom;
  final Color color;
  final Map<Point<int>, Color> fill;
  final Function(Tile, bool)? onTap;

  const TileBoundsGrid({
    super.key,
    required this.tileZoom,
    this.color = Colors.black,
    this.fill = const {},
    this.onTap,
  });

  @override
  State<TileBoundsGrid> createState() => _TileBoundsGridState();
}

class _TileBoundsGridState extends State<TileBoundsGrid> {
  int get stopZoom => widget.tileZoom - 3;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final calc = TileCalculator(widget.tileZoom);

    final bounds = DiscreteTileRange(
      widget.tileZoom,
      calc.locationToTile(camera.visibleBounds.northWest),
      calc.locationToTile(camera.visibleBounds.southEast),
    );

    final Offset boundsMin =
        camera.latLngToScreenOffset(calc.tileOrigin(bounds.min));
    final Offset step =
        camera.latLngToScreenOffset(calc.tileOrigin(bounds.min + Point(1, 1))) -
            boundsMin;

    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTapUp: (details) {
        final location = MapCamera.of(context).screenOffsetToLatLng(details.localPosition);
        final tile = TileCalculator(widget.tileZoom).locationToTile(location);
        if (widget.onTap != null) widget.onTap!(tile, !widget.fill.containsKey(tile));
      },
      child: Stack(
        children: [
          for (final tile in widget.fill.entries)
            TileFill(
              tile: tile.key,
              color: tile.value,
              calculator: calc,
            ),
          if (camera.zoom > stopZoom)
            RepaintBoundary(
              child: Container(
                color: Colors.transparent,
                width: size.width,
                height: size.height,
                child: CustomPaint(
                  painter: GridLinePainter(
                    color: widget.color,
                    xs: List.generate(
                            bounds.width + 1, (i) => boundsMin.dx + i * step.dx)
                        .toList(),
                    ys: List.generate(bounds.height + 1,
                        (i) => boundsMin.dy + i * step.dy).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension OffsetExtension on Offset {
  Offset floor() => Offset(dx.floorToDouble(), dy.floorToDouble());
}

class GridLinePainter extends CustomPainter {
  final Color color;
  final List<double> xs;
  final List<double> ys;

  const GridLinePainter({
    required this.color,
    required this.xs,
    required this.ys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.color = color;
    paint.strokeWidth = 1;
    paint.strokeJoin = StrokeJoin.round;
    paint.strokeCap = StrokeCap.round;
    // final dashes = CircularIntervalList([10.0, 13.0]);
    final dashes = CircularIntervalList([3.0, 3.0]);

    for (final x in xs) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
      canvas.drawPath(dashPath(path, dashArray: dashes), paint);
    }

    for (final y in ys) {
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width, y);
      canvas.drawPath(dashPath(path, dashArray: dashes), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TileFill extends StatelessWidget {
  final Point<int> tile;
  final Color color;
  final TileCalculator calculator;

  const TileFill({
    required this.tile,
    required this.color,
    required this.calculator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final bounds = calculator.tileBounds(tile);
    final c1 = camera.latLngToScreenOffset(bounds.northWest);
    final c2 = camera.latLngToScreenOffset(bounds.southEast);
    return Positioned(
      left: c1.dx,
      top: c1.dy,
      width: c2.dx - c1.dx,
      height: c2.dy - c1.dy,
      child: Container(
        color: color,
      ),
    );
  }
}
