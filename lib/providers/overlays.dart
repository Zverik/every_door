// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/models/imagery.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayImageryProvider =
    NotifierProvider<OverlayImagery, List<Imagery>>(OverlayImagery.new);

class OverlayImagery extends Notifier<List<Imagery>> {
  final Map<String, Imagery> _imagery = {};
  final List<String> _order = [];
  final Map<String, Set<String>> _modes = {};

  @override
  List<Imagery> build() {
    ref.listen(editorModeProvider, (o, n) {
      _updateState();
    });
    return [];
  }

  void _updateState() {
    final mode = ref.read(editorModeProvider);
    final layers = _order.where((k) => _modes[k]?.contains(mode.name) ?? true);
    state = layers
        .map((k) => _imagery[k])
        .whereType<Imagery>()
        .toList();
  }

  Future<void> addLayer(String key, Imagery imagery,
      {Set<String>? modes, String? pluginId}) async {
    await imagery.initialize();
    if (pluginId != null) {
      key = 'plugin_${pluginId}#$key';
    }
    _imagery[key] = imagery;
    _order.add(key);
    if (modes != null) _modes[key] = modes;
    _updateState();
  }

  void removeLayer(String key) {
    _imagery.remove(key);
    _order.remove(key);
    _modes.remove(key);
    _updateState();
  }

  void removeLayers(String prefix) {
    _imagery.removeWhere((k, _) => k.startsWith(prefix));
    _order.removeWhere((k) => k.startsWith(prefix));
    _modes.removeWhere((k, _) => k.startsWith(prefix));
    _updateState();
  }

  void removePluginLayers(String pluginId) {
    removeLayers('plugin_$pluginId#');
  }
}
