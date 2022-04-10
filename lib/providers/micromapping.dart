import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final micromappingProvider =
    StateNotifierProvider<MicromappingController, bool>((_) => MicromappingController());

final microZoomedInProvider = StateProvider<LatLngBounds?>((_) => null);

class MicromappingController extends StateNotifier<bool> {
  static const kMicromappingKey = 'micromappingMode';

  MicromappingController() : super(false) {
    loadState();
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(kMicromappingKey) ?? false;
  }

  toggle() async {
    await set(!state);
  }

  set(bool newValue) async {
    state = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kMicromappingKey, state);
  }
}
