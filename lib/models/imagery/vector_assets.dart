import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/vector.dart';
import 'package:every_door/models/imagery/vector/style_reader.dart';
import 'package:every_door/models/plugin.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class VectorAssetsImagery extends VectorImagery {
  static final _logger = Logger('VectorAssetsImagery');

  // We need those to initialize the layer.
  final String stylePath;
  final String spritesBase;

  VectorAssetsImagery({
    required super.id,
    required this.stylePath,
    required this.spritesBase,
    super.fast,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    super.overlay = false,
    super.best = false,
  });

  @override
  Future<void> initialize() async {
    style ??= await EdStyleReader(url: stylePath)
        .readAssets(spritesBase: spritesBase);
  }

  @override
  Widget buildLayer({bool reset = false}) {
    final style = this.style;
    if (style == null) {
      _logger.severe('Non-initialized vector layer: $id');
      return Container();
    }

    return VectorTileLayer(
      theme: style.theme,
      tileProviders: style.providers,
      sprites: style.sprites,
      maximumZoom: 22.0,
      // Vector looks cooler, but super slow on far zooms.
      layerMode: fast ? VectorTileLayerMode.raster : VectorTileLayerMode.vector,
    );
  }
}
