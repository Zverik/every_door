import 'dart:async';
import 'dart:convert';

import 'package:every_door/models/imagery/bing.dart';
import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/imagery.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const kOSMImagery = TmsImagery(
  id: 'openstreetmap',
  name: 'OpenStreetMap',
  url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  attribution: '© OpenStreetMap contributors',
  minZoom: 0,
  maxZoom: 19,
);

final imageryProvider = StateNotifierProvider<ImageryProvider, Imagery>(
    (ref) => ImageryProvider(ref));

final baseImageryProvider = StateProvider<Imagery>((ref) => kOSMImagery);

final selectedImageryProvider =
    StateNotifierProvider<SelectedImageryProvider, Imagery>(
        (ref) => SelectedImageryProvider(ref));

final StreamController<void> tileResetController = StreamController.broadcast();

class ImageryProvider extends StateNotifier<Imagery> {
  static final _logger = Logger('ImageryProvider');
  final Ref _ref;
  bool loaded = false;
  final List<Imagery> _additional = [];

  static String? bingUrlTemplate;

  static const kBingUrlKey = 'bing_url_template';
  static const kImageryKey = 'imagery_id';

  static final bingImagery = BingImagery(
    id: 'bing',
    name: 'Bing Aerial Imagery',
    url:
        'ONmGm9hPmmIXyIpRK8Mx33q/TVG91lBWanmUE4XbZl42a+Hpr7b+hd+gqZBF9vXtTteFeLqaXS/JwQvk/eHDRbNcl6hfAWMnCS6b5l+jEqg=',
    encrypted: true,
    icon: 'https://osmlab.github.io/editor-layer-index/sources/world/Bing.png',
    attribution: '© Microsoft Bing',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  static final maxarPremiumImagery = TmsImagery(
    id: 'Maxar-Premium',
    name: 'Maxar Premium Imagery',
    url:
        "EcKQpupFzHs7yZp0CdAT3zOWVWST2GB8eji2OtSHNANsdO7JnPHXw+riiIBA2aPDb5GFaKmySAOl/QDz57eaWI18qPwmdhpDeFLMmiDRZ4JQYGJbTzCq1On6IkNnrsnn5KvbL+1P3sAVur9nCCvaomT6i1Tv/WUFFD9zKG8gOf1TCN7mPWIhDOQteeacbx0X60EeyXhg1tyyrtcJ53TgTsScje4/URAsVSNjMjTBz+dbzBpTrcTtI5t398LZP4wP",
    encrypted: true,
    icon: 'https://osmlab.github.io/editor-layer-index/sources/world/Maxar.png',
    attribution: '© DigitalGlobe',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  static final mapboxImagery = TmsImagery(
    id: 'Mapbox',
    name: 'Mapbox Satellite',
    url:
        "EcKQpupFzHsz359rFNAelnzeXi+ZgGVtMyCwNNTaeQFgK+nHlqvc3+K/iN0M0e3HYI2cJbm2TxXm5QT0ranPEswj6sVgagtKNkXyi2HZct8mbGBfTzGg3/T5LHVs4c/lqaviIIxV85VP4LkSJCPEi3vinH+s4lpJUycdGGFHPshdeNTDOW4DB6QHSbDKBzsRrRIdxCRM1If92rsopU+JPMud2IUmLx99Hw85cCGEj9Qopkdzi7OfUaYQpauIfd0e",
    encrypted: true,
    icon:
        'https://osmlab.github.io/editor-layer-index/sources/world/MapBoxSatellite.png',
    attribution: '© Mapbox',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  ImageryProvider(this._ref) : super(mapboxImagery) {
    _updateBingUrlTemplate();
    loaded = false;
    _loadState();
  }

  Future<List<Imagery>> getImageryListForLocation(LatLng location) async {
    final geohash =
        geoHasher.encode(location.longitude, location.latitude, precision: 4);
    final rows = await _ref.read(presetProvider).imageryQuery(geohash);
    List<Imagery> results = rows.map((row) => TileImagery.fromJson(row)).whereType<Imagery>().toList();
    results.addAll(_additional);
    results.add(mapboxImagery);
    // Imagery is disabled by Maxar.
    // results.add(maxarPremiumImagery);
    if (bingUrlTemplate != null) results.add(bingImagery);
    return results;
  }

  /// Loads the chosen imagery from shared preferences. There are some
  /// system keys it processes in code: for Bing, Maxar, and Mapbox.
  /// If it's none of those, it asks [PresetProvider] if it knows this key.
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final imageryId = prefs.getString(kImageryKey);
    if (imageryId != null) {
      if (imageryId == bingImagery.id) {
        state = bingImagery;
      } else if (imageryId == maxarPremiumImagery.id) {
        state =
            mapboxImagery; // yes, we're silently changing the chosen imagery.
      } else if (imageryId == mapboxImagery.id) {
        state = mapboxImagery;
      } else if (_additional.any((i) => i.id == imageryId)) {
        state = _additional.firstWhere((i) => i.id == imageryId);
      } else {
        final imagery =
            await _ref.read(presetProvider).singleImageryQuery(imageryId);
        if (imagery != null) {
          state = TileImagery.fromJson(imagery);
        }
      }
    }
    loaded = true;
  }

  /// Simply saves the current chosen imagery to shared preferences.
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kImageryKey, state.id);
  }

