import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_data.dart';
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
    mapSub = controller.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        setState(() {
          center = event.center;
        });
      } else if (event is MapEventMoveEnd) {
        ref.read(effectiveLocationProvider.notifier).set(event.center);
        updateNearest();
      }
    });
    updateNearest();
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
      nearestBuildings = data.where((e) => e['building'] != null).toList();
      nearestEntrances = data.where((e) => e['entrance'] != null).toList();
    });
  }

  editBuilding(OsmChange building) async {
    // TODO
  }

  editEntrance(OsmChange entrance) async {
    // TODO
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
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: FlutterMap(
          mapController: controller,
          options: MapOptions(
            center: center,
            zoom: 18.0,
            minZoom: 17.0,
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
                  ],
                ),
              ),
            MarkerLayerWidget(
              options: MarkerLayerOptions(
                markers: [
                  for (final addr in nearestBuildings)
                    Marker(
                      point: addr.location,
                      width: 100.0,
                      height: 50.0,
                      builder: (BuildContext context) {
                        return GestureDetector(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white.withOpacity(0.7),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                              child: Text(
                                addr['addr:housenumber'] ?? addr['addr:housename'] ?? '?',
                                style: kFieldTextStyle,
                              ),
                            ),
                          ),
                          onTap: () {
                            editBuilding(addr);
                          },
                        );
                      },
                    ),
                  for (final addr in nearestEntrances)
                    Marker(
                      point: addr.location,
                      width: 100.0,
                      height: 50.0,
                      builder: (BuildContext context) {
                        return GestureDetector(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white.withOpacity(0.7),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                              child: Text(
                                makeEntranceLabel(addr),
                                style: kFieldTextStyle.copyWith(fontSize: 12.0),
                              ),
                            ),
                          ),
                          onTap: () {
                            editEntrance(addr);
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
      ),
    );
  }
}
