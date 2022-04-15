import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class MapDragCreateOptions extends LayerOptions {
  List<DragButton> buttons;
  MapDragCreateOptions({this.buttons = const []});
}

class DragButton {
  final IconData icon;
  final Function()? onDragStart;
  final Function(LatLng)? onDragEnd;
  final Function()? onTap;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  DragButton({
    required this.icon,
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
          for (final btn in options.buttons) DragButtonsWidget(btn, mapState),
        ],
      );
    }
    throw Exception('Unknown layer options type: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) => options is MapDragCreateOptions;
}

class _DragButtonTargetLayer extends StatelessWidget {
  final MapState _mapState;

  const _DragButtonTargetLayer(this._mapState);

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragButton>(
      builder: (context, accepted, rejected) {
        return Container(
          color: Colors.yellow.withOpacity(0.2),
        );
      },
      onAcceptWithDetails: (details) {
        final pos = CustomPoint(details.offset.dx, details.offset.dy);
        final origin = _mapState.getPixelOrigin();
        final location = _mapState.layerPointToLatLng(pos + origin);
        if (details.data.onDragEnd != null) details.data.onDragEnd!(location);
      },
    );
  }
}

class DragButtonsWidget extends StatelessWidget {
  final DragButton options;
  final MapState _mapState;

  const DragButtonsWidget(this.options, this._mapState);

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
          const offset = CustomPoint(-arrowSize / 2, 87.0);
          final pos = CustomPoint(details.offset.dx, details.offset.dy);
          final origin = _mapState.getPixelOrigin();
          final location = _mapState.layerPointToLatLng(pos - offset + origin);
          if (options.onDragEnd != null) options.onDragEnd!(location);
        },
        feedbackOffset: Offset(arrowSize / 2, 70.0),
        dragAnchorStrategy: (draggable, context, position) =>
            Offset(arrowSize / 2, 70.0),
        feedback: CustomPaint(
          painter: _ArrowUpPainter(),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = size.longestSide / 10.0
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final wingLevel = size.width / 2;
    final path = Path()
      ..moveTo(size.width / 2, size.height / 30)
      ..lineTo(size.width / 2, size.height)
      ..moveTo(0, wingLevel)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, wingLevel);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
