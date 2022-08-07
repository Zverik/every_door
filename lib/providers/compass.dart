import 'dart:async';
import 'dart:math' show atan2;

import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final compassProvider = StateNotifierProvider<CompassController, CompassData?>(
    (ref) => CompassController());

class CompassData {
  final double? heading;

  const CompassData(this.heading);
}

class CompassController extends StateNotifier<CompassData?> {
  static final _logger = Logger('CompassController');
  late final StreamSubscription _sub;
  int lastEmit = 0;
  static const kMinIntervalMS = 1000;

  CompassController() : super(null) {
    _sub = magnetometerEvents.listen(
      (MagnetometerEvent event) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastEmit >= kMinIntervalMS) {
          lastEmit = now;
          final heading = atan2(event.x, event.y);
          // TODO: the heading is incorrect.
          _logger
              .info('Magnetometer: ${event.x}, ${event.y}; heading $heading');
          state = CompassData(heading);
        }
      },
      onError: (error) {
        state = null;
      },
      onDone: () {
        state = null;
      },
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