  /// Changes the current imagery, notifies listeners, and saves the state.
  void setImagery(Imagery value) {
    state = value;
    _saveState();
  }

  /// Adds the imagery definition to an internal additional imagery
  /// list, to be provided to everywhere. Also if the imagery added
  /// has been stored to preferences, immediately switches to it.
  void registerImagery(Imagery imagery, bool force) async {
    if (!_additional.any((i) => i.id == imagery.id)) {
      _additional.add(imagery);

      if (force) {
        setImagery(imagery);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final imageryId = prefs.getString(kImageryKey);
        if (imageryId != null && imageryId == imagery.id) {
          state = imagery;
        }
      }
    }
  }

  /// Removes one specific additional imagery entry. Behaves
  /// like [resetImagery], in that it changes state, but does
  /// not save it.
  void unregisterImagery(String imageryId) {
    _additional.removeWhere((i) => i.id == imageryId);
    if (state.id == imageryId) state = mapboxImagery;
  }

  /// Called to clear the list of imagery added. Usually called
  /// on plugin de-registration, and some of the imagery can be
  /// immediately reinstated (including the selected one), so
  /// we're changing the state, but not saving it.
  void resetImagery() {
    if (_additional.any((i) => i == state)) {
      state = mapboxImagery;
    }
    _additional.clear();
  }

  Future _updateBingUrlTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final metaUrl = Uri.https(
      'dev.virtualearth.net',
      '/REST/V1/Imagery/Metadata/Aerial',
      {'output': 'json', 'include': 'ImageryProviders', 'key': bingImagery.url},
    );
    final resp = await http.get(metaUrl);
    if (resp.statusCode != 200) {
      _logger.warning(
          'Failed to get Bing imagery metadata: ${resp.statusCode} ${resp.body}, url: $metaUrl');
      final oldUrl = prefs.getString(kBingUrlKey);
      if (oldUrl != null) return oldUrl;
      throw StateError(
          'Error querying Bing metadata: ${resp.statusCode} ${resp.body}\nURL: $metaUrl');
    }
    final data = JsonDecoder().convert(resp.body);
    final resource =
        data['resourceSets'][0]['resources'][0] as Map<String, dynamic>;
    String url = resource['imageUrl'];
    Iterable<String> subdomains =
        (resource['imageUrlSubdomains'] as List).whereType<String>();
    url = url.replaceFirst('{subdomain}', '{switch:${subdomains.join(",")}}');
    bingUrlTemplate = url;
    await prefs.setString(kBingUrlKey, url);
  }
}

class SelectedImageryProvider extends StateNotifier<Imagery> {
  final Ref _ref;
  bool isOSM = true;

  static const kPrefsKey = 'selected_imagery_osm';

  SelectedImageryProvider(this._ref) : super(_ref.read(baseImageryProvider)) {
    loadValue();
  }

  Future<void> loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    bool newOSM = prefs.getBool(kPrefsKey) ?? isOSM;
    if (newOSM != isOSM) toggle();
  }

  Future<void> storeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsKey, isOSM);
  }

  void toggle() {
    isOSM = !isOSM;
    state =
        isOSM ? _ref.watch(baseImageryProvider) : _ref.watch(imageryProvider);
    tileResetController.add(null);
    storeValue();
  }
}
