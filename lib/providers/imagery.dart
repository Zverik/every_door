import 'dart:convert';

import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/imagery.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final imageryProvider = StateNotifierProvider<ImageryProvider, Imagery>(
    (ref) => ImageryProvider(ref));

final selectedImageryProvider =
    StateNotifierProvider<SelectedImageryProvider, Imagery>(
        (ref) => SelectedImageryProvider(ref));

class ImageryProvider extends StateNotifier<Imagery> {
  static final _logger = Logger('ImageryProvider');
  final Ref _ref;
  bool loaded = false;

  static String? bingUrlTemplate;

  static const kBingUrlKey = 'bing_url_template';
  static const kImageryKey = 'imagery_id';

  static final bingImagery = Imagery(
    id: 'bing',
    type: ImageryType.bing,
    name: 'Bing Aerial Imagery',
    url:
        'ONmGm9hPmmIXyIpRK8Mx33q/TVG91lBWanmUE4XbZl42a+Hpr7b+hd+gqZBF9vXtTteFeLqaXS/JwQvk/eHDRbNcl6hfAWMnCS6b5l+jEqg=',
    encrypted: true,
    icon: 'https://osmlab.github.io/editor-layer-index/sources/world/Bing.png',
    attribution: '© Microsoft Bing',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  static final maxarPremiumImagery = Imagery(
    id: 'Maxar-Premium',
    type: ImageryType.tms,
    name: 'Maxar Premium Imagery',
    url:
        "EcKQpupFzHs7yZp0CdAT3zOWVWST2GB8eji2OtSHNANsdO7JnPHXw+riiIBA2aPDb5GFaKmySAOl/QDz57eaWI18qPwmdhpDeFLMmiDRZ4JQYGJbTzCq1On6IkNnrsnn5KvbL+1P3sAVur9nCCvaomT6i1Tv/WUFFD9zKG8gOf1TCN7mPWIhDOQteeacbx0X60EeyXhg1tyyrtcJ53TgTsScje4/URAsVSNjMjTBz+dbzBpTrcTtI5t398LZP4wP",
    encrypted: true,
    icon: 'https://osmlab.github.io/editor-layer-index/sources/world/Maxar.png',
    attribution: '© DigitalGlobe',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  static final mapboxImagery = Imagery(
    id: 'Mapbox',
    type: ImageryType.tms,
    name: 'Mapbox Satellite',
    url:
        "EcKQpupFzHsz359rFNAelnzeXi+ZgGVtMyCwNNTaeQFgK+nHlqvc3+K/iN0M0e3HYI2cJbm2TxXm5QT0ranPEswj6sVgagtKNkXyi2HZct8mbGBfTzGg3/T5LHVs4c/lqaviIIxV85VP4LkSJCPEi3vinH+s4lpJUycdGGFHPshdeNTDOW4DB6QHSbDKBzsRrRIdxCRM1If92rsopU+JPMud2IUmLx99Hw85cCGEj9Qopkdzi7OfUaYQpauIfd0e",
    encrypted: true,
    icon: 'https://osmlab.github.io/editor-layer-index/sources/world/MapBoxSatellite.png',
    attribution: '© Mapbox',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  ImageryProvider(this._ref) : super(mapboxImagery) {
    _updateBingUrlTemplate();
    loaded = false;
    loadState();
  }

  Future<List<Imagery>> getImageryListForLocation(LatLng location) async {
    final geohash =
        geoHasher.encode(location.longitude, location.latitude, precision: 4);
    final rows = await _ref.read(presetProvider).imageryQuery(geohash);
    List<Imagery> results = rows.map((row) => Imagery.fromJson(row)).toList();
    results.add(mapboxImagery);
    // Imagery is disabled by Maxar.
    // results.add(maxarPremiumImagery);
    if (bingUrlTemplate != null) results.add(bingImagery);
    return results;
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final imageryId = prefs.getString(kImageryKey);
    if (imageryId != null) {
      if (imageryId == bingImagery.id) {
        state = bingImagery;
      } else if (imageryId == maxarPremiumImagery.id) {
        state = mapboxImagery;  // yes, we're silently changing the chosen imagery.
      } else if (imageryId == mapboxImagery.id) {
        state = mapboxImagery;
      } else {
        final imagery =
            await _ref.read(presetProvider).singleImageryQuery(imageryId);
        if (imagery != null) {
          state = Imagery.fromJson(imagery);
        }
      }
    }
    loaded = true;
  }

  saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kImageryKey, state.id);
  }

  setImagery(Imagery value) {
    state = value;
    saveState();
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

  SelectedImageryProvider(this._ref) : super(kOSMImagery) {
    loadValue();
  }

  loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    bool newOSM = prefs.getBool(kPrefsKey) ?? isOSM;
    if (newOSM != isOSM) toggle();
  }

  storeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsKey, isOSM);
  }

  toggle() {
    isOSM = !isOSM;
    state = isOSM ? kOSMImagery : _ref.watch(imageryProvider);
    storeValue();
  }
}
