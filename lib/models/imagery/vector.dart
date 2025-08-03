import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/vector/style_reader.dart';
import 'package:every_door/models/plugin.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class VectorImagery extends Imagery {
  static final _logger = Logger('VectorImagery');
  Style? style;
  final bool fast;

  // We need those to initialize the layer.
  final String? url;
  final String? apiKey;
  final Plugin? plugin;
  final Map<String, String>? headers;

  VectorImagery({
    required super.id,
    this.style,
    this.fast = true,
    this.url,
    this.apiKey,
    this.plugin,
    this.headers,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    super.overlay = false,
    super.best = false,
    String cachingStore = kTileCacheImagery,
  });

  @override
  Future<void> initialize() async {
    if (style == null && url != null) {
      style = await EdStyleReader(
        url: url!,
        apiKey: apiKey,
        plugin: plugin,
        httpHeaders: headers,
      ).read();
    }
  }

  @override
  Widget buildLayer({bool reset = false}) {
    final style = this.style;
    if (style == null) {
      _logger.warning('Non-initialized vector layer: $id');
      return Container();
    }

    return VectorTileLayer(
      theme: style.theme,
      tileProviders: style.providers,
      sprites: style.sprites,
      maximumZoom: 22.0,
      fileCacheMaximumSizeInBytes: kVectorCacheSizeMB * 1024 * 1024,
      // Vector looks cooler, but super slow on far zooms.
      layerMode: fast ? VectorTileLayerMode.raster : VectorTileLayerMode.vector,
    );
  }
}
