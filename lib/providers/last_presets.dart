import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastPresetsProvider = Provider((ref) => LastPresetsProvider(ref));

class LastPresetsProvider {
  final Ref _ref;
  // I could use queue, but it does not have .indexOf().
  final Map<EditorMode, List<Preset>> _lastPresets = {};

  static const kMaxLastPresets = 3;

  LastPresetsProvider(this._ref);

  registerPreset(Preset preset) {
    final mode = _ref.read(editorModeProvider);
    if (!_lastPresets.containsKey(mode)) _lastPresets[mode] = <Preset>[];
    final list = _lastPresets[mode]!;

    final pos = list.indexOf(preset);
    if (pos == 0) return;
    if (pos > 0) list.removeAt(pos);
    list.insert(0, preset);
    if (list.length > kMaxLastPresets)
      list.removeRange(kMaxLastPresets, list.length);
  }

  List<Preset> getPresets() {
    final mode = _ref.read(editorModeProvider);
    return _lastPresets[mode] ?? const [];
  }
}