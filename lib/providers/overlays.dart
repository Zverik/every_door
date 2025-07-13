import 'package:every_door/models/imagery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayImageryProvider =
    NotifierProvider<OverlayImagery, List<Widget>>(OverlayImagery.new);

class OverlayImagery extends Notifier<List<Widget>> {
  final Map<String, Imagery> _imagery = {};
  final List<String> _order = [];

  @override
  List<Widget> build() => [];

  void _updateState() {
    state = _order
        .map((k) => _imagery[k]?.buildLayer())
        .whereType<Widget>()
        .toList();
  }

  Future<void> addLayer(String key, Imagery imagery) async {
    await imagery.initialize();
    _imagery[key] = imagery;
    _order.add(key);
    _updateState();
  }

  void removeLayer(String key) {
    _imagery.remove(key);
    _order.remove(key);
    _updateState();
  }

  void removeLayers(String prefix) {
    _imagery.removeWhere((k, _) => k.startsWith(prefix));
    _order.removeWhere((k) => k.startsWith(prefix));
    _updateState();
  }
}
