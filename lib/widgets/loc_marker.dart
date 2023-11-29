import 'package:every_door/providers/compass.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'dart:math' show pi;

class LocationMarkerWidget extends ConsumerWidget {
  final bool tracking;

  LocationMarkerWidget({super.key, this.tracking = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    if (trackLocation == null) return Container();

    final CompassData? compass = null; // ref.watch(compassProvider);
    final bool isTracking = tracking && ref.watch(trackingProvider);
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _LocationMarkerPainter(
          border: isTracking,
          offset: MapCamera.of(context).getOffsetFromOrigin(trackLocation),
          heading: compass?.heading,
        ),
        // TODO: check that it's still painted
        // size: Size(constraints.maxWidth, constraints.maxHeight),
      ),
    );
  }
}

class _LocationMarkerPainter extends CustomPainter {
  final bool border;
  final Offset offset;
  final double? heading;

  static final kMarkerColor = Colors.blue.withOpacity(0.4);
  static final kBorderColor = Colors.black.withOpacity(0.8);
  static const kCircleRadius = 10.0;
  static const kHeadingRadius = 20.0;
  static const kHeadingAngleWidth = 30.0 * pi / 180.0; // 30°

  _LocationMarkerPainter(
      {required this.border, required this.offset, this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = kMarkerColor;

    canvas.drawCircle(offset, kCircleRadius, paint);

    if (heading != null) {
      final headingRect =
          Rect.fromCircle(center: offset, radius: kHeadingRadius);
      final headingPaint = Paint()
        ..shader = RadialGradient(colors: [
          kMarkerColor.withOpacity(1.0),
          kMarkerColor.withOpacity(0.0)
        ]).createShader(headingRect);
      canvas.drawArc(
        headingRect,
        heading! - kHeadingAngleWidth / 2,
        kHeadingAngleWidth,
        true,
        headingPaint,
      );
    }

    if (border) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = kBorderColor
        ..strokeWidth = 1.0;

      canvas.drawCircle(offset, kCircleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_LocationMarkerPainter oldDelegate) => false;
}
