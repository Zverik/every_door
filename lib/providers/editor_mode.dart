// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/providers/events.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:every_door/screens/modes/definitions/amenity.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/screens/modes/definitions/notes.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final editorModeProvider =
    NotifierProvider<EditorModeController, BaseModeDefinition>(
        EditorModeController.new);

final microZoomedInProvider = StateProvider<LatLngBounds?>((_) => null);
final navigationModeProvider = StateProvider<bool>((ref) => false);

class EditorModeController extends Notifier<BaseModeDefinition> {
  static const kModeKey = 'micromappingMode';
  static final _logger = Logger('EditorModeController');

  final List<BaseModeDefinition> _modes = [];
  int _currentMode = 1;

  @override
  BaseModeDefinition build() {
    reset();
    return DefaultAmenityModeDefinition(ref);
  }

  Future<void> reset() async {
    _modes.clear();
    _modes.addAll([
      DefaultMicromappingModeDefinition(ref),
      DefaultAmenityModeDefinition(ref),
      DefaultEntrancesModeDefinition(ref),
      DefaultNotesModeDefinition(ref),
    ]);
    for (final mode in _modes) {
      await ref.read(eventsProvider.notifier).callModeCreated(mode);
    }
    _currentMode = 1;
    state = loadState() ?? _modes[_currentMode];
  }

  Future<void> initializeFromPlugin(String pluginId) async {
    for (final mode in _modes) {
      await ref.read(eventsProvider.notifier).callModeCreated(mode, pluginId);
    }
    state = _modes[_currentMode];
  }

  Iterable<BaseModeDefinition> modes() sync* {
    for (final mode in _modes) yield mode;
  }

  BaseModeDefinition? loadState() {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    final mode = prefs.getString(kModeKey);
    final idx = _modes.indexWhere((m) => m.name == mode);
    if (idx >= 0) {
      _currentMode = idx;
      return _modes[idx];
    }
    return null;
  }

  Future<void> set(String name) async {
    final i = _modes.indexWhere((m) => m.name == name);
    if (i >= 0 && _currentMode != i && i < _modes.length) {
      _currentMode = i;
      state = _modes[i];
      final prefs = ref.read(sharedPrefsProvider).requireValue;
      await prefs.setString(kModeKey, state.name);
    }
  }

  BaseModeDefinition? get(String name) {
    return _modes.where((m) => m.name == name).firstOrNull;
  }

  void register(BaseModeDefinition mode) {
    final oldMode = get(mode.name);
    if (oldMode == mode) {
      return; // Option to update the mode?
    } else if (oldMode != null) {
      throw ArgumentError(
          'Mode with the name "${mode.name}" already registered.');
    }

    // TODO: priorities
    _modes.add(mode);
    ref.read(eventsProvider.notifier).callModeCreated(mode);
    // TODO: proper notifying
    state = loadState() ?? _modes[_currentMode];
  }

  void unregister(String name) {
    int pos = _modes.indexWhere((m) => m.name == name);
    if (pos >= 0) {
      if (_currentMode >= pos) _currentMode -= 1;
      _modes.removeAt(pos);
      state = _modes[_currentMode]; // what if it's not changed?
    }
  }

  // We're notifying even when the state is the same, because the mode list
  // could have been changed.
  @override
  bool updateShouldNotify(previous, next) => true;
}
