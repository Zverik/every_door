import 'package:every_door/constants.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

final effectiveLocationProvider =
    NotifierProvider<EffectiveLocationController, LatLng>(
        EffectiveLocationController.new);

final zoomProvider = NotifierProvider<ZoomNotifier, double>(ZoomNotifier.new);

final rotationProvider =
    NotifierProvider<RotationNotifier, double>(RotationNotifier.new);

class ZoomNotifier extends Notifier<double> {
  @override
  double build() => kInitialZoom;
}

class RotationNotifier extends Notifier<double> {
  @override
  double build() => 0.0;
}

class EffectiveLocationController extends Notifier<LatLng> {
  static const kSavedLocation = 'last_location';

  @override
  LatLng build() {
    LatLng location = LatLng(kDefaultLocation[0], kDefaultLocation[1]);
    final geoPos = ref.read(geolocationProvider);
    if (geoPos != null) {
      location = geoPos;
    } else {
      final prefs = ref.read(sharedPrefsProvider).requireValue;
      final loc = prefs.getStringList(kSavedLocation);
      if (loc != null) {
        location = LatLng(double.parse(loc[0]), double.parse(loc[1]));
      }
    }
    return location;
  }

  Future<void> set(LatLng location) async {
    state = location;
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    await prefs.setStringList(kSavedLocation,
        [location.latitude.toString(), location.longitude.toString()]);
  }
}
