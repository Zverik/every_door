import 'package:every_door/constants.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:shared_preferences/shared_preferences.dart';

final effectiveLocationProvider =
    StateNotifierProvider<EffectiveLocationController, LatLng>(
        (ref) => EffectiveLocationController(ref));

class EffectiveLocationController extends StateNotifier<LatLng> {
  static const kSavedLocation = 'last_location';

  final Ref _ref;

  EffectiveLocationController(this._ref)
      : super(LatLng(kDefaultLocation[0], kDefaultLocation[1])) {
    _restore();
  }

  _restore() async {
    final geoPos = _ref.read(geolocationProvider);
    if (geoPos != null) {
      state = geoPos;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final loc = prefs.getStringList(kSavedLocation);
      if (loc != null) {
        state = LatLng(double.parse(loc[0]), double.parse(loc[1]));
      }
    }
  }

  set(LatLng location) async {
    state = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSavedLocation,
        [location.latitude.toString(), location.longitude.toString()]);
  }
}
