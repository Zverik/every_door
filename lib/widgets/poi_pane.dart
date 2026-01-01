// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/amenity_age.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'poi_tile.dart';

class PoiPane extends ConsumerStatefulWidget {
  final List<Located> amenities;
  final AmenityAgeData? Function(Located)? getAmenityData;
  final Function(Located) onTap;
  final PoiDescriber describer;

  const PoiPane({
    required this.amenities,
    required this.describer,
    required this.onTap,
    this.getAmenityData,
  });

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

  final Map<String, TextSpan> _descriptions = {};

  void _prepareDescriptions() {
    _descriptions.clear();
    for (var amenity in widget.amenities) {
      _descriptions[amenity.uniqueId] = widget.describer.describe(amenity);
    }
  }

  @override
  void initState() {
    super.initState();
    _prepareDescriptions();
  }

  @override
  void didUpdateWidget(covariant PoiPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.amenities.every((a) => _descriptions.containsKey(a.uniqueId))) {
      _prepareDescriptions();
    }
  }

  Widget nothingAroundPane(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;
    final needDownload = ref.read(areaStatusProvider).value != AreaStatus.fresh;

    String message;
    if (needDownload)
      message = loc.tileDragDownload;
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

  void toggleCheck(Located element) async {
    if (element is! OsmChange) return;
    setState(() {
      element.toggleCheck();
    });
    final changes = ref.read(changesProvider);
    await changes.saveChange(element);
    ref.read(needMapUpdateProvider.notifier).trigger();
  }

  Widget buildGridHorizontal(BuildContext context) {
    if (_descriptions.isEmpty) return Container();

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
            for (final entry in widget.amenities.asMap().entries)
              PoiTile(
                index: entry.key + 1,
                description: _descriptions[entry.value.uniqueId]!,
                width: 190.0,
                onToggleCheck: () {
                  toggleCheck(entry.value);
                },
                amenityData: widget.getAmenityData?.call(entry.value),
                onTap: () {
                  widget.onTap(entry.value);
                },
              ),
          ],
        ),
      ),
    );
  }
}
