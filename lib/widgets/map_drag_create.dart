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
          const offset = CustomPoint(-arrowSize / 2, -2.0);
          final pos = CustomPoint(details.offset.dx, details.offset.dy);
          // To adjust offset, we need to know the location of everything.
          final mapOrigin =
              _mapKey?.currentContext!.findRenderObject()!.paintBounds.topLeft;
          final globalMapOriginTr = _mapKey?.currentContext!
              .findRenderObject()!
              .getTransformTo(null)
              .getTranslation();
          final globalMapOrigin = globalMapOriginTr == null
              ? CustomPoint(0.0, 0.0)
              : CustomPoint(globalMapOriginTr.x, globalMapOriginTr.y);
          _logger.info('Map origin: $mapOrigin, global: $globalMapOrigin, '
              'drop offset: ${pos - offset}, '
              'top: ${options.top}, bottom: ${options.bottom}.');
          final location = _pointToLatLng(pos - offset + globalMapOrigin);
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
            shape: CircleBorder(),
          ),
          onPressed: () {
            if (options.onTap != null) options.onTap!();
          },
        ),
      ),
    );
  }

  LatLng _pointToLatLng(CustomPoint localPoint) {
    final size = _mapState.originalSize!;

    final localPointCenterDistance =
        CustomPoint(size.x / 2, size.y / 2) - localPoint;
    final mapCenter = _mapState.project(_mapState.center);
    var point = mapCenter - localPointCenterDistance;

    if (_mapState.rotation != 0.0) {
      point = _rotatePoint(mapCenter, point, _mapState.rotationRad);
    }

    return _mapState.unproject(point);
  }

  CustomPoint<num> _rotatePoint(
      CustomPoint<num> mapCenter, CustomPoint<num> point, double rotationRad) {
    final m = Matrix4.identity()
      ..translate(mapCenter.x.toDouble(), mapCenter.y.toDouble())
      ..rotateZ(-rotationRad)
      ..translate(-mapCenter.x.toDouble(), -mapCenter.y.toDouble());

    final tp = MatrixUtils.transformPoint(
        m, Offset(point.x.toDouble(), point.y.toDouble()));

    return CustomPoint(tp.dx, tp.dy);
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
