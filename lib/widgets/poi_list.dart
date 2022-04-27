import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/providers/legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/poi_pane.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;

class PoiListPane extends ConsumerStatefulWidget {
  final Widget? areaStatusPanel;
  final bool isWide;

  const PoiListPane({this.areaStatusPanel, this.isWide = false});

  @override
  _PoiListPageState createState() => _PoiListPageState();
}

class _PoiListPageState extends ConsumerState<PoiListPane> {
  List<OsmChange> allPOI = [];
  List<OsmChange> nearestPOI = [];
  final mapController = AmenityMapController();
  bool farFromUser = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      updateNearest();
    });
  }

  updateFarFromUser() {
    final gpsLocation = ref.read(geolocationProvider);
    bool newFar;
    if (gpsLocation != null) {
      final location = ref.read(effectiveLocationProvider);
      final distance = DistanceEquirectangular();
      newFar = distance(location, gpsLocation) >= kFarDistance;
    } else {
      newFar = true;
    }

    if (newFar != farFromUser) {
      setState(() {
        farFromUser = newFar;
      });
    }
  }

  updateNearest({LatLng? forceLocation, int? forceRadius}) async {
    // Disabling updates in zoomed in mode.
    if (forceLocation == null && ref.read(microZoomedInProvider) != null)
      return;

    final provider = ref.read(osmDataProvider);
    final editorMode = ref.read(editorModeProvider);
    final filter = ref.read(poiFilterProvider);
    final location = forceLocation ?? ref.read(effectiveLocationProvider)!;
    // Query for amenities around the location.
    final int radius =
        forceRadius ?? (farFromUser ? kFarVisibilityRadius : kVisibilityRadius);
    List<OsmChange> data = await provider.getElements(location, radius);
    // Filter for amenities (or not amenities).
    data = data.where((e) {
      switch (e.kind) {
        case ElementKind.amenity:
          return editorMode == EditorMode.poi;
        case ElementKind.micro:
          return editorMode == EditorMode.micromapping;
        case ElementKind.building:
        case ElementKind.entrance:
          return false;
        default:
          return e.isNew;
      }
    }).toList();
    // Apply the building filter.
    if (filter.isNotEmpty) {
      data = data.where((e) => filter.matches(e)).toList();
    }
    // Remove points too far from the user.
    const distance = DistanceEquirectangular();
    data = data
        .where((element) => distance(location, element.location) <= radius)
        .toList();
    // Sort by distance.
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));
    // Trim to 10-20 elements.
    if (data.length > kAmenitiesInList)
      data = data.sublist(0, kAmenitiesInList);
    // Update the map.
    if (!mounted) return;
    setState(() {
      nearestPOI = data;
    });

    if (editorMode == EditorMode.micromapping) {
      final locale = Localizations.localeOf(context);
      ref.read(legendProvider.notifier).updateLegend(data, locale: locale);
    }

    // Zoom automatically only when tracking location.
    if (ref.read(trackingProvider)) {
      mapController.zoomToFit(data.map((e) => e.location));
    }
  }

  micromappingTap(LatLngBounds area) async {
    if (ref.read(editorModeProvider) == EditorMode.micromapping) {
      List<OsmChange> amenitiesAtCenter = nearestPOI
          .where((element) => area.contains(element.location))
          .toList();

      if (amenitiesAtCenter.isEmpty) return;
      if (amenitiesAtCenter.length == 1 ||
          ref.read(microZoomedInProvider) != null) {
        if (amenitiesAtCenter.length > 1) {
          // Sort by distance.
          const distance = DistanceEquirectangular();
          amenitiesAtCenter.sort((a, b) => distance(area.center, a.location)
              .compareTo(distance(area.center, b.location)));
        }
        // Open the editor for the first object.
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PoiEditorPage(amenity: amenitiesAtCenter.first)),
        );
        // When finished, reset zoomed in state.
        ref.read(microZoomedInProvider.state).state = null;
        updateNearest();
      } else {
        // Multiple amenities: zoom in and enhance.
        ref.read(microZoomedInProvider.state).state = area;
        // updateNearest(forceLocation: area.center);
        setState(() {
          nearestPOI = nearestPOI
              .where((element) => area.contains(element.location))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.read(effectiveLocationProvider);
    final isMicromapping =
        ref.watch(editorModeProvider) == EditorMode.micromapping;
    final isZoomedIn = ref.watch(microZoomedInProvider) != null;
    final apiStatus = ref.watch(apiStatusProvider);
    ref.listen(editorModeProvider, (_, next) {
      updateNearest();
    });
    ref.listen(needMapUpdateProvider, (_, next) {
      updateNearest();
    });
    ref.listen(poiFilterProvider, (_, next) {
      updateNearest();
    });
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      mapController.setLocation(next, emitDrag: false, onlyIfFar: true);
      updateFarFromUser();
      updateNearest();
    });
    ref.listen<LatLngBounds?>(microZoomedInProvider, (_, next) {
      // Only update when returning from the mode.
      if (next == null) updateNearest();
    });

    return Flex(
      direction: widget.isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: AmenityMap(
            initialLocation: location,
            amenities: nearestPOI,
            controller: mapController,
            onDragEnd: (pos) {
              ref.read(effectiveLocationProvider.notifier).set(pos);
            },
            onTap: micromappingTap,
            colorsFromLegend: isMicromapping,
            drawNumbers: !isMicromapping || isZoomedIn,
          ),
        ),
        if (widget.areaStatusPanel != null)
          widget.isWide
              ? RotatedBox(quarterTurns: 3, child: widget.areaStatusPanel!)
              : widget.areaStatusPanel!,
        if (!isMicromapping || isZoomedIn)
          Expanded(
            flex: isMicromapping || farFromUser ? 1 : 3,
            child: apiStatus != ApiStatus.idle
                ? buildApiStatusPane(context, apiStatus)
                : PoiPane(nearestPOI),
          ),
        if (isMicromapping && !isZoomedIn && !widget.isWide) LegendPane(),
        if (isMicromapping && !isZoomedIn && widget.isWide)
          SizedBox(child: LegendPane(), width: 200.0),
      ],
    );
  }

  Widget buildApiStatusPane(BuildContext context, ApiStatus apiStatus) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20.0),
        Text(
          getApiStatusLoc(apiStatus, loc),
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }
}

class LegendPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legend = List.of(ref.watch(legendProvider));
    if (legend.isEmpty) return Container();

    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10.0),
      constraints: BoxConstraints(minHeight: 150.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in legend)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: item.color, size: 20.0),
                SizedBox(width: 5.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(item.isOther ? loc.legendOther : item.label,
                        style: kFieldTextStyle),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
