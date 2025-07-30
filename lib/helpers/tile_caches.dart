import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:http/io_client.dart';

const kTileCacheBase = 'base';
const kTileCacheImagery = 'satellite';
const kTileCacheDownload = 'download';

class CachedBingTileProvider extends FMTCTileProvider {
  CachedBingTileProvider()
      : super(
          stores: {
            kTileCacheImagery: BrowseStoreStrategy.readUpdateCreate,
            kTileCacheDownload: BrowseStoreStrategy.read,
          },
          httpClient: IOClient(),
        );

  String _tileToQuadkey(int x, int y, int z) {
    String quad = '';
    for (int i = z; i > 0; i--) {
      int digit = 0;
      int mask = 1 << (i - 1);
      if ((x & mask) != 0) digit += 1;
      if ((y & mask) != 0) digit += 2;
      quad += digit.toString();
    }
    return quad;
  }

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final quadkey = _tileToQuadkey(
      coordinates.x.round(),
      coordinates.y.round(),
      coordinates.z.round(),
    );
    final tileUrl = super.getTileUrl(coordinates, options);
    return tileUrl
        .replaceFirst('_QUADKEY_', quadkey)
        .replaceFirst('_CULTURE_', 'en');
  }
}
