import 'dart:async';

import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/models/imagery/vector.dart';
import 'package:every_door/models/imagery/vector_assets.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final baseImageryProvider =
    NotifierProvider<BaseImageryNotifier, Imagery>(BaseImageryNotifier.new);

final selectedImageryProvider =
    NotifierProvider<SelectedImageryProvider, Imagery>(
        SelectedImageryProvider.new);

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
    attribution: '© OpenFreeMap',
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

class SelectedImageryProvider extends Notifier<Imagery> {
  bool isBase = true;

  static const kPrefsKey = 'selected_imagery_osm';

  @override
  Imagery build() {
    loadValue();
    ref.listen(baseImageryProvider, (_, next) {
      if (isBase) state = next;
    });
    return ref.read(baseImageryProvider);
  }

  Future<void> loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    bool newOSM = prefs.getBool(kPrefsKey) ?? isBase;
    if (newOSM != isBase) toggle();
  }

  Future<void> storeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsKey, isBase);
  }

  void toggle() {
    isBase = !isBase;
    state = isBase ? ref.read(baseImageryProvider) : ref.read(imageryProvider);
    tileResetController.add(null);
    storeValue();
  }
}
