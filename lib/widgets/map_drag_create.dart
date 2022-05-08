import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';

class MapDragCreateOptions extends LayerOptions {
  List<DragButton> buttons;
  GlobalKey? mapKey;
  MapDragCreateOptions({this.buttons = const [], this.mapKey});
}

class DragButton {
  final IconData icon;
  final Color? color;
  final Function()? onDragStart;
  final Function(LatLng)? onDragEnd;
  final Function()? onTap;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  DragButton({
    required this.icon,
    this.color,
    this.onDragStart,
    this.onDragEnd,
    this.onTap,
    this.top,
    this.bottom,
    this.left,
    this.right,
  }) {
    if (left == null && right == null)
      throw Exception('Please specify left or right for a button');
    if (left != null && right != null)
      throw Exception('Please specify either left or right for a button');
    if (top == null && bottom == null)
      throw Exception('Please specify top or bottom for a button');
    if (bottom != null && top != null)
      throw Exception('Please specify either top or bottom for a button');
  }
}

class MapDragCreatePlugin implements MapPlugin {
  @override
  Widget createLayer(LayerOptions options, MapState mapState, Stream stream) {
    if (options is MapDragCreateOptions) {
      return Stack(
        children: [
          // DragButtonTargetLayer(mapState),
          for (final btn in options.buttons)
            DragButtonsWidget(btn, mapState, options.mapKey),
        ],
      );
    }
    throw Exception('Unknown layer options type: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) => options is MapDragCreateOptions;
}

class DragButtonsWidget extends StatelessWidget {
  final DragButton options;
  final MapState _mapState;
  final GlobalKey? _mapKey;

  static final _logger = Logger('DragButtonsWidget');

  const DragButtonsWidget(this.options, this._mapState, this._mapKey);

  @override
  Widget build(BuildContext context) {
    const arrowSize = 60.0;
    return Positioned(
      left: options.left,
      right: options.right,
      top: options.top,
      bottom: options.bottom,
      child: Draggable(
        data: options,
        onDragStarted: () {
          if (options.onDragStart != null) options.onDragStart!();
        },
        onDragEnd: (details) {
          const offset = CustomPoint(-arrowSize / 2, 82.0); // 82 or 128?
          final pos = CustomPoint(details.offset.dx, details.offset.dy);
          final origin = _mapState.getPixelOrigin();
          final mapOrigin =
              _mapKey?.currentContext!.findRenderObject()!.paintBounds.topLeft;
          final globalMapOrigin = _mapKey?.currentContext!
              .findRenderObject()!
              .getTransformTo(null)
              .getTranslation();
          _logger.info(
              'Map origin: $mapOrigin, global: ${globalMapOrigin?.x}, '
              '${globalMapOrigin?.y}, drop offset: ${pos - offset}, '
              'top: ${options.top}, bottom: ${options.bottom}.');
          final location = _mapState.layerPointToLatLng(pos - offset + origin);
          if (options.onDragEnd != null) options.onDragEnd!(location);
        },
        feedbackOffset: Offset(arrowSize / 2, 70.0),
        dragAnchorStrategy: (draggable, context, position) =>
            Offset(arrowSize / 2, 70.0),
        feedback: CustomPaint(
          painter:
              _ArrowUpPainter(options.color ?? Theme.of(context).primaryColor),
          size: Size(arrowSize, 100.0),
        ),
        childWhenDragging: Container(),
        child: ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 15.0,
            ),
            child: Icon(options.icon, size: 30.0),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () {
            if (options.onTap != null) options.onTap!();
          },
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
