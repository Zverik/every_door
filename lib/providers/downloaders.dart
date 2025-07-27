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
import 'package:flutter_riverpod/flutter_riverpod.dart';

final osmDataDownloadProvider =
    NotifierProvider<OsmDataDownloadNotifier, DownloadingState>(
        OsmDataDownloadNotifier.new);

final imageryDownloadProvider =
    NotifierProvider.family<TileDownloadNotifier, DownloadingState, Imagery>(
        TileDownloadNotifier.new);

class DownloadingState {
  final int total;
  final int processed;
  final int downloaded;
  final bool downloading;

  bool get idle => total == 0;
  int get percent => total == 0 ? 0 : (100 * processed / total).round();

  const DownloadingState({
    required this.total,
    this.processed = 0,
    this.downloaded = 0,
    this.downloading = true,
  });

  const DownloadingState.idle()
      : total = 0,
        processed = 0,
        downloaded = 0,
        downloading = false;
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
    for (final bounds in boundsList) {
      await dataProvider.downloadInBounds(bounds);
      await noteProvider.downloadNotesInBounds(bounds);
      count += 1;
      state = DownloadingState(
          total: boundsList.length, processed: count, downloaded: count);
      if (_needStop) break;
    }
    ref.read(presetProvider).clearFieldCache();
    ref.read(presetProvider).cacheComboOptions();
    state = DownloadingState(
        total: boundsList.length,
        processed: count,
        downloaded: count,
        downloading: false);
  }
}

class TileDownloadNotifier extends FamilyNotifier<DownloadingState, Imagery> {
  @override
  DownloadingState build(Imagery imagery) => DownloadingState.idle();

  bool canDownload() {
    return arg is TmsImagery ||
        arg is WmsImagery ||
        arg is BingImagery ||
        arg is VectorImagery;
  }

  void start(Iterable<Tile> tiles) {
    if (state.downloading) throw StateError('Data is already downloading');

    if (arg is TmsImagery || arg is WmsImagery || arg is BingImagery) {
      _startRasterDownload();
    } else if (arg is VectorImagery) {
      _startVectorDownload();
    } else {
      throw ArgumentError(
          'Unsupported imagery type for downloading: ${arg.runtimeType}');
    }
  }

  void cancel() {}

  void _startRasterDownload() {}

  void _startVectorDownload() {}
}
