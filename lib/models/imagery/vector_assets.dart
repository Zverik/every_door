// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/vector.dart';
import 'package:every_door/models/imagery/vector/style_reader.dart';

class VectorAssetsImagery extends VectorImagery {
  // We need those to initialize the layer.
  final String stylePath;
  final String? spritesBase;

  VectorAssetsImagery({
    required super.id,
    required this.stylePath,
    this.spritesBase,
    super.fast,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    super.overlay = false,
    super.best = false,
    super.cachingStore = kTileCacheBase,
  });

  @override
  Future<void> initialize() async {
    style ??= await EdStyleReader(url: stylePath)
        .readAssets(spritesBase: spritesBase);
  }
}
