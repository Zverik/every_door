import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'poi_tile.dart';

class PoiPane extends ConsumerStatefulWidget {
  final List<OsmChange> amenities;
  final Function(OsmChange, int)? isCountedOld;

  const PoiPane(this.amenities, {this.isCountedOld});

  @override
  ConsumerState<PoiPane> createState() => _PoiPaneState();
}

class _PoiPaneState extends ConsumerState<PoiPane> {
  @override
  Widget build(BuildContext context) {
    return widget.amenities.isEmpty
        ? nothingAroundPane(context)
        : Container(
            color: Colors.grey.shade100,
            child: buildGridHorizontal(context),
          );
  }

  Widget nothingAroundPane(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;
    final needDownload = ref.read(areaStatusProvider).value != AreaStatus.fresh;

    String message;
    if (needDownload)
      message = "Try tapping the download button"; // TODO: better words and loc
    else if (hasFilter)
      message = loc.tileDragOrUnfilter;
    else
      message = loc.tileDragTheMap;

    return Center(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        loc.tileNothingAround(kVisibilityRadius) + '\n' + message,
        style: TextStyle(fontSize: 18.0),
        textAlign: TextAlign.center,
      ),
    ));
  }

  void toggleCheck(OsmChange element) {
    setState(() {
      element.toggleCheck();
    });
    final changes = ref.read(changesProvider);
    changes.saveChange(element);
  }

  Widget buildGridHorizontal(BuildContext context) {
    var tiles = widget.amenities.asMap().entries.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SafeArea(
        left: false,
        top: false,
        bottom: false,
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.start,
          runSpacing: 2.0,
          spacing: 2.0,
          children: [
            for (final entry in tiles)
              PoiTile(
                index: entry.key + 1,
                amenity: entry.value,
                width: 190.0,
                onToggleCheck: () {
                  toggleCheck(entry.value);
                },
                isCountedOld: widget.isCountedOld,
              ),
          ],
        ),
      ),
    );
  }
}
