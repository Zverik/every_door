// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:async';
import 'dart:convert';

import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/imagery/bing.dart';
import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:fast_geohash/fast_geohash_str.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/imagery.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

final imageryProvider =
    NotifierProvider<ImageryProvider, Imagery>(ImageryProvider.new);

class ImageryProvider extends Notifier<Imagery> {
  static final _logger = Logger('ImageryProvider');
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
    icon: MultiIcon(
        imageUrl:
            'https://osmlab.github.io/editor-layer-index/sources/world/Bing.png'),
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
    icon: MultiIcon(
        imageUrl:
            'https://osmlab.github.io/editor-layer-index/sources/world/Maxar.png'),
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
    icon: MultiIcon(
        imageUrl:
            'https://osmlab.github.io/editor-layer-index/sources/world/MapBoxSatellite.png'),
    attribution: '© Mapbox',
    minZoom: 1,
    maxZoom: 22,
  ).decrypt();

  @override
  Imagery build() {
    loaded = false;
    _updateBingUrlTemplate();
    _loadState();
    return mapboxImagery;
  }

  Future<List<Imagery>> getImageryListForLocation(LatLng location) async {
    final hash = geohash.encode(location.latitude, location.longitude, 4);
    final rows = await ref.read(presetProvider).imageryQuery(hash);
    List<Imagery> results = rows
        .map((row) => TileImagery.fromJson(row))
        .whereType<Imagery>()
        .toList();
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
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    final imageryId = prefs.getString(kImageryKey);
    if (imageryId != null) {
      if (imageryId == bingImagery.id) {
        await _initializeAndSet(bingImagery);
      } else if (imageryId == maxarPremiumImagery.id) {
        _setDefault(); // yes, we're silently changing the chosen imagery.
      } else if (imageryId == mapboxImagery.id) {
        await _initializeAndSet(mapboxImagery);
      } else if (_additional.any((i) => i.id == imageryId)) {
        await _initializeAndSet(
            _additional.firstWhere((i) => i.id == imageryId));
      } else {
        final imagery =
            await ref.read(presetProvider).singleImageryQuery(imageryId);
        if (imagery != null) {
          await _initializeAndSet(TileImagery.fromJson(imagery));
        }
      }
    }
    loaded = true;
  }

  /// Simply saves the current chosen imagery to shared preferences.
  Future<void> _saveState() async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    await prefs.setString(kImageryKey, state.id);
  }

  /// Sets the default layer. This layer is expected to require
  /// no initialization.
  void _setDefault() {
    state = mapboxImagery;
  }

  /// Sets the layer and calls its initialization method.
  Future<void> _initializeAndSet(Imagery imagery) async {
    await imagery.initialize();
    state = imagery;
  }

  /// Changes the current imagery, notifies listeners, and saves the state.
  Future<void> setImagery(Imagery value) async {
    _initializeAndSet(value);
    _saveState();
  }

  /// Adds the imagery definition to an internal additional imagery
  /// list, to be provided to everywhere. Also if the imagery added
  /// has been stored to preferences, immediately switches to it.
  void registerImagery(Imagery imagery, bool force) async {
    if (!_additional.any((i) => i.id == imagery.id)) {
      _additional.add(imagery);

      if (force) {
        await setImagery(imagery);
      } else {
        final prefs = ref.read(sharedPrefsProvider).requireValue;
        final imageryId = prefs.getString(kImageryKey);
        if (imageryId != null && imageryId == imagery.id) {
          await _initializeAndSet(imagery);
        }
      }
    }
  }

  /// Removes one specific additional imagery entry. Behaves
  /// like [resetImagery], in that it changes state, but does
  /// not save it.
  void unregisterImagery(String imageryId) {
    _additional.removeWhere((i) => i.id == imageryId);
    if (state.id == imageryId) _setDefault();
  }

  /// Called to clear the list of imagery added. Usually called
  /// on plugin de-registration, and some of the imagery can be
  /// immediately reinstated (including the selected one), so
  /// we're changing the state, but not saving it.
  void resetImagery() {
    if (_additional.any((i) => i == state)) _setDefault();
    _additional.clear();
  }

  Future _updateBingUrlTemplate() async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
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
