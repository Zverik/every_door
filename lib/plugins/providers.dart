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

  LatLng get location => _ref.read(effectiveLocationProvider);
  bool get isTracking => _ref.read(trackingProvider);
  double? get compass => _ref.read(compassProvider)?.heading;

  set location(LatLng value) =>
      _ref.read(effectiveLocationProvider.notifier).set(value);
  set zoom(double value) => _ref.read(zoomProvider.notifier).state = value;

  // TODO: do we need watching?
}
