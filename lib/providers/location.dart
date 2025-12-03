import 'package:every_door/constants.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

final effectiveLocationProvider =
    NotifierProvider<EffectiveLocationController, LatLng>(
        EffectiveLocationController.new);

final visibleBoundsProvider =
    NotifierProvider<VisibleBoundsNotifier, LatLngBounds?>(
        VisibleBoundsNotifier.new);

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

class VisibleBoundsNotifier extends Notifier<LatLngBounds?> {
  @override
  LatLngBounds? build() => null;

  void update(LatLngBounds bounds) {
    final old = state;
    if (old == null) {
      state = bounds;
    } else {
      // We do not shrink the bounds, because it's basically an area to download. Why update?
      // 1e-3 ≈ 111 m, 1e-5 ≈ 1.1m, good enough.
      // When new is bigger, it is not covered by old, that's okay.
      // When new is smaller (area < old.area), we hold until the difference is twofold.
      if (!old.expand(1e-5).containsBounds(bounds) ||
          bounds.area() * 2 > old.area()) {
        state = bounds;
      }
    }
  }
}

extension LatLngBoundsExpansion on LatLngBounds {
  LatLngBounds expand(double delta) => LatLngBounds(
        LatLng(south - delta, west - delta),
        LatLng(north + delta, east + delta),
      );

  double area() => (north - south) * (east - west);
}
