import 'dart:math' as math;
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
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

  math.Point<int> _coordToTile(LatLng coord, int zoom) {
    final z2 = math.pow(2, zoom);
    final x = z2 * (coord.longitude + 180.0) / 360.0;
    final lat = coord.latitudeInRad;
    final y =
        z2 * (1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2;
    return math.Point(x.floor(), y.floor());
  }

  Future<int> cacheTiles(
      TileLayer options, LatLngBounds bounds, int zoom) async {
    int downloaded = 0;
    final pt1 = _coordToTile(bounds.northWest, zoom);
    final pt2 = _coordToTile(bounds.southEast, zoom);
    for (int x = pt1.x; x <= pt2.x; x++) {
      for (int y = pt1.y; y <= pt2.y; y++) {
        final coords = TileCoordinates(x, y, zoom);
        final url = options.tileProvider.getTileUrl(coords, options);
        // Same logic as in CacheManager.getSingleFile().
        final cached = await TileCacheManager.instance.getFileFromCache(url);
        if (cached == null || !cached.validTill.isAfter(DateTime.now())) {
          final headers = {
            'User-Agent':
                'flutter_map (info.zverev.ilya.every_door; tile_cacher)'
          };
          await TileCacheManager.instance
              .downloadFile(url, authHeaders: headers);
          downloaded += 1;
        }
      }
    }
    return downloaded;
  }

  int _countTiles(LatLngBounds bounds, int zoom) {
    final pt1 = _coordToTile(bounds.northWest, zoom);
    final pt2 = _coordToTile(bounds.southEast, zoom);
    return (pt2.x - pt1.x + 1) * (pt2.y - pt1.y + 1);
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
          total += _countTiles(area, zoom);
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
          processed += _countTiles(area, zoom);
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
