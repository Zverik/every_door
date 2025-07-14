import 'package:every_door/models/imagery.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayImageryProvider =
    NotifierProvider<OverlayImagery, List<Widget>>(OverlayImagery.new);

class OverlayImagery extends Notifier<List<Widget>> {
  final Map<String, Imagery> _imagery = {};
  final List<String> _order = [];
  final Map<String, Set<String>> _modes = {};

  @override
  List<Widget> build() {
    ref.listen(editorModeProvider, (o, n) {
      _updateState();
    });
    return [];
  }

  void _updateState() {
    final mode = ref.read(editorModeProvider);
    final layers = _order.where((k) => _modes[k]?.contains(mode.name) ?? true);
    state = layers
        .map((k) => _imagery[k]?.buildLayer())
        .whereType<Widget>()
        .toList();
  }

  Future<void> addLayer(String key, Imagery imagery,
      [Set<String>? modes]) async {
    await imagery.initialize();
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
}
