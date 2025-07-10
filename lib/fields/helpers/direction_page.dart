import 'dart:math' as math;
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/widgets/pin_marker.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:latlong2/latlong.dart' show LatLng;

class DirectionValuePage extends ConsumerStatefulWidget {
  final LatLng location;
  final String? value;

  const DirectionValuePage(this.location, this.value);

  @override
  ConsumerState<DirectionValuePage> createState() => _DirectionValuePageState();
}

class _DirectionValuePageState extends ConsumerState<DirectionValuePage> {
  static const kMinRadius = 30.0;

  final controller = MapController();
  final _gdKey = GlobalKey();
  double? direction;
  int fov = 0;

  @override
  void initState() {
    super.initState();
    _initFields(widget.value);
    // This is a hack. Since the arrow translation depends on knowing the
    // size of the gesture detector container, it is initially offset,
    // because sizes are not yet known. I force redrawing widgets on the
    // second frame, and everything is fine then.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  void _initFields(String? value) {
    fov = 0;
    direction = null;
    if (value != null) {
      value = value.trim();
      final negative = value.startsWith('-');
      if (negative) value = value.substring(1);
      final parts = value
          .split('-')
          .map((p) => _parseDirectionValue(p))
          .whereType<double>()
          .toList();
      if (parts.isNotEmpty && negative) parts.first = -parts.first;
      if (parts.length == 1)
        direction = parts.first;
      else if (parts.length == 2) {
        direction = (parts.first + parts.last) / 2.0;
        fov = (parts.last - parts.first).abs().round();
      }
      if (direction != null) {
        direction = direction! + ref.read(rotationProvider);
      }
    }
  }

  double? _parseDirectionValue(String value) {
    value = value.trim().toUpperCase();
    if (value.isEmpty) return null;
    if (value == 'N' || value == 'NORTH') return 0;
    if (value == 'NE') return 45;
    if (value == 'E' || value == 'EAST') return 90;
    if (value == 'SE') return 135;
    if (value == 'S' || value == 'SOUTH') return 180;
    if (value == 'SW') return 225;
    if (value == 'W' || value == 'WEST') return 270;
    if (value == 'NW') return 315;
    return double.tryParse(value);
  }

  int _clamp(double d) => (d.round() + 720) % 360;

  String? _getAngle() {
    double? d = direction;
    if (d == null) return null;
    d -= ref.read(rotationProvider);
    if (fov == 0) return _clamp(d).toString();
    final d1 = d - fov / 2.0;
    return '${_clamp(d1)}-${_clamp(d1 + fov)}';
  }

  void updateDirection(Offset localPosition) {
    final bounds = _gdKey.currentContext!.findRenderObject()!.paintBounds;
    final d = bounds.center - localPosition;
    final r = d.distance;
    setState(() {
      if (r < kMinRadius) {
        direction = null;
      } else {
        final angle = d.direction - math.pi / 2.0;
        direction = (angle / math.pi * 180.0).roundToDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final isOSM = imagery == ref.watch(baseImageryProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chooseLocation),
        actions: [
          if (widget.value != null)
            IconButton(
              onPressed: () {
                Navigator.pop(context, '-');
              },
              icon: Icon(Icons.delete),
              tooltip: loc.fieldHoursClear,
            ),
          IconButton(
            onPressed: () {
              setState(() {
                ref.read(selectedImageryProvider.notifier).toggle();
              });
            },
            icon: Icon(isOSM ? Icons.map_outlined : Icons.map),
            tooltip: loc.navImagery,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller,
            options: MapOptions(
              initialCenter: widget.location,
              initialZoom: 19.0,
              minZoom: 17.0,
              maxZoom: 20.0,
              initialRotation: ref.watch(rotationProvider),
              interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              imagery.buildLayer(reset: true),
              ...ref.watch(overlayImageryProvider),
              AttributionWidget(imagery),
              LocationMarkerWidget(),
              if (direction == null)
                MarkerLayer(
                  markers: [PinMarker(widget.location)],
                ),
            ],
          ),
          if (direction != null)
            DirectionArrow(
              direction: direction!,
              fov: fov,
              color: isOSM ? Colors.black : Colors.yellow,
              size: _gdKey.currentContext?.findRenderObject()?.paintBounds.size,
            ),
          GestureDetector(
            key: _gdKey,
            behavior: HitTestBehavior.opaque,
            onPanDown: (e) {
              updateDirection(e.localPosition);
            },
            onPanUpdate: (e) {
              updateDirection(e.localPosition);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _getAngle());
        },
      ),
    );
  }
}

class DirectionArrow extends StatelessWidget {
  final double direction;
  final int fov;
  final Color color;
  final Size? size;

  const DirectionArrow(
      {required this.direction,
      this.fov = 0,
      this.color = Colors.yellow,
      this.size});

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? MediaQuery.of(context).size;
    final arrowLength = size.shortestSide / 2.0 - 20;
    final angle = direction / 180.0 * math.pi;
    return Transform.translate(
      offset: Offset(size.width / 2.0 - 15.0, size.height / 2.0 - arrowLength),
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: CustomPaint(
          size: Size(30.0, arrowLength),
          painter: ArrowPainter(fov: fov, color: color),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final int fov;
  final Color color;

  const ArrowPainter({this.fov = 0, this.color = Colors.yellow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final wingLevel = size.width;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2, 0)
      ..moveTo(0, wingLevel)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, wingLevel);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ArrowPainter || oldDelegate.fov != fov;
  }
}
