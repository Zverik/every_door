import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:flutter/material.dart' show Widget;
import 'package:flutter_map/flutter_map.dart' show TileLayer;
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:mbtiles/mbtiles.dart';

class MbTilesImagery extends TileImagery {
  final MbTiles mbtiles;

  const MbTilesImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required super.url,
    super.minZoom,
    super.maxZoom,
    super.overlay = false,
    super.best = false,
    super.tileSize = 256,
    required this.mbtiles,
  });

  MbTilesImagery.from(TileImageryData data, {required MbTiles mbtiles})
    : this(
        id: data.id,
        category: data.category,
        name: data.name,
        icon: data.icon,
        attribution: data.attribution,
        overlay: data.overlay,
        best: data.best,
        url: data.url,
        minZoom: data.minZoom,
        maxZoom: data.maxZoom,
        mbtiles: mbtiles,
      );

  @override
  Widget buildLayer({bool reset = false}) {
    return TileLayer(
      urlTemplate: url,
      tileProvider: MbTilesTileProvider(
        mbtiles: mbtiles,
        silenceTileNotFound: false,
      ),
      minNativeZoom: minZoom,
      maxNativeZoom: maxZoom,
      maxZoom: 22,
      tileDimension: tileSize,
      userAgentPackageName: kUserAgentPackageName,
      reset: reset ? tileResetController.stream : null,
    );
  }
}
