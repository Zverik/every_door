import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Image, instantiateImageCodec, ImageByteFormat;

import 'package:every_door/helpers/tile_calculator.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles/src/grid/slippy_map_translator.dart';
import 'package:vector_map_tiles/src/cache/storage_cache.dart';
import 'package:vector_map_tiles/src/cache/byte_storage_factory_io.dart';

class VectorTileCacher {
  final Style style;
  late final StorageCache _storageCache;

  VectorTileCacher(this.style) {
    final cacheStorage =
        createByteStorage(null); // We do not override the cache folder
    _storageCache =
        StorageCache(cacheStorage, Duration(days: 60), 50 * 1024 * 1024);
  }

  Future<void> cacheTile(Tile tile) async {
    final identity = TileIdentity(tile.zoom, tile.x, tile.y);
    await Future.wait([
      _cacheVectorTiles(identity),
      _cacheRasterTiles(identity),
    ]);
  }

  String _toKey(String source, TileIdentity id, String ext) =>
      '${id.z}_${id.x}_${id.y}_$source.$ext';

  // Basically [_tileSupplier] from [VectorTileCompositeLayer].
  Future<void> _cacheVectorTiles(TileIdentity tile) async {
    for (final source in style.theme.tileSources) {
      final provider = style.providers.tileProviderBySource[source];
      if (provider == null ||
          provider.type != TileProviderType.vector ||
          tile.z < provider.minimumZoom) {
        return;
      }

      final desiredZoom = min(
          max(tile.z + provider.tileOffset.zoomOffset, provider.minimumZoom),
          provider.maximumZoom);
      if (desiredZoom > tile.z) {
        return;
      }

      String dataKey = _toKey(source, tile, 'pbf');
      var tileToLoad = tile;
      if (tile.z != desiredZoom) {
        final translator = SlippyMapTranslator(desiredZoom);
        final translation = translator.translate(tile);
        tileToLoad = translation.translated;
        dataKey = _toKey(source, tileToLoad, 'pbf');
      }

      try {
        var bytes = await _storageCache.retrieve(dataKey);
        if (bytes == null) {
          bytes = await provider.provide(tile);
          await _storageCache.put(dataKey, bytes);
        }
      } on ProviderException catch (error) {
        if (error.statusCode == 404 || error.statusCode == 204) {
          return;
        }
        rethrow;
      }
    }
  }

  // This is [ImageLoadingCache] inside [RasterTileProvider].
  Future<void> _cacheRasterTiles(TileIdentity tile) async {
    final rasterProviders = style.providers.tileProviderBySource.entries
        .where((e) => e.value.type == TileProviderType.raster);
    for (final entry in rasterProviders) {
      final source = entry.key;
      final provider = entry.value;

      final zoom = tile.z;
      if (zoom < provider.minimumZoom) {
        return;
      }
      var translation = TileTranslation.identity(tile.normalize());
      if (zoom > provider.maximumZoom) {
        final translator = SlippyMapTranslator(provider.maximumZoom);
        translation = translator.specificZoomTranslation(translation.original,
            zoom: provider.maximumZoom);
      }
      final translated = translation.translated;

      // [ImageLoadingCache]
      final key = _toKey(source, translated, 'png');
      var bytes = await _storageCache.retrieve(key);
      if (bytes == null) {
        bytes = await provider.provide(translated);
        try {
          final image = await _imageFrom(bytes: bytes);
          await _putQuietly(key, image);
        } catch (_) {
          try {
            await _storageCache.remove(key);
          } catch (_) {}
          rethrow;
        }
      }
    }
  }

  Future<Image> _imageFrom({required Uint8List bytes}) async {
    final codec = await instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  Future _putQuietly(String key, Image image) async {
    Image cloned = image.clone();
    try {
      final bytes = await cloned.toByteData(format: ImageByteFormat.png);
      if (bytes != null) {
        await _storageCache.put(key, bytes.buffer.asUint8List());
      }
    } catch (_) {
      // nothing to do
    } finally {
      cloned.dispose();
    }
  }
}
