import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;

class BingImagery extends TmsImagery {
  final _tileProvider = CachedBingTileProvider();

  BingImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required super.url,
    super.minZoom,
    super.maxZoom,
    super.best = false,
    super.tileSize = 256,
    super.encrypted = false,
  });

  @override
  TmsImagery copyWith({
    String? url,
    int? tileSize,
    String? attribution,
    int? minZoom,
    int? maxZoom,
  }) {
    return BingImagery(
      id: id,
      category: category,
      name: name,
      attribution: attribution ?? this.attribution,
      icon: icon,
      url: url ?? this.url,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      best: best,
      tileSize: tileSize ?? this.tileSize,
    );
  }

  @override
  TileProvider getTileProvider() => _tileProvider;

  @override
  String prepareUrl() {
    return ImageryProvider.bingUrlTemplate
            ?.replaceFirst('{quadkey}', '_QUADKEY_')
            .replaceFirst('{culture}', '_CULTURE_') ??
        '';
  }
}
