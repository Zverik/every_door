import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final editorModeProvider =
    StateNotifierProvider<EditorModeController, EditorMode>(
        (_) => EditorModeController());

final microZoomedInProvider = StateProvider<LatLngBounds?>((_) => null);

enum EditorMode {
  poi,
  micromapping,
  entrances,
}

class EditorModeController extends StateNotifier<EditorMode> {
  static const kModeKey = 'micromappingMode';

  EditorModeController() : super(EditorMode.poi) {
    loadState();
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final modes = {for (final m in EditorMode.values) m.name: m};
    state = modes[prefs.getString(kModeKey)] ?? EditorMode.poi;
  }

  set(EditorMode newValue) async {
    if (state != newValue) {
      state = newValue;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kModeKey, state.name);
    }
  }
}
