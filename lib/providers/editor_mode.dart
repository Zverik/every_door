import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final editorModeProvider =
    StateNotifierProvider<EditorModeController, EditorMode>(
        (_) => EditorModeController());

final microZoomedInProvider = StateProvider<LatLngBounds?>((_) => null);
final navigationModeProvider = StateProvider<bool>((ref) => false);

enum EditorMode {
  poi,
  micromapping,
  entrances,
  notes,
}

const kEditorModeIcons = {
  EditorMode.poi: Icons.free_breakfast, // local_cafe icon is broken
  EditorMode.micromapping: Icons.park,
  EditorMode.entrances: Icons.home,
  EditorMode.notes: Icons.note_alt,
};

const kEditorModeIconsOutlined = {
  EditorMode.poi: Icons.free_breakfast_outlined,
  EditorMode.micromapping: Icons.park_outlined,
  EditorMode.entrances: Icons.home_outlined,
  EditorMode.notes: Icons.note_alt_outlined,
};

const kNextMode = {
  EditorMode.micromapping: EditorMode.poi,
  EditorMode.poi: EditorMode.entrances,
  EditorMode.entrances: EditorMode.notes,
  EditorMode.notes: EditorMode.micromapping,
};

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

  next() async {
    await set(kNextMode[state]!);
  }
}
