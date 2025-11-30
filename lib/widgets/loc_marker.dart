import 'package:every_door/providers/compass.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'dart:math' show pi;

/// This is the blue circle displayed at the user location.
/// Uses [geolocationProvider] for getting the GPS tracker data.
/// Returns an empty [Container] if not tracking.
class LocationMarkerWidget extends ConsumerWidget {
  LocationMarkerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    if (trackLocation == null) return Container();

    final CompassData? compass = ref.watch(compassProvider);
    return MobileLayerTransformer(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _LocationMarkerPainter(
            border: ref.watch(trackingProvider),
            offset: MapCamera.of(context).getOffsetFromOrigin(trackLocation),
            heading: compass?.heading,
          ),
          // TODO: check that it's still painted
          // size: Size(constraints.maxWidth, constraints.maxHeight),
        ),
      ),
    );
  }
}

class _LocationMarkerPainter extends CustomPainter {
  final bool border;
  final Offset offset;
  final double? heading;

  static final kMarkerColor = Colors.blue.withValues(alpha: 0.4);
  static final kBorderColor = Colors.black.withValues(alpha: 0.8);
  static const kCircleRadius = 10.0;
  static const kHeadingRadius = 20.0;
  static const kHeadingAngleWidth = 60.0 * pi / 180.0; // 60°

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
          kMarkerColor.withValues(alpha: 1.0),
          kMarkerColor.withValues(alpha: 0.0)
        ]).createShader(headingRect);
      canvas.drawArc(
        headingRect,
        // Subtracting pi/2 adjusts the heading because Flutter's arc drawing starts at the positive x-axis,
        // while a heading of 0 represents north (upwards).
        (heading! - pi / 2) - kHeadingAngleWidth / 2,
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
