import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:flutter/material.dart' show Widget;
import 'package:flutter_map/flutter_map.dart'
    show TileLayer, WMSTileLayerOptions, Epsg4326, Epsg3857;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class WmsImagery extends TileImagery {
  final FMTCTileProvider _tileProvider;
  final bool wms4326;

  WmsImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required super.url,
    super.headers,
    super.minZoom,
    super.maxZoom,
    super.overlay = false,
    super.best = false,
    this.wms4326 = false,
  }) : _tileProvider = FMTCTileProvider(
          stores: {kTileCacheImagery: BrowseStoreStrategy.readUpdateCreate},
          headers: headers,
        );

  WmsImagery.from(TileImageryData data, {bool wms4326 = false})
      : this(
          id: data.id,
          category: data.category,
          name: data.name,
          icon: data.icon,
          attribution: data.attribution,
          overlay: data.overlay,
          best: data.best,
          url: data.url,
          headers: data.headers,
          minZoom: data.minZoom,
          maxZoom: data.maxZoom,
          wms4326: wms4326,
        );

  WMSTileLayerOptions _buildWMSOptions(String url) {
    final uri = Uri.parse(url);
    final baseUrl = uri.origin + uri.path + '?';
    final Map<String, String> other = {};
    final params = uri.queryParameters.map(
      (key, value) => MapEntry(key.toLowerCase(), value),
    );
    final version = params['version'] ?? '1.3.0';
    final layers = params['layers']!.split(',');
    final style = params['styles'] ?? '';
    final format = params['format'] ?? 'image/jpeg';
    final transparent = params['transparent']?.toLowerCase() == 'true';
    final crs = wms4326 ? const Epsg4326() : const Epsg3857();

    /*const kRequiredKeys = ['width', 'height', 'bbox', 'service', 'request'];
  for (final k in kRequiredKeys) {
    if (!params.containsKey(k))
      throw ArgumentError('Missing WMS required parameter $k');
  }*/
    const kAllKeys = [
      'service',
      'request',
      'layers',
      'styles',
      'format',
      'crs',
      'srs',
      'version',
      'transparent',
      'width',
      'height',
      'bbox',
    ];
    for (final kv in uri.queryParameters.entries) {
      if (!kAllKeys.contains(kv.key.toLowerCase())) other[kv.key] = kv.value;
    }

    return WMSTileLayerOptions(
      baseUrl: baseUrl,
      version: version,
      layers: layers,
      styles: style.isEmpty ? [] : [style],
      otherParameters: other,
      format: format,
      transparent: transparent,
      crs: crs,
    );
  }

  @override
  Widget buildLayer({bool reset = false}) {
    return TileLayer(
      wmsOptions: _buildWMSOptions(url),
      tileProvider: _tileProvider,
      minNativeZoom: minZoom,
      maxNativeZoom: maxZoom,
      maxZoom: 22,
      tileDimension: tileSize,
      tms: false,
      userAgentPackageName: kUserAgentPackageName,
      reset: reset ? tileResetController.stream : null,
    );
  }
}
