// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/providers/compass.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

@Bind()
class PluginProviders {
  final Ref _ref;

  PluginProviders(this._ref);

  /// Get the current location of the main screen.
  LatLng get location => _ref.read(effectiveLocationProvider);

  /// Learn whether we're moving the map automatically with the user
  /// movement.
  bool get isTracking => _ref.read(trackingProvider);

  /// Get the compass direction.
  double? get compass => _ref.read(compassProvider)?.heading;

  /// Teleports the map to the given location.
  set location(LatLng value) =>
      _ref.read(effectiveLocationProvider.notifier).set(value);

  /// Changes the map zoom level.
  set zoom(double value) => _ref.read(zoomProvider.notifier).update(value);

  // TODO: do we need watching?
}
