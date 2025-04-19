import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' show pi;

final compassProvider = StateNotifierProvider<CompassController, CompassData?>(
  (ref) => CompassController(),
);

class CompassData {
  // radians, zero is North
  final double? heading;

  const CompassData(this.heading);
}

class CompassController extends StateNotifier<CompassData?> {
  static final _logger = Logger('CompassController');
  StreamSubscription<CompassEvent>? _sub;

  CompassController() : super(null) {
    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      _logger.warning("Compass events not available on this platform.");
      state = null;
      return;
    }
    _sub = compassEvents.listen(
      (CompassEvent event) {
        if (event.heading != null) {
          _logger.info('Compass heading: ${event.heading}');

          final double headingRadians = event.heading! * pi / 180.0;
          state = CompassData(headingRadians);
        } else {
          _logger.info('Compass is calibrating, heading is null.');
          state = const CompassData(null);
        }
      },
      onError: (error) {
        _logger.severe('Error reading compass data: $error');
        state = null;
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}