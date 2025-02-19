import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';

class MapDragCreateButton extends StatelessWidget {
  final MultiIcon icon;
  final Function()? onDragStart;
  final Function(LatLng)? onDragEnd;
  final Function()? onTap;
  final Alignment alignment;
  final CustomMapController map;

  static const kArrowSize = 60.0;
  static final _logger = Logger('MapDragCreateButton');

  const MapDragCreateButton({
    super.key,
    required this.map,
    required this.icon,
    this.onDragStart,
    this.onDragEnd,
    this.onTap,
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
            const offset = Offset(-kArrowSize / 2, -2.0);
            final pos = Offset(details.offset.dx, details.offset.dy);
            // To adjust offset, we need to know the location of everything.
            final globalMapOriginTr = map.mapKey?.currentContext!
                .findRenderObject()!
                .getTransformTo(null)
                .getTranslation();
            final globalMapOrigin = globalMapOriginTr == null
                ? Offset(0.0, 0.0)
                : Offset(globalMapOriginTr.x, globalMapOriginTr.y);
            _logger.info(
                'global: $globalMapOrigin, drop offset: ${pos - offset}.');
            final location = map.mapController?.camera
                .offsetToCrs(pos - offset + globalMapOrigin);
            if (onDragEnd != null && location != null) onDragEnd!(location);
          },
          feedbackOffset: Offset(kArrowSize / 2, 70.0),
          dragAnchorStrategy: (draggable, context, position) =>
              Offset(kArrowSize / 2, 70.0),
          feedback: CustomPaint(
            painter: _ArrowUpPainter(Theme.of(context).primaryColor),
            size: Size(kArrowSize, 100.0),
          ),
          childWhenDragging: Container(),
          child: RoundButton(icon: icon, onPressed: onTap),
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
