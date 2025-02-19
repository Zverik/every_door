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

  EditorModeController(this._ref) : super(AmenityModeDefinition(_ref)) {
    reset();
    loadState();
  }

  reset() {
    _modes.clear();
    _logger.fine('Ref class: ${_ref.runtimeType}');
    _modes.addAll([
      MicromappingModeDefinition(_ref),
      AmenityModeDefinition(_ref),
      EntrancesModeDefinition(_ref),
      NotesModeDefinition(_ref),
    ]);
    _currentMode = 1;
    state = _modes[_currentMode];
  }

  Iterable<BaseModeDefinition> modes() sync* {
    for (final mode in _modes) yield mode;
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(kModeKey);
    final idx = _modes.indexWhere((m) => m.name == mode);
    if (idx >= 0) {
      _currentMode = idx;
      state = _modes[idx];
    }
  }

  set(String name) async {
    final i = _modes.indexWhere((m) => m.name == name);
    if (i >= 0 && _currentMode != i && i < _modes.length) {
      _currentMode = i;
      state = _modes[i];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kModeKey, state.name);
    }
  }
}
