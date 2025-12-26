// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'dart:math' show pi;

final compassProvider =
    NotifierProvider<CompassController, CompassData?>(CompassController.new);

class CompassData {
  // radians, zero is North
  final double? heading;

  const CompassData(this.heading);
}

class CompassController extends Notifier<CompassData?> {
  static final _logger = Logger('CompassController');
  StreamSubscription<CompassEvent>? _sub;

  @override
  CompassData? build() {
    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      _logger.warning("Compass events not available on this platform.");
      return null;
    }

    _sub = compassEvents.listen(
      (CompassEvent event) {
        if (event.heading != null) {
          final double headingRadians = event.heading! * pi / 180.0;
          state = CompassData(headingRadians);
        } else {
          _logger.fine('Compass is calibrating, heading is null.');
          state = CompassData(null);
        }
      },
      onError: (error) {
        _logger.severe('Error reading compass data: $error');
        state = null;
      },
    );

    ref.onDispose(() => _sub?.cancel());
    return null;
  }
}
