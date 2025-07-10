import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart';

class TileCacheManager {
  static const key = 'tileCache';
  static CacheManager instance = CacheManager(
    Config(key, maxNrOfCacheObjects: 10000, stalePeriod: Duration(days: 120)),
  );
}

class CachedTileProvider extends TileProvider {
  static final _logger = Logger('CachedTileProvider');

  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    // print(url);
    return CachedNetworkImageProvider(
      url,
      cacheManager: TileCacheManager.instance,
      headers: headers,
      errorListener: (e) {
        _logger.warning('Failed to load a tile: $e');
      },
    );
  }
}

class CachedBingTileProvider extends TileProvider {
  CachedBingTileProvider();

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

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      cacheManager: TileCacheManager.instance,
      headers: headers,
    );
  }
}