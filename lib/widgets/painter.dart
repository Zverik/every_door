import 'package:every_door/helpers/draw_style.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class PainterWidget extends StatefulWidget {
  final Function(List<Offset>) onDrawn;
  final DrawingStyle style;

  const PainterWidget({Key? key, required this.style, required this.onDrawn})
      : super(key: key);

  @override
  State<PainterWidget> createState() => _PainterWidgetState();
}

class _PainterWidgetState extends State<PainterWidget> {
  final List<Offset> _offsets = [];

  Offset _parseLocation(BuildContext context, Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(globalPosition);
  }

  List<Offset> _simplifiedOffsets() {
    // TODO: simplification algorithm
    return _offsets;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _offsets.clear();
          _offsets.add(_parseLocation(context, details.globalPosition));
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _offsets.add(_parseLocation(context, details.globalPosition));
        });
      },
      onPanEnd: (details) {
        if (_offsets.length >= 2) widget.onDrawn(_simplifiedOffsets());
        setState(() {
          _offsets.clear();
        });
      },
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
    paint.strokeCap = StrokeCap.butt;

    final path = Path();
    path.moveTo(_offsets.first.dx, _offsets.first.dy);
    for (int i = 1; i < _offsets.length; i++)
      path.lineTo(_offsets[i].dx, _offsets[i].dy);
    canvas.drawPath(
        _style.dashed
            ? dashPath(path, dashArray: CircularIntervalList([10.0, 6.0]))
            : path,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  // oldDelegate is! LineDrawer ||
  // _offsets.length != oldDelegate._offsets.length;
}
