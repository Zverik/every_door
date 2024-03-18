import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/providers/legend.dart';
import 'package:every_door/widgets/filter.dart';
import 'package:every_door/widgets/legend.dart';
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
  ConsumerState createState() => _PoiListPageState();
}

class _PoiListPageState extends ConsumerState<PoiListPane> {
  List<LatLng> otherPOI = [];
  List<OsmChange> nearestPOI = [];
  final mapController = AmenityMapController();
  bool farFromUser = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateFarFromUser();
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
    final isMicromapping =
        ref.read(editorModeProvider) == EditorMode.micromapping;
    final filter = ref.read(poiFilterProvider);
    final location = forceLocation ?? ref.read(effectiveLocationProvider)!;
    // Query for amenities around the location.
    final int radius =
        forceRadius ?? (farFromUser ? kFarVisibilityRadius : kVisibilityRadius);
    List<OsmChange> data = await provider.getElements(location, radius);

    // Remove points too far from the user.
    const distance = DistanceEquirectangular();
    data = data
        .where((e) => e.isPoint || e.isArea)
        .where((element) => distance(location, element.location) <= radius)
        .toList();

    // Keep other mode objects to show.
    final otherData = data
        .where((e) {
          switch (e.kind) {
            case ElementKind.amenity:
              return isMicromapping;
            case ElementKind.micro:
              return !isMicromapping;
            default:
              return false;
          }
        })
        .map((e) => e.location)
        .toList();

    // Filter for amenities (or not amenities).
    data = data.where((e) {
      switch (e.kind) {
        case ElementKind.amenity:
          return !isMicromapping;
        case ElementKind.micro:
          return isMicromapping;
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
    // Sort by distance.
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));
    // Trim to 10-20 elements.
    final maxElements = !isMicromapping ? kAmenitiesInList : kMicroStuffInList;
    if (data.length > maxElements) data = data.sublist(0, maxElements);

    // Update the map.
    if (!mounted) return;
    setState(() {
      nearestPOI = data;
      otherPOI = otherData;
    });

    // Update the legend.
    if (isMicromapping) {
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
            builder: (_) => PoiEditorPage(amenity: amenitiesAtCenter.first),
            fullscreenDialog: true,
          ),
        );
        // When finished, reset zoomed in state.
        ref.read(microZoomedInProvider.notifier).state = null;
        updateNearest();
      } else {
        // Multiple amenities: zoom in and enhance.
        ref.read(microZoomedInProvider.notifier).state = area;
        // Disable tracking.
        ref.read(trackingProvider.notifier).state = false;
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

    final Widget bottomPane;
    if (apiStatus != ApiStatus.idle) {
      bottomPane = Expanded(
        flex: isMicromapping || farFromUser ? 10 : 23,
        child: buildApiStatusPane(context, apiStatus),
      );
    } else if (!isMicromapping || isZoomedIn) {
      // We want to constraint vertical size, so that tiles
      // don't take precious space from the map.
      final bottomPaneChild = SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: widget.isWide,
        child: PoiPane(nearestPOI),
      );
      final needMaxMap = isMicromapping || farFromUser;
      final mediaHeight = MediaQuery.of(context).size.height;
      if (widget.isWide || mediaHeight <= 600)
        bottomPane = Expanded(
          flex: needMaxMap ? 10 : 23,
          child: bottomPaneChild,
        );
      else
        bottomPane = SizedBox(
          height: needMaxMap && mediaHeight < 900 ? 300 : 400,
          child: bottomPaneChild,
        );
    } else if (!widget.isWide) {
      bottomPane = LegendPane();
    } else {
      bottomPane = SizedBox(
        child: SingleChildScrollView(
          child: SafeArea(
            left: false,
            bottom: false,
            right: false,
            child: LegendPane(),
          ),
        ),
        width: 200.0,
      );
    }

    return Flex(
      direction: widget.isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 10,
          child: AmenityMap(
            initialLocation: location,
            amenities: nearestPOI,
            otherObjects: otherPOI,
            controller: mapController,
            onDragEnd: (pos) {
              ref.read(effectiveLocationProvider.notifier).set(pos);
            },
            onTap: micromappingTap,
            onFilterTap: isMicromapping
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          color: Colors.white,
                          height: 250.0,
                          padding: EdgeInsets.all(15.0),
                          child: PoiFilterPane(),
                        );
                      },
                    );
                  },
            colorsFromLegend: isMicromapping,
            drawNumbers: !isMicromapping || isZoomedIn,
            drawZoomButtons: isMicromapping || farFromUser,
          ),
        ),
        if (widget.areaStatusPanel != null)
          widget.isWide
              ? RotatedBox(quarterTurns: 3, child: widget.areaStatusPanel!)
              : widget.areaStatusPanel!,
        bottomPane,
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
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }
}
