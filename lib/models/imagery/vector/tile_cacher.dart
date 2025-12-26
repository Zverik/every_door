// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Image, instantiateImageCodec, ImageByteFormat;

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_calculator.dart';
import 'package:every_door/models/imagery/vector/cache_kinds.dart';
import 'package:flutter/services.dart'
    show BackgroundIsolateBinaryMessenger, RootIsolateToken;
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
    _storageCache = StorageCache(
        cacheStorage, Duration(days: 60), kVectorCacheSizeMB * 1024 * 1024);
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

Future<Map<CachedFileKind, int>> measureVectorCache() async {
  final vectorStorage = createByteStorage(null);
  final entries = await vectorStorage.list();
  final result = <CachedFileKind, int>{};
  for (final entry in entries) {
    final kind = CachedFileKind.match(entry.path);
    result[kind] = (result[kind] ?? 0) + entry.size;
  }
  return result;
}

Future<void> clearVectorCache(bool everything) async {
  final vectorStorage = createByteStorage(null);
  final entries = await vectorStorage.list();
  for (final entry in entries) {
    final kind = CachedFileKind.match(entry.path);
    if (everything || kind == CachedFileKind.rendered) {
      await vectorStorage.delete(entry.path);
    }
  }

  // Let's not clear style cache, for it is not reloaded in this session.
  // await StyleCache.instance.clear();
}

class CacheSizeWatchdogSettings {
  final int sizeLimitMB;
  final int targetSizeMB;
  final Duration interval;
  final RootIsolateToken rootIsolateToken;

  const CacheSizeWatchdogSettings({
    this.sizeLimitMB = kVectorCacheSizeMB - 5,
    this.targetSizeMB = kVectorCacheSizeMB - 10,
    this.interval = const Duration(minutes: 10),
    required this.rootIsolateToken,
  });
}

/// This function keeps the vector tile storage under the size limit.
/// It runs indefinitely and is intended to be started in an isolate.
/// Better keep the [sizeLimitMB] a bit under the default or specified
/// limit, e.g. at 40.
void persistentCacheSizeWatchdog(CacheSizeWatchdogSettings settings) async {
  // Path Provider calls a native function.
  BackgroundIsolateBinaryMessenger.ensureInitialized(settings.rootIsolateToken);

  final storage = createByteStorage(null);
  final sizeLimit = settings.sizeLimitMB * 1024 * 1024;
  final targetSize = settings.targetSizeMB * 1024 * 1024;

  while (true) {
    final entries = await storage.list();
    int size = entries.isEmpty
        ? 0
        : entries.map((e) => e.size).reduce((a, b) => a + b);

    if (size > sizeLimit) {
      final rankedEntries = entries.sorted((a, b) {
        final kindA = CachedFileKind.match(a.path);
        final kindB = CachedFileKind.match(b.path);
        if (kindA != kindB) {
          return kindB.compareTo(kindA);
        }
        return a.accessed.compareTo(b.accessed);
      });

      for (final entry in rankedEntries) {
        try {
          await storage.delete(entry.path);
          size -= entry.size;
          if (size <= targetSize) {
            break;
          }
        } catch (e) {
          // ignore, race condition file was deleted
        }
      }
    }

    await Future.delayed(settings.interval);
  } // infinite loop
}

// A small bit of `iterable_extensions.dart` that we use here.
extension SortingIterable<T> on Iterable<T> {
  List<T> sorted([Comparator<T>? compare]) => [...this]..sort(compare);
}
