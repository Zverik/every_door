import 'package:every_door/providers/compass.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'dart:math' show pi;

class LocationMarkerOptions extends LayerOptions {
  final bool tracking;

  LocationMarkerOptions({
    Key? key,
    this.tracking = true,
    Stream<void>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class LocationMarkerPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    if (options is LocationMarkerOptions) {
      return _LocationMarkerLayer(options, mapState, stream);
    }
    throw Exception('Wrong options type: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) => options is LocationMarkerOptions;
}

class LocationMarkerWidget extends StatelessWidget {
  final LocationMarkerOptions _options;

  LocationMarkerWidget({Key? key, bool tracking = true})
      : _options = LocationMarkerOptions(tracking: tracking),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.maybeOf(context)!;
    return _LocationMarkerLayer(_options, mapState, mapState.onMoved);
  }
}

class _LocationMarkerLayer extends ConsumerWidget {
  final LocationMarkerOptions _options;
  final MapState _mapState;
  final Stream<void>? _stream;

  _LocationMarkerLayer(this._options, this._mapState, this._stream)
      : super(key: _options.key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    final CompassData? compass = null; // ref.watch(compassProvider);
    final bool tracking = _options.tracking && ref.watch(trackingProvider);

    return LayoutBuilder(
      builder: (context, constraints) => StreamBuilder<void>(
          stream: _stream,
          builder: (context, _) {
            if (trackLocation == null) return Container();

            return CustomPaint(
              painter: _LocationMarkerPainter(
                border: tracking,
                offset: _mapState.getOffsetFromOrigin(trackLocation),
                heading: compass?.heading,
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          }),
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
