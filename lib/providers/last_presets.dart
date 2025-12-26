// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastPresetsProvider = Provider((ref) => LastPresetsProvider(ref));

class LastPresetsProvider {
  final Ref _ref;
  // I could use queue, but it does not have .indexOf().
  final Map<String, List<Preset>> _lastPresets = {};
  final Map<String, Map<String, String>> _lastTags = {};

  static const kMaxLastPresets = 3;

  LastPresetsProvider(this._ref);

  void registerPreset(Preset preset, Map<String, String> tags,
      {bool justTags = false}) {
    final mode = _ref.read(editorModeProvider);
    if (!_lastPresets.containsKey(mode.name))
      _lastPresets[mode.name] = <Preset>[];
    final list = _lastPresets[mode.name]!;

    // Push the preset to the top and trim the list.
    final pos = list.indexOf(preset);
    if (!justTags && pos != 0) {
      if (pos > 0) list.removeAt(pos);
      list.insert(0, preset);
      if (list.length > kMaxLastPresets) {
        for (int i = kMaxLastPresets; i < list.length; i++)
          _lastTags.remove(list[i].id);
        list.removeRange(kMaxLastPresets, list.length);
      }
    }

    // Store tags, removing useless things.
    if (!ElementKind.amenity.matchesTags(tags)) {
      final Map<String, String> newTags = {};
      const kDeleteKeys = {
        'check_date',
        'source',
        'note',
        'operator',
        'phone',
        'website',
        'camera:direction',
        'direction',
      };
      tags.forEach((key, value) {
        if (!kDeleteKeys.contains(key) &&
            !key.startsWith('ref') &&
            !key.startsWith('name') &&
            !key.startsWith('contact:') &&
            !key.startsWith('addr:')) {
          newTags[key] = value;
        }
      });
      _lastTags[preset.id] = newTags;
    }
  }

  List<Preset> getPresets() {
    final mode = _ref.read(editorModeProvider);
    return _lastPresets[mode.name] ?? const [];
  }

  Map<String, String>? getTagsForPreset(Preset preset) => _lastTags[preset.id];
}
