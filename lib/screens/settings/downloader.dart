import 'package:every_door/constants.dart';
import 'package:every_door/generated/l10n/app_localizations.dart';
import 'package:every_door/helpers/geometry/tile_range.dart';
import 'package:every_door/helpers/tile_calculator.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/downloaders.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:every_door/widgets/tile_bounds_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class TileCacheDownloader extends ConsumerStatefulWidget {
  const TileCacheDownloader({super.key});

  @override
  ConsumerState<TileCacheDownloader> createState() =>
      _TileCacheDownloaderState();
}

class _TileCacheDownloaderState extends ConsumerState<TileCacheDownloader> {
  static const kBaseZoom = 15; // 85 tiles to zoom 18, ~1 km on side
  static const kMaxTilesToDownload = 20;

  final Set<Tile> _selected = {};
  final List<LatLngBounds> _areas = [];

  @override
  void initState() {
    super.initState();
    _updateDownloadedAreas();
  }

  Future<void> _updateDownloadedAreas() async {
    final areas = await ref.read(downloadedAreaProvider).getAllAreas();
    _areas.clear();
    _areas.addAll(areas);
    setState(() {});
  }

  bool _needDownloadData() {
    if (_selected.isEmpty) return false;
    if (_areas.isEmpty) return true;

    //  This list contains parts that are not covered by any area.
    Iterable<LatLngBounds> tileBounds =
        _selected.map((tile) => tile.tileBounds());

    for (final area in _areas) {
      // Now we cut each part with the area that we've got.
      final newBounds = <LatLngBounds>[];
      for (final part in tileBounds) newBounds.addAll(part.difference(area));
      tileBounds = newBounds;

      // If areas cover all the parts, the resulting list would be empty.
      if (tileBounds.isEmpty) return false;
    }

    // Since some parts were left, we need to download data.
    return true;
  }

