import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor/building.dart';
import 'package:every_door/screens/editor/entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntranceEditorPage extends ConsumerStatefulWidget {
  const EntranceEditorPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EntranceEditorPage> createState() => _EntranceEditorPageState();
}

class _EntranceEditorPageState extends ConsumerState<EntranceEditorPage> {
  List<OsmChange> nearestBuildings = [];
  List<OsmChange> nearestEntrances = [];
  late LatLng center;
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;

  @override
  void initState() {
    super.initState();
    center = ref.read(effectiveLocationProvider); // TODO
    mapSub = controller.mapEventStream.listen(onMapEvent);
    updateNearest();
  }

  onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController;
    if (event is MapEventMove) {
      center = event.center;
      if (!fromController) {
        ref.read(trackingProvider.state).state = false;
        setState(() {
          // redraw center marker
        });
      }
    } else if (event is MapEventMoveEnd) {
      if (!fromController) {
        ref.read(effectiveLocationProvider.notifier).set(event.center);
        updateNearest();
      }
    }
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  updateNearest() async {
    final provider = ref.read(osmDataProvider);
    final location = ref.read(effectiveLocationProvider);
    const radius = kVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    const distance = DistanceEquirectangular();
    data = data.where((e) => distance(location, e.location) <= radius).toList();
    setState(() {
      nearestBuildings = data
          .where((e) => e['building'] != null && e['building'] != 'entrance')
          .toList();
      nearestEntrances = data
          .where((e) => e['entrance'] != null || e['building'] == 'entrance')
          .toList();
    });
  }

  editBuilding(OsmChange building) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 6.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BuildingEditorPane(
              building: building,
              location: ref.read(effectiveLocationProvider),
            ),
          ),
        );
      },
    );
  }

  editEntrance(OsmChange? entrance) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 6.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: EntranceEditorPane(
              entrance: entrance,
              location: ref.read(effectiveLocationProvider),
            ),
          ),
        );
      },
    );
  }

  String makeBuildingLabel(OsmChange building) {
    String number =
        building['addr:housenumber'] ?? building['addr:housename'] ?? '?';
    final levels = building['building:levels'];
    return levels == null ? number : '$number\n$levels';
  }

  String makeEntranceLabel(OsmChange entrance) {
    final flats = entrance['addr:flats'];
    final ref = entrance['ref'];
    if (flats == null && ref == null) return '?';
    return [ref, flats].whereType<String>().join(': ');
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.read(effectiveLocationProvider);
    final imagery = ref.watch(selectedImageryProvider);
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      setState(() {
        center = next;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrances'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                ref.read(selectedImageryProvider.notifier).toggle();
              });
            },
            icon: Icon(imagery == kOSMImagery ? Icons.map_outlined : Icons.map),
          ),
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
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          center: center,
          zoom: 17.0,
          minZoom: 15.0,
          maxZoom: 20.0,
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
        children: [
          TileLayerWidget(
            options: buildTileLayerOptions(imagery),
          ),
          if (trackLocation != null)
            CircleLayerWidget(
              options: CircleLayerOptions(
                circles: [
                  CircleMarker(
                    point: trackLocation,
                    color: Colors.blue.withOpacity(0.4),
                    radius: 10.0,
                  ),
                  if (ref.watch(trackingProvider))
                    CircleMarker(
                      point: trackLocation,
                      borderColor: Colors.black.withOpacity(0.8),
                      borderStrokeWidth: 1.0,
                      color: Colors.transparent,
                      radius: 10.0,
                    ),
                ],
              ),
            ),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                for (final building in nearestBuildings)
                  Marker(
                    point: building.location,
                    width: 100.0,
                    height: 50.0,
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white.withOpacity(0.7),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 10.0,
                            ),
                            child: Text(
                              makeBuildingLabel(building),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: kFieldFontSize),
                            ),
                          ),
                        ),
                        onTap: () {
                          editBuilding(building);
                        },
                      );
                    },
                  ),
                for (final entrance in nearestEntrances)
                  Marker(
                    point: entrance.location,
                    width: 100.0,
                    height: 50.0,
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white.withOpacity(0.7),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 10.0,
                            ),
                            child: Text(
                              makeEntranceLabel(entrance),
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),
                        onTap: () {
                          // TODO: on tap check underlying entrances and buildings,
                          // and if found, open a chooser.
                          editEntrance(entrance);
                        },
                      );
                    },
                  ),
                if (!ref.watch(trackingProvider))
                  Marker(
                    point: center,
                    anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                    builder: (ctx) => Icon(Icons.location_pin),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
