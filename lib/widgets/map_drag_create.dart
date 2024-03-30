import 'dart:math' show Point;

import 'package:every_door/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';

class DragButton {
  final IconData icon;
  final Color? color;
  final Function()? onDragStart;
  final Function(LatLng)? onDragEnd;
  final Function()? onTap;
  final String? tooltip;
  final Alignment alignment;
  final EdgeInsets padding;

  DragButton({
    required this.icon,
    this.color,
    this.onDragStart,
    this.onDragEnd,
    this.onTap,
    this.tooltip,
    this.alignment = Alignment.bottomRight,
    this.padding = EdgeInsets.zero,
  });
}

class DragButtonWidget extends StatelessWidget {
  final DragButton button;
  final GlobalKey? mapKey;

  static final _logger = Logger('DragButtonsWidget');

  const DragButtonWidget({required this.button, this.mapKey});

  @override
  Widget build(BuildContext context) {
    const arrowSize = 60.0;
    final camera = MapCamera.of(context);
    final safePadding =
        MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0);
    const commonPadding =
        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0);

    return Align(
      alignment: button.alignment,
      child: Padding(
        padding: button.padding + safePadding + commonPadding,
        child: Draggable(
          data: button,
          onDragStarted: () {
            if (button.onDragStart != null) button.onDragStart!();
          },
          onDragEnd: (details) {
            const offset = Point(-arrowSize / 2, -2.0);
            final pos = Point(details.offset.dx, details.offset.dy);
            // To adjust offset, we need to know the location of everything.
            final mapOrigin =
                mapKey?.currentContext!.findRenderObject()!.paintBounds.topLeft;
            final globalMapOriginTr = mapKey?.currentContext!
                .findRenderObject()!
                .getTransformTo(null)
                .getTranslation();
            final globalMapOrigin = globalMapOriginTr == null
                ? Point(0.0, 0.0)
                : Point(globalMapOriginTr.x, globalMapOriginTr.y);
            _logger.info('Map origin: $mapOrigin, global: $globalMapOrigin, '
                'drop offset: ${pos - offset}, padding: ${button.padding}.');
            final location =
                camera.pointToLatLng(pos - offset + globalMapOrigin);
            if (button.onDragEnd != null) button.onDragEnd!(location);
          },
          feedbackOffset: Offset(arrowSize / 2, 70.0),
          dragAnchorStrategy: (draggable, context, position) =>
              Offset(arrowSize / 2, 70.0),
          feedback: CustomPaint(
            painter:
                _ArrowUpPainter(button.color ?? Theme.of(context).primaryColor),
            size: Size(arrowSize, 100.0),
          ),
          childWhenDragging: Container(),
          child: RoundButton(
            icon: button.icon,
            tooltip: button.tooltip,
            onPressed: button.onTap,
          ),
        ),
      ),
    );
  }
}

class MapDragCreateButton extends StatelessWidget {
  final IconData icon;
  final Function()? onDragStart;
  final Function(LatLng)? onDragEnd;
  final Function()? onTap;
  final String? tooltip;
  final Alignment alignment;
  final MapController map;
  final GlobalKey? mapKey;

  static const kArrowSize = 60.0;
  static final _logger = Logger('MapDragCreateButton');

  const MapDragCreateButton({
    super.key,
    this.mapKey,
    required this.map,
    required this.icon,
    this.onDragStart,
    this.onDragEnd,
    this.onTap,
    this.tooltip,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final safePadding =
        MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0);
    const commonPadding =
        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: safePadding + commonPadding,
        child: Draggable(
          onDragStarted: () {
            if (onDragStart != null) onDragStart!();
          },
          onDragEnd: (details) {
            const offset = Point(-kArrowSize / 2, -2.0);
            final pos = Point(details.offset.dx, details.offset.dy);
            // To adjust offset, we need to know the location of everything.
            final globalMapOriginTr = mapKey?.currentContext!
                .findRenderObject()!
                .getTransformTo(null)
                .getTranslation();
            final globalMapOrigin = globalMapOriginTr == null
                ? Point(0.0, 0.0)
                : Point(globalMapOriginTr.x, globalMapOriginTr.y);
            _logger.info(
                'global: $globalMapOrigin, drop offset: ${pos - offset}.');
            final location =
                map.camera.pointToLatLng(pos - offset + globalMapOrigin);
            if (onDragEnd != null) onDragEnd!(location);
          },
          feedbackOffset: Offset(kArrowSize / 2, 70.0),
          dragAnchorStrategy: (draggable, context, position) =>
              Offset(kArrowSize / 2, 70.0),
          feedback: CustomPaint(
            painter: _ArrowUpPainter(Theme.of(context).primaryColor),
            size: Size(kArrowSize, 100.0),
          ),
          childWhenDragging: Container(),
          child: RoundButton(
            icon: icon,
            tooltip: tooltip,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

class _ArrowUpPainter extends CustomPainter {
  final Color color;

  _ArrowUpPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const kShiftDown = 8.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.longestSide / 10.0
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final wingLevel = size.width / 2 + kShiftDown;
    final path = Path()
      ..moveTo(size.width / 2, size.height / 30 + kShiftDown)
      ..lineTo(size.width / 2, size.height)
      ..moveTo(0, wingLevel)
      ..lineTo(size.width / 2, kShiftDown)
      ..lineTo(size.width, wingLevel);
    canvas.drawPath(path, paint);

    const kRedCircleRadius = 2.0;
    final redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width / 2, kRedCircleRadius), kRedCircleRadius, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