  Iterable<DiscreteTileRange> _groupTiles() {
    // Very simple greedy algorithm.
    // Complexity: O(tiles * log(tiles)), quadratic worst case.

    // Better algorithms (with complexity O(grid size * tiles)):
    // 1. https://leetcode.com/problems/maximal-rectangle/solutions/5014890/faster-lesser-detailed-explaination-stack-height-step-by-step-explaination-python-java/
    // 2. https://bravenewmethod.com/2015/01/18/finding-maximal-rectangles-in-a-grid/
    // 3. https://discussions.unity.com/t/largest-rectangle-of-tiles/185528

    Set<Tile> tiles = Set.of(_selected);
    final ranges = <DiscreteTileRange>[];
    while (tiles.isNotEmpty) {
      // 1. Find the top left tile.
      Tile tile = tiles.first;
      for (final nextTile in tiles) {
        if (nextTile.y < tile.y ||
            (nextTile.y == tile.y && nextTile.x < tile.x)) tile = nextTile;
      }

      // 2. Find the x for the rightmost tile extending from this one.
      Tile rightTile = Tile(tile.x + 1, tile.y, tile.zoom);
      while (tiles.contains(rightTile)) {
        rightTile = Tile(rightTile.x + 1, tile.y, tile.zoom);
      }
      int rightX = rightTile.x - 1;

      // 3. Having the horizontal range, check tiles below to form a rectangle.
      Tile topTile = Tile(tile.x, tile.y + 1, tile.zoom);
      while (tiles.contains(topTile)) {
        if (topTile.x < rightX) {
          topTile = Tile(topTile.x + 1, topTile.y, tile.zoom);
        } else {
          topTile = Tile(tile.x, topTile.y + 1, tile.zoom);
        }
      }

      // 4. We were scanning left to right and top to bottom, and found
      // a missing tile. Now walk back a bit.
      topTile = Tile(rightX, topTile.y - 1, tile.zoom);

      // 5. We've found a rectangle between tile and topTile.
      // Register it and remove the tiles.
      final range = DiscreteTileRange(tile.zoom, tile, topTile);
      tiles.removeAll(range.tiles);
      ranges.add(range);
    }
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final base = ref.watch(baseImageryProvider);
    final imagery = ref.watch(imageryProvider);

    ref.listen(downloadedAreaProvider, (o, n) {
      _updateDownloadedAreas();
    });

    Widget? osmButton;
    Widget? baseButton;
    Widget? imageryButton;

    final osmDownloadStatus = ref.watch(osmDataDownloadProvider);
    if (_needDownloadData() ||
        _selected.isEmpty ||
        osmDownloadStatus.downloading) {
      // We're at the OSM download stage.
      if (osmDownloadStatus.downloading) {
        // When downloading, display a cancel button and the download progress.
        osmButton = ElevatedButton(
          child: Text('Cancel (${osmDownloadStatus.percent}%)'),
          onPressed: () {
            ref.read(osmDataDownloadProvider.notifier).cancel();
          },
        );
      } else {
        // Not started yet, and ready to download (or no tiles selected).
        osmButton = ElevatedButton(
          child: Text('Download Data'),
          onPressed: _selected.isEmpty
              ? null
              : () {
                  ref
                      .read(osmDataDownloadProvider.notifier)
                      .start(_groupTiles().map((r) => r.toBounds()));
                },
        );
      }
    } else {
      final baseStatus = ref.watch(imageryDownloadProvider(base));
      final imageryStatus = ref.watch(imageryDownloadProvider(imagery));

      if (baseStatus.downloading) {
        baseButton = ElevatedButton(
          child: Text('Cancel (${baseStatus.percent}%)'),
          onPressed: () {
            ref.read(imageryDownloadProvider(base).notifier).cancel();
          },
        );
      } else {
        bool canDownload =
            ref.read(imageryDownloadProvider(base).notifier).canDownload();
        baseButton = ElevatedButton(
          child: Text('Download Map Tiles'),
          onPressed: !canDownload
              ? null
              : () {
                  ref
                      .read(imageryDownloadProvider(base).notifier)
                      .start(_selected);
                },
        );
      }

      // Now absolutely the same for satellite imagery.
      if (imageryStatus.downloading) {
        imageryButton = ElevatedButton(
          child: Text('Cancel (${imageryStatus.percent}%)'),
          onPressed: () {
            ref.read(imageryDownloadProvider(imagery).notifier).cancel();
          },
        );
      } else {
        bool canDownload =
            ref.read(imageryDownloadProvider(imagery).notifier).canDownload();
        imageryButton = ElevatedButton(
          child: Text('Download Satellite'),
          onPressed: !canDownload
              ? null
              : () {
                  ref
                      .read(imageryDownloadProvider(imagery).notifier)
                      .start(_selected);
                },
        );
      }

      // TODO: what about overlays?
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Download Tiles'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: ref.watch(effectiveLocationProvider),
                initialZoom: 14.0,
                minZoom: 10.0,
                maxZoom: 16.0,
                initialRotation: ref.watch(rotationProvider),
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all -
                      InteractiveFlag.rotate -
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: [
                base.buildLayer(reset: true),
                ...ref.watch(overlayImageryProvider),
                AttributionWidget(imagery),
                PolygonLayer(
                  polygons: [
                    for (final area in _areas)
                      Polygon(
                        points: area.toPoints(),
                        color: Colors.green.withValues(alpha: 0.1),
                        borderColor: Colors.green.shade800,
                        borderStrokeWidth: 3.0,
                      ),
                  ],
                ),
                TileBoundsGrid(
                  tileZoom: kBaseZoom,
                  fill: Map.fromEntries(_selected.map((tile) =>
                      MapEntry(tile, Colors.blue.withValues(alpha: 0.7)))),
                  onTap: (point, doSet) {
                    if (doSet) {
                      if (_selected.length >= kMaxTilesToDownload &&
                          !_selected.contains(point)) {
                        // Maximum tiles reached, display an error panel.
                        // TODO
                      } else {
                        if (_selected.add(point)) setState(() {});
                      }
                    } else {
                      if (_selected.remove(point)) setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10.0,
            children: [
              if (_selected.isEmpty)
                TextButton(child: Text('Select tiles to download', style: kFieldTextStyle,), onPressed: null),
              if (osmButton != null && _selected.isNotEmpty) osmButton,
              if (baseButton != null) baseButton,
              if (imageryButton != null) imageryButton,
            ],
          ),
        ],
      ),
    );
  }
}

extension BoundPoints on LatLngBounds {
  List<LatLng> toPoints() {
    return [northWest, northEast, southEast, southWest];
  }

  /// Returns zero to four parts made by cutting out [other] from
  /// this polygon. Useful to check for coverage: each area cuts some,
  /// and we need to check whether anything is left.
  List<LatLngBounds> difference(LatLngBounds other) {
    if (other.containsBounds(this)) return [];
    if (!isOverlapping(other)) return [this];
    final parts = <LatLngBounds>[];

    // Tiles run left to right.
    double newWest = west;
    if (other.west > west && other.west < east) {
      parts.add(LatLngBounds(southWest, LatLng(north, other.west)));
      newWest = other.west;
    }
    double newEast = east;
    if (other.east < east && other.east > west) {
      parts.add(LatLngBounds(LatLng(north, other.east), southEast));
      newEast = other.east;
    }

    // Tiles run top to bottom.
    if (other.north > north && other.north < south) {
      parts.add(LatLngBounds(
        LatLng(north, newWest),
        LatLng(other.north, newEast),
      ));
    }
    if (other.south < south && other.south > north) {
      parts.add(LatLngBounds(
        LatLng(other.south, newWest),
        LatLng(south, newEast),
      ));
    }

    // If parts is empty, this means there's a miss.
    return parts.isEmpty ? [this] : parts;
  }
}
