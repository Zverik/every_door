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
import 'package:every_door/providers/micromapping.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoiListPage extends ConsumerStatefulWidget {
  final LatLng? location;

  const PoiListPage({this.location});

  @override
  _PoiListPageState createState() => _PoiListPageState();
}

class _PoiListPageState extends ConsumerState<PoiListPage> {
  static const kSavedLocation = 'last_location';

  late LatLng location;
  List<OsmChange> allPOI = [];
  List<OsmChange> nearestPOI = [];
  final mapController = AmenityMapController();
  late LifecycleEventHandler lifecycleObserver;
  AreaStatus areaStatus = AreaStatus.fresh;
  bool farFromUser = false;

  @override
  void initState() {
    super.initState();
    location =
        widget.location ?? LatLng(kDefaultLocation[0], kDefaultLocation[1]);
    if (widget.location == null) restoreLocation();

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
        } on Exception catch (e) {
          print(e); // No point in catching anything
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

  restoreLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final loc = prefs.getStringList(kSavedLocation);
    if (loc != null && ref.read(geolocationProvider) == null) {
      setState(() {
        location = LatLng(double.parse(loc[0]), double.parse(loc[1]));
        mapController.setLocation(location);
      });
    }
  }

  saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSavedLocation,
        [location.latitude.toString(), location.longitude.toString()]);
  }

  updateFarFromUser() {
    final gpsLocation = ref.read(geolocationProvider);
    bool newFar;
    if (gpsLocation != null) {
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

  updateNearest() async {
    final provider = ref.read(osmDataProvider);
    final micromapping = ref.read(micromappingProvider);
    final filter = ref.read(poiFilterProvider);
    final location = this.location;
    // Query for amenities around the location.
    final radius = farFromUser ? kFarVisibilityRadius : kVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    // Filter for amenities (or not amenities).
    data = data
        .where((e) =>
            e.isModified ||
            (micromapping
                ? !(e.element?.isAmenity ?? false)
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

  @override
  Widget build(BuildContext context) {
    final micromapping = ref.watch(micromappingProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;
    ref.listen(needMapUpdateProvider, (previous, next) {
      updateNearest();
    });
    ref.listen(poiFilterProvider, (previous, next) {
      updateNearest();
    });

    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        if (ref.read(trackingProvider))
          return true;
        else {
          ref.read(trackingProvider.state).state = true;
          return false;
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
                  location = pos;
                  saveLocation();
                  updateFarFromUser();
                  updateNearest();
                  updateAreaStatus();
                },
                onTrack: (pos) {
                  // TODO: adjust zoom level to fit half of nearby points
                  // (but restricted to 17-19 probably)
                },
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
              flex: micromapping || farFromUser ? 1 : 3,
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
