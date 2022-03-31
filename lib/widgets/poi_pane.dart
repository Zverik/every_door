import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'poi_tile.dart';

class PoiPane extends ConsumerStatefulWidget {
  final List<OsmChange> amenities;
  final VoidCallback updateNearest;

  const PoiPane({required this.amenities, required this.updateNearest});

  @override
  ConsumerState<PoiPane> createState() => _PoiPaneState();
}

class _PoiPaneState extends ConsumerState<PoiPane> {
  /// Reorder tiles into vertical orientation.
  List<T> reorderIntoColumns<T>(List<T> tiles) {
    final List<T> result = [];
    // TODO: ?
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    var tiles = widget.amenities.asMap().entries.toList();
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;
    // tiles = reorderIntoColumns(tiles);

    return widget.amenities.isEmpty
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              loc.tileNothingAround(kVisibilityRadius) +
                  '\n' +
                  (hasFilter ? loc.tileDragOrUnfilter : loc.tileDragTheMap),
              style: TextStyle(fontSize: 18.0),
            ),
          ))
        : Container(
            color: Colors.grey.shade100,
            child: ResponsiveGridList(
              minItemWidth: 150.0,
              horizontalGridSpacing: 2,
              verticalGridSpacing: 2,
              rowMainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (final entry in tiles)
                  PoiTile(
                    index: entry.key + 1,
                    amenity: entry.value,
                    onToggleCheck: () {
                      setState(() {
                        entry.value.toggleCheck();
                      });
                      final changes = ref.read(changesProvider);
                      changes.saveChange(entry.value);
                    },
                    onNeedReload: widget.updateNearest,
                  ),
              ],
            ),
          );
  }

  Widget build2(BuildContext context) {
    return widget.amenities.isEmpty
        ? Center(child: Text('Nothing around'))
        : ListView.separated(
            // TODO: two columns?
            itemCount: widget.amenities.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) => PoiTile(
              index: index + 1,
              amenity: widget.amenities[index],
              onToggleCheck: () {
                setState(() {
                  widget.amenities[index].toggleCheck();
                });
                final changes = ref.read(changesProvider);
                changes.saveChange(widget.amenities[index]);
              },
              onNeedReload: widget.updateNearest,
            ),
          );
  }
}
