import 'package:every_door/screens/modes/definitions/amenity.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/screens/modes/definitions/notes.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final editorModeProvider =
    StateNotifierProvider<EditorModeController, BaseModeDefinition>(
        (ref) => EditorModeController(ref));

final microZoomedInProvider = StateProvider<LatLngBounds?>((_) => null);
final navigationModeProvider = StateProvider<bool>((ref) => false);

class EditorModeController extends StateNotifier<BaseModeDefinition> {
  static const kModeKey = 'micromappingMode';
  static final _logger = Logger('EditorModeController');

  final Ref _ref;
  final List<BaseModeDefinition> _modes = [];
  int _currentMode = 1;

  EditorModeController(this._ref) : super(DefaultAmenityModeDefinition(_ref)) {
    reset();
    loadState();
  }

  void reset() {
    _modes.clear();
    _logger.fine('Ref class: ${_ref.runtimeType}');
    _modes.addAll([
      DefaultMicromappingModeDefinition(_ref),
      DefaultAmenityModeDefinition(_ref),
      DefaultEntrancesModeDefinition(_ref),
      DefaultNotesModeDefinition(_ref),
    ]);
    _currentMode = 1;
    state = _modes[_currentMode];
  }

  Iterable<BaseModeDefinition> modes() sync* {
    for (final mode in _modes) yield mode;
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(kModeKey);
    final idx = _modes.indexWhere((m) => m.name == mode);
    if (idx >= 0) {
      _currentMode = idx;
      state = _modes[idx];
    }
  }

  Future<void> set(String name) async {
    final i = _modes.indexWhere((m) => m.name == name);
    if (i >= 0 && _currentMode != i && i < _modes.length) {
      _currentMode = i;
      state = _modes[i];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kModeKey, state.name);
    }
  }

  BaseModeDefinition? get(String name) {
    return _modes.where((m) => m.name == name).firstOrNull;
  }

  void register(BaseModeDefinition mode) {
    final oldMode = get(mode.name);
    if (oldMode == mode) {
      state = _modes[_currentMode]; // TODO: proper notifying
    } else if (oldMode != null) {
      throw ArgumentError(
          'Mode with the name "${mode.name}" already registered.');
    }

    // TODO: priorities
    _modes.add(mode);
    loadState();
    state = _modes[_currentMode]; // TODO: proper notifying
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
  bool updateShouldNotify(old, current) => true;
}
