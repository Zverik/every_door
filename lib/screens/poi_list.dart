import 'package:every_door/constants.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/lifecycle.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/widgets/filter.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/poi_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class PoiListPage extends ConsumerStatefulWidget {
  const PoiListPage();

  @override
  _PoiListPageState createState() => _PoiListPageState();
}

class _PoiListPageState extends ConsumerState<PoiListPage> {
  List<OsmChange> allPOI = [];
  List<OsmChange> nearestPOI = [];
  final mapController = AmenityMapController();
  late LifecycleEventHandler lifecycleObserver;
  AreaStatus areaStatus = AreaStatus.fresh;
  bool farFromUser = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      updateNearest();
      updateAreaStatus();
    });

    lifecycleObserver = LifecycleEventHandler(
      detached: () async {
        try {
          if (kUploadOnClose) {
            final provider = ref.read(osmApiProvider);
            await provider.uploadChanges();
          }
        } on Exception {
          // No point in catching anything.
        }
      },
    );
    WidgetsBinding.instance?.addObserver(lifecycleObserver);
  }

  @override
  dispose() {
    WidgetsBinding.instance?.removeObserver(lifecycleObserver);
    super.dispose();
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

  downloadAmenities(LatLng location) async {
    final provider = ref.read(osmDataProvider);
    await provider.downloadAround(location);
    updateNearest();
    updateAreaStatus();
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
    data = data
        .where((e) =>
            e.isModified ||
            (editorMode == EditorMode.micromapping
                ? (e.element?.isMicro ?? true)
                : (e.element?.isAmenity ?? true)))
        .toList();
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
    setState(() {
      nearestPOI = data;
    });

    // Zoom automatically only when tracking location.
    if (ref.read(trackingProvider)) {
      mapController.zoomToFit(data.map((e) => e.location));
    }
  }

  updateAreaStatus() async {
    final area = ref.read(downloadedAreaProvider);
    final location = ref.read(effectiveLocationProvider);
    final bbox = boundsFromRadius(location, kVisibilityRadius);
    final status = await area.getAreaStatus(bbox);
    if (status != areaStatus) {
      setState(() {
        areaStatus = status;
      });
    }
  }

  uploadChanges(BuildContext context) async {
    if (ref.read(authProvider) == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OsmAccountPage()));
      return;
    }

    ref.read(apiStatusProvider.notifier).state = ApiStatus.uploading;
    try {
      int count = await ref.read(osmApiProvider).uploadChanges(true);
      AlertController.show(
          'Uploaded', 'Sent $count changes to API.', TypeAlert.success);
    } on Exception catch (e) {
      // TODO: prettify the message?
      AlertController.show('Upload failed', e.toString(), TypeAlert.error);
    } finally {
      ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }

  micromappingTap(LatLngBounds area) async {
    if (ref.read(editorModeProvider) == EditorMode.micromapping) {
      // TODO: check if there is but one amenity there.
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
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PoiEditorPage(amenity: amenitiesAtCenter.first)),
        );
        // When finished, reset zoomed in state.
        ref.read(microZoomedInProvider.state).state = null;
        if (result == true) updateNearest();
      } else {
        ref.read(microZoomedInProvider.state).state = area;
        updateNearest(forceLocation: area.center);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.read(effectiveLocationProvider);
    final editorMode = ref.watch(editorModeProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;
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
      updateAreaStatus();
    });

    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        if (ref.read(microZoomedInProvider) != null) {
          ref.read(microZoomedInProvider.state).state = null;
          return false;
        } else if (!ref.read(trackingProvider)) {
          ref.read(trackingProvider.state).state = true;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(kAppTitle),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(location)),
              );
            },
            icon: Icon(Icons.menu),
          ),
          actions: [
            if (!hasChangesToUpload)
              IconButton(
                onPressed: apiStatus != ApiStatus.idle
                    ? null
                    : () {
                        downloadAmenities(location);
                      },
                icon: Icon(Icons.download),
              ),
            if (hasChangesToUpload)
              IconButton(
                onPressed: () async {
                  uploadChanges(context);
                },
                icon: Icon(Icons.upload, color: Colors.yellowAccent),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  ref.read(selectedImageryProvider.notifier).toggle();
                });
              },
              icon: Icon(ref.watch(selectedImageryProvider) == kOSMImagery
                  ? Icons.map_outlined
                  : Icons.map),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.white,
                      height: 250.0,
                      padding: EdgeInsets.all(15.0),
                      child: PoiFilterPane(location),
                    );
                  },
                );
              },
              icon: Icon(
                hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: hasFilter ? Colors.yellowAccent : null,
              ),
            ),
            if (!ref.watch(trackingProvider))
              IconButton(
                onPressed: ref.watch(trackingProvider)
                    ? null
                    : () {
                        ref.read(trackingProvider.state).state = true;
                      },
                icon: const Icon(Icons.my_location),
              ),
          ],
        ),
        body: Column(
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
              ),
            ),
            if (areaStatus != AreaStatus.fresh && apiStatus == ApiStatus.idle)
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  height: 50.0,
                  color: areaStatus == AreaStatus.missing
                      ? Colors.redAccent
                      : Colors.yellow,
                  child: Center(
                    child: Text(
                      areaStatus == AreaStatus.missing
                          ? loc.messageNoData
                          : loc.messageDataObsolete,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: areaStatus == AreaStatus.missing
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  downloadAmenities(location);
                },
              ),
            Expanded(
              flex:
                  editorMode == EditorMode.micromapping || farFromUser ? 1 : 3,
              child: apiStatus != ApiStatus.idle
                  ? Column(
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
                    )
                  : PoiPane(
                      amenities: nearestPOI, updateNearest: updateNearest),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            ref.read(microZoomedInProvider.state).state = null;
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: '/list'),
                builder: (context) => MapChooserPage(
                  creating: true,
                  location: location,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
