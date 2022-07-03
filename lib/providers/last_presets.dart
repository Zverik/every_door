import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastPresetsProvider = Provider((ref) => LastPresetsProvider(ref));

class LastPresetsProvider {
  final Ref _ref;
  // I could use queue, but it does not have .indexOf().
  final Map<EditorMode, List<Preset>> _lastPresets = {};
  final Map<String, Map<String, String>> _lastTags = {};

  static const kMaxLastPresets = 3;

  LastPresetsProvider(this._ref);

  registerPreset(Preset preset, Map<String, String> tags) {
    final mode = _ref.read(editorModeProvider);
    if (!_lastPresets.containsKey(mode)) _lastPresets[mode] = <Preset>[];
    final list = _lastPresets[mode]!;

    // Push the preset to the top and trim the list.
    final pos = list.indexOf(preset);
    if (pos == 0) return;
    if (pos > 0) list.removeAt(pos);
    list.insert(0, preset);
    if (list.length > kMaxLastPresets) {
      for (int i = kMaxLastPresets; i < list.length; i++)
        _lastTags.remove(list[i].id);
      list.removeRange(kMaxLastPresets, list.length);
    }

    // Store tags, removing useless things.
    if (!isAmenityTags(tags)) {
      final Map<String, String> newTags = {};
      const kDeleteKeys = {'check_date', 'source', 'note', 'operator'};
      tags.forEach((key, value) {
        if (!kDeleteKeys.contains(key) &&
            !key.startsWith('ref') &&
            !key.startsWith('name')) {
          newTags[key] = value;
        }
      });
      _lastTags[preset.id] = tags;
    }
  }

  List<Preset> getPresets() {
    final mode = _ref.read(editorModeProvider);
    return _lastPresets[mode] ?? const [];
  }

  Map<String, String>? getTagsForPreset(Preset preset) => _lastTags[preset.id];
}
