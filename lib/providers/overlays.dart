import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/imagery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayImageryProvider =
    NotifierProvider<OverlayImagery, List<Widget>>(OverlayImagery.new);

class OverlayImagery extends Notifier<List<Widget>> {
  final Map<String, TileLayerOptions> _imagery = {};
  final Map<String, Widget> _widgets = {};
  final List<String> _order = [];

  @override
  List<Widget> build() => [];

  void _updateState() {
    state = _order
        .map((k) => _widgets[k] ?? _imagery[k]?.buildTileLayer())
        .whereType<Widget>()
        .toList();
  }

  void addLayer({required String key, Imagery? imagery, Widget? widget}) {
    if (imagery != null) _imagery[key] = TileLayerOptions(imagery);
    if (widget != null) _widgets[key] = widget;
    _order.add(key);
    _updateState();
  }

  void removeLayer(String key) {
    _imagery.remove(key);
    _widgets.remove(key);
    _order.remove(key);
    _updateState();
  }

  void removeLayers(String prefix) {
    _imagery.removeWhere((k, _) => k.startsWith(prefix));
    _widgets.removeWhere((k, _) => k.startsWith(prefix));
    _order.removeWhere((k) => k.startsWith(prefix));
    _updateState();
  }
}
