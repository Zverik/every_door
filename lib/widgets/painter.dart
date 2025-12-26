// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:math' as math;

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:every_door/helpers/geometry/simplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';
import 'package:path_drawing/path_drawing.dart';

class PainterWidget extends StatefulWidget {
  final Function(List<LatLng>) onDrawn;
  final Function(LatLng)? onTap;
  final Function()? onMapMove;
  final DrawingStyle style;
  final MapController map;

  const PainterWidget(
      {super.key,
      required this.style,
      required this.onDrawn,
      this.onTap,
      this.onMapMove,
      required this.map});

  @override
  State<PainterWidget> createState() => _PainterWidgetState();
}

class _PainterWidgetState extends State<PainterWidget> {
  static const kSimplifyTolerance = 1.0;

  final List<Offset> _offsets = [];
  bool drawing = false;
  int pointers = 0;

  static final _logger = Logger('PainterWidget');

  LatLng _coordFromOffset(Offset offset) =>
      widget.map.camera.offsetToCrs(offset);

  void _stopDrawing() {
    if (drawing || _offsets.isNotEmpty) {
      setState(() {
        drawing = false;
        _offsets.clear();
      });
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    pointers += 1;
    if (pointers == 1) {
      setState(() {
        drawing = true;
        _offsets.clear();
        _offsets.add(event.localPosition);
      });
    } else {
      _stopDrawing();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    pointers -= 1;
    if (drawing && _offsets.length >= 2) {
      // Yay we have drawn something!
      double tolerance = kSimplifyTolerance;
      List<Offset> offsets;
      do {
        offsets = simplifyOffsets(_offsets, tolerance, true);
        tolerance += 1;
      } while (offsets.length > kDrawingMaxPoints);
      final coords = offsets.map((o) => _coordFromOffset(o)).toList();
      final length = LineString(coords).getLengthInMeters();
      if (length <= kDrawingMaxLength) {
        widget.onDrawn(coords);
      } else {
        _logger.warning(
            'Drawn a line of ${coords.length} points and $length meters, too long.');
      }
    }
    _stopDrawing();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!drawing) return;
    setState(() {
      if (_offsets.isEmpty || _offsets.last != event.localPosition)
        _offsets.add(event.localPosition);
    });
  }

  void _onPointerCancel(PointerCancelEvent event) {
    pointers -= 1;
    _logger.info('Pointer cancelled? $pointers');
    _stopDrawing();
  }

  void _handleTap(TapUpDetails details) {
    _stopDrawing();
    final loc = _coordFromOffset(details.localPosition);
    _logger.info('Tap detected at $loc');
    if (widget.onTap != null) {
      widget.onTap!(loc);
    }
  }

  late double _mapZoomStart;
  late Offset _focalStartLocal;
  late Offset _lastFocalLocal;
  late LatLng _focalStartLatLng;
  bool _isMultifinger = false;

  void _onScaleStart(ScaleStartDetails details) {
    _isMultifinger = details.pointerCount == 2;
    if (!_isMultifinger) return;
    _stopDrawing();

    _mapZoomStart = widget.map.camera.zoom;
    _focalStartLocal = _lastFocalLocal = details.localFocalPoint;
    _focalStartLatLng = widget.map.camera.offsetToCrs(_focalStartLocal);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isMultifinger) return;

    var newZoom = widget.map.camera.zoom;
    if (details.scale > 0.0) {
      final resultZoom = _mapZoomStart + math.log(details.scale) / math.ln2;
      newZoom = widget.map.camera.clampZoom(resultZoom);
    }

    final newCenter = _calculatePinchZoomAndMove(details, newZoom);
    widget.map.move(newCenter, newZoom);
    _lastFocalLocal = details.localFocalPoint;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_isMultifinger && widget.onMapMove != null) widget.onMapMove!();
    _isMultifinger = false;
  }

  // Yup, the next two functions are from flutter_map.
  LatLng _calculatePinchZoomAndMove(
    ScaleUpdateDetails details,
    double zoomAfterPinchZoom,
  ) {
    final camera = widget.map.camera;
    final oldCenterPt = camera.projectAtZoom(camera.center, zoomAfterPinchZoom);
    final newFocalLatLong =
        camera.offsetToCrs(_focalStartLocal, zoomAfterPinchZoom);
    final newFocalPt = camera.projectAtZoom(newFocalLatLong, zoomAfterPinchZoom);
    final oldFocalPt = camera.projectAtZoom(_focalStartLatLng, zoomAfterPinchZoom);
    final zoomDifference = oldFocalPt - newFocalPt;
    final moveDifference = _rotateOffset(_focalStartLocal - _lastFocalLocal);

    final newCenterPt = oldCenterPt + zoomDifference + moveDifference;
    return camera.unprojectAtZoom(newCenterPt, zoomAfterPinchZoom);
  }

  Offset _rotateOffset(Offset offset) {
    final radians = widget.map.camera.rotationRad;
    if (radians != 0.0) {
      final cos = math.cos(radians);
      final sin = math.sin(radians);
      final nx = (cos * offset.dx) + (sin * offset.dy);
      final ny = (cos * offset.dy) - (sin * offset.dx);

      return Offset(nx, ny);
    }

    return offset;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTapUp: _handleTap,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: RepaintBoundary(
          child: Container(
            color: Colors.transparent,
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: LineDrawer(_offsets, widget.style),
            ),
          ),
        ),
      ),
    );
  }
}

class LineDrawer extends CustomPainter {
  final List<Offset> _offsets;
  final DrawingStyle _style;

  const LineDrawer(this._offsets, this._style);

  @override
  void paint(Canvas canvas, Size size) {
    if (_offsets.length < 2) return;
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.color = _style.color;
    paint.strokeWidth = _style.stroke;
    paint.strokeJoin = StrokeJoin.round;
    paint.strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(_offsets.first.dx, _offsets.first.dy);
    for (int i = 1; i < _offsets.length; i++)
      path.lineTo(_offsets[i].dx, _offsets[i].dy);
    canvas.drawPath(
        _style.dashed
            ? dashPath(path, dashArray: CircularIntervalList([10.0, 13.0]))
            : path,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  // oldDelegate is! LineDrawer ||
  // _offsets.length != oldDelegate._offsets.length;
}
