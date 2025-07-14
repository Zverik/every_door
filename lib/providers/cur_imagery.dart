import 'dart:async';

import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/models/imagery/vector_assets.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final baseImageryProvider =
    NotifierProvider<BaseImageryNotifier, Imagery>(BaseImageryNotifier.new);

final imageryIsBaseProvider =
    NotifierProvider<ImageryIsBaseProvider, bool>(ImageryIsBaseProvider.new);

final selectedImageryProvider = Provider<Imagery>((ref) {
  final base = ref.watch(baseImageryProvider);
  final imagery = ref.watch(imageryProvider);
  final isBase = ref.watch(imageryIsBaseProvider);

  tileResetController.add(null);
  return isBase ? base : imagery;
});

final StreamController<void> tileResetController = StreamController.broadcast();

class BaseImageryNotifier extends Notifier<Imagery> {
  static const _kOSMImagery = TmsImagery(
    id: 'openstreetmap',
    name: 'OpenStreetMap',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
    minZoom: 0,
    maxZoom: 19,
  );

  static final _kBaseImagery = VectorAssetsImagery(
    id: 'openfreemap-liberty',
    name: 'OpenFreeMap Liberty',
    attribution: '© OSM contributors, OpenFreeMap',
    stylePath: 'assets/styles/liberty.json',
    spritesBase: 'assets/styles/ofm',
  );

  Imagery _base = _kBaseImagery;

  @override
  Imagery build() {
    _base.initialize().then((_) {
      state = _base;
    });
    return _kOSMImagery;
  }

  void set(Imagery imagery) {
    state = imagery;
  }

  void revert() {
    state = _base;
  }

  void setBase(Imagery imagery) {
    final isBase = state == _base;
    _base = imagery;
    if (isBase) state = _base;
  }
}

class ImageryIsBaseProvider extends Notifier<bool> {
  static const kPrefsKey = 'selected_imagery_osm';

  @override
  bool build() {
    _loadValue();
    return true;
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    bool? newOSM = prefs.getBool(kPrefsKey);
    if (newOSM != null && newOSM != state) state = newOSM;
  }

  Future<void> _storeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsKey, state);
  }

  void toggle() {
    state = !state;
    _storeValue();
  }
}
