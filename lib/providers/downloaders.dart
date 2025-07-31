import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/helpers/tile_calculator.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/bing.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/models/imagery/vector.dart';
import 'package:every_door/models/imagery/wms.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final osmDataDownloadProvider =
    NotifierProvider<OsmDataDownloadNotifier, DownloadingState>(
        OsmDataDownloadNotifier.new);

final imageryDownloadProvider =
    NotifierProvider.family<TileDownloadNotifier, DownloadingState, Imagery>(
        TileDownloadNotifier.new);

/// State of the ongoing download, or an idle state.
class DownloadingState {
  /// Total number of tiles to download, or zero, if it's idle.
  final int total;

  /// Number of tiles processed: skipped, failed, or downloaded.
  final int processed;

  /// Number of tiles successfully downloaded from the server.
  final int downloaded;

  /// Whether a downloading process is active.
  final bool downloading;

  /// An error message, is there was an error.
  final String? error;

  /// Whether a downloading process is active. Accounts for both [downloading]
  /// and [total] being zero.
  bool get idle => total == 0 || !downloading;

  /// An integer percent to display.
  int get percent => total == 0 ? 0 : (100 * processed / total).round();

  const DownloadingState({
    required this.total,
    this.processed = 0,
    this.downloaded = 0,
    this.downloading = true,
    this.error,
  });

  DownloadingState withError(String error) => DownloadingState(
        total: total,
        processed: processed,
        downloaded: downloaded,
        downloading: false,
        error: error,
      );

  const DownloadingState.idle()
      : total = 0,
        processed = 0,
        downloaded = 0,
        downloading = false,
        error = null;

  @override
  String toString() => idle
      ? 'DownloadingState(total: $total, downloading: $downloading, error: $error)'
      : 'DownloadingState(total: $total, processed: $processed, downloaded: $downloaded)';
}

class OsmDataDownloadNotifier extends Notifier<DownloadingState> {
  bool _needStop = false;

  @override
  DownloadingState build() => DownloadingState.idle();

  void start(Iterable<LatLngBounds> boundsList) {
    if (state.downloading) throw StateError('Data is already downloading');
    if (ref.read(apiStatusProvider) != ApiStatus.idle)
      throw StateError('Data download is in progress');
    _startDownload(boundsList);
  }

  void cancel() {
    _needStop = true;
  }

  Future<void> _startDownload(Iterable<LatLngBounds> boundsList) async {
    _needStop = false;
    state = DownloadingState(total: boundsList.length);
    final dataProvider = ref.read(osmDataProvider);
    final noteProvider = ref.read(notesProvider);
    int count = 0;
    try {
      for (final bounds in boundsList) {
        await dataProvider.downloadInBounds(bounds);
        await noteProvider.downloadNotesInBounds(bounds);
        count += 1;
        state = DownloadingState(
            total: boundsList.length, processed: count, downloaded: count);
        if (_needStop) break;
      }

      state = DownloadingState(
          total: boundsList.length,
          processed: count,
          downloaded: count,
          downloading: false);
    } on Exception catch (e) {
      state = state.withError(e.toString());
    } finally {
      ref.read(presetProvider).clearFieldCache();
      ref.read(presetProvider).cacheComboOptions();
    }
  }
}

class TileDownloadNotifier extends FamilyNotifier<DownloadingState, Imagery> {
  static final _logger = Logger('TileDownloadNotifier');

  @override
  DownloadingState build(Imagery imagery) => DownloadingState.idle();

  bool canDownload() {
    return arg is TmsImagery ||
        arg is WmsImagery ||
        arg is BingImagery ||
        arg is VectorImagery;
  }

  void start(Iterable<Tile> tiles) {
    if (tiles.isEmpty) return;
    if (state.downloading) throw StateError('Data is already downloading');

    if (arg is TmsImagery || arg is WmsImagery) {
      _startRasterDownload(tiles);
    } else if (arg is VectorImagery) {
      _startVectorDownload(tiles);
    } else {
      throw ArgumentError(
          'Unsupported imagery type for downloading: ${arg.runtimeType}');
    }
  }

  void cancel() {
    FMTCStore(kTileCacheDownload).download.cancel();
  }

  void _startRasterDownload(Iterable<Tile> tiles) async {
    final region = MultiRegion(
        tiles.map((tile) => RectangleRegion(tile.tileBounds())).toList());
    final downloadable = region.toDownloadable(
        minZoom: kMinBulkDownloadZoom,
        maxZoom: kMaxBulkDownloadZoom,
        options: _unwrapFMTCTileProvider(arg.buildLayer() as TileLayer));
    // await FMTCStore(kTileCacheDownload).download.cancel();
    final progress = FMTCStore(kTileCacheDownload)
        .download
        .startForeground(
          region: downloadable,
          parallelThreads: 1,
          maxBufferLength: 10,
          skipExistingTiles: true,
          skipSeaTiles: false,
          retryFailedRequestTiles: true,
          disableRecovery: true,
        )
        .downloadProgress;

    progress.listen(
      (dp) {
        state = DownloadingState(
          total: dp.maxTilesCount,
          downloaded: dp.flushedTilesCount,
          processed: dp.attemptedTilesCount,
          downloading: true,
        );
        _logger.info(state);
      },
      onError: (error) {
        state = state.withError(error?.toString() ?? "unknown");
        _logger.warning(state);
      },
      onDone: () {
        state = DownloadingState.idle();
      },
      cancelOnError: true,
    );
  }

  void _startVectorDownload(Iterable<Tile> tiles) {
    for (int zoom = tiles.first.zoom; zoom <= kMaxBulkDownloadZoom; zoom++) {
      // TODO
    }
  }
}

// TODO: remove when https://github.com/JaffaKetchup/flutter_map_tile_caching/issues/193 is fixed
TileLayer _unwrapFMTCTileProvider(TileLayer layer) {
  final provider = layer.tileProvider;
  if (provider is! FMTCTileProvider) return layer;
  final rawProvider = NetworkTileProvider(
    headers: provider.headers,
    cachingProvider: DisabledMapCachingProvider(),
  );
  return TileLayer(
    tileProvider: rawProvider,
    wmsOptions: layer.wmsOptions,
    urlTemplate: layer.urlTemplate,
    minZoom: layer.minZoom,
    maxZoom: layer.maxZoom,
    maxNativeZoom: layer.maxNativeZoom,
    tileDimension: layer.tileDimension,
    subdomains: layer.subdomains,
    zoomOffset: layer.zoomOffset,
    tms: layer.tms,
    tileBounds: layer.tileBounds,
  );
}
