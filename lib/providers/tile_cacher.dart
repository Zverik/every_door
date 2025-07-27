import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/tile_range.dart';
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tileCacheProvider = StateNotifierProvider<TileCacher, TileCacherState>(
    (ref) => TileCacher(ref));

class TileCacherState {
  final int total;
  final int processed;
  final int downloaded;

  bool get idle => total == 0;
  double get progress => total == 0 ? 0 : processed / total;

  const TileCacherState(
      {required this.total, this.processed = 0, this.downloaded = 0});

  const TileCacherState.idle()
      : total = 0,
        processed = 0,
        downloaded = 0;
}

class TileCacher extends StateNotifier<TileCacherState> {
  static final _logger = Logger('TileCacher');
  static const kMinZoom = 15;
  static const kMaxDownloadTiles = 6000;

  final Ref _ref;
  bool _needStop = false;

  TileCacher(this._ref) : super(TileCacherState.idle());

  Future<int> cacheTiles(
      TileLayer options, LatLngBounds bounds, int zoom) async {
    int downloaded = 0;
    final range = DiscreteTileRange.fromBounds(zoom, bounds);
    for (final coords in range.coordinates) {
      final url = options.tileProvider.getTileUrl(coords, options);
      // Same logic as in CacheManager.getSingleFile().
      final cached =
          null; // await TileCacheManager.instance.getFileFromCache(url);
      if (cached == null || !cached.validTill.isAfter(DateTime.now())) {
        final headers = {
          'User-Agent': 'flutter_map (info.zverev.ilya.every_door; tile_cacher)'
        };
        // await TileCacheManager.instance
        //     .downloadFile(url, authHeaders: headers);
        downloaded += 1;
      }
    }
    return downloaded;
  }

  Future _waitUntilImageryLoaded() async {
    _ref.read(imageryProvider);
    await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
        .then((_) => !_ref.read(imageryProvider.notifier).loaded));
  }

  Future<bool> cacheForAll({int? maxZoom}) async {
    await _waitUntilImageryLoaded();
    final imagery = _ref.read(imageryProvider);
    final base = _ref.read(baseImageryProvider);
    final areas = await _ref.read(downloadedAreaProvider).getAllAreas();
    _needStop = false;

    // First count how many tiles we need to get.
    int total = 0;
    for (final img in [base, imagery]) {
      if (img is! TmsImagery || img.tileSize != 256) continue;
      int layerMaxZoom = maxZoom ?? img.maxZoom;
      if (layerMaxZoom > kMaxBulkDownloadZoom)
        layerMaxZoom = kMaxBulkDownloadZoom;
      for (final area in areas) {
        for (int zoom = kMinZoom; zoom <= layerMaxZoom; zoom++) {
          total += DiscreteTileRange.fromBounds(zoom, area).count;
        }
      }
    }
    _logger.info('Total tiles to download: $total');

    // Now actually download tiles.
    int downloaded = 0;
    int processed = 0;
    state = TileCacherState(total: total);
    for (final img in [base, imagery]) {
      if (img is! TmsImagery || img.tileSize != 256) continue;
      final tileLayer = img.buildLayer();
      if (tileLayer is! TileLayer) continue;

      int layerMaxZoom = maxZoom ?? img.maxZoom;
      if (layerMaxZoom > kMaxBulkDownloadZoom)
        layerMaxZoom = kMaxBulkDownloadZoom;

      for (final area in areas) {
        _logger.info(
            'Downloading $img for area [${area.southWest}, ${area.northEast}]');
        for (int zoom = kMinZoom; zoom <= layerMaxZoom; zoom++) {
          if (_needStop) break;
          try {
            downloaded += await cacheTiles(tileLayer, area, zoom);
          } on Exception catch (e) {
            _logger.severe('Failed to download tiles: $e');
          }
          if (downloaded >= kMaxDownloadTiles) {
            _logger.warning('Incomplete download: tile limit reached');
            state = TileCacherState.idle();
            return false;
          }
          processed += DiscreteTileRange.fromBounds(zoom, area).count;
          state = TileCacherState(
              total: total, downloaded: downloaded, processed: processed);
        }
      }
    }
    state = TileCacherState.idle();
    return true;
  }

  void stop() {
    _needStop = true;
  }
}
