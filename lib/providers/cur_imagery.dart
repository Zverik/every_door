import 'dart:async';

import 'package:every_door/helpers/tile_caches.dart';
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
  static final _kOSMImagery = TmsImagery(
    id: 'openstreetmap',
    name: 'OpenStreetMap',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
    minZoom: 0,
    maxZoom: 19,
    cachingStore: kTileCacheBase,
  );

  static final _kBaseImagery = VectorAssetsImagery(
    id: 'osm-versatiles',
    name: 'Versatiles Colorful',
    attribution: '© OpenStreetMap contributors',
    stylePath: 'assets/styles/versatiles.json',
    spritesBase: 'assets/styles/sprites',
  );

  final Imagery _base = _kBaseImagery;

  @override
  Imagery build() {
    _base.initialize().then((_) {
      if (state == _kOSMImagery) state = _base;
    });
    return _kOSMImagery;
  }

  void set(Imagery imagery) {
    imagery.initialize().then((_){
      state = imagery;
    });
  }

  void revert() {
    state = _base;
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
