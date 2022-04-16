import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor/building.dart';
import 'package:every_door/screens/editor/entrance.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/multi_hit.dart';
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
  Map<String, GlobalKey> keys = {};
  late LatLng center;
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;
  LatLng? newLocation;
  double? savedZoom;

  @override
  void initState() {
    super.initState();
    center = ref.read(effectiveLocationProvider);
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
      }
    }
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  ElementKind getOurKind(OsmChange change) {
    const kAcceptedKinds = {ElementKind.building, ElementKind.entrance};
    return detectKind(change.getFullTags(), kAcceptedKinds);
  }

  updateNearest() async {
    final provider = ref.read(osmDataProvider);
    final location = ref.read(effectiveLocationProvider);
    const radius = kVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    const distance = DistanceEquirectangular();
    data = data.where((e) => distance(location, e.location) <= radius).toList();
    setState(() {
      nearestBuildings =
          data.where((e) => getOurKind(e) == ElementKind.building).toList();
      nearestEntrances =
          data.where((e) => getOurKind(e) == ElementKind.entrance).toList();
      for (final c in nearestEntrances + nearestBuildings) {
        if (!keys.containsKey(c.databaseId)) {
          keys[c.databaseId] = GlobalKey();
        }
      }
    });
  }

  OsmChange? findByKey(Key key) {
    String databaseId;
    try {
      databaseId =
          keys.entries.firstWhere((element) => element.value == key).key;
    } on Exception {
      return null;
    }
    for (final e in nearestBuildings) if (e.databaseId == databaseId) return e;
    for (final e in nearestEntrances) if (e.databaseId == databaseId) return e;
    return null;
  }

  openEditor(Widget pane, [LatLng? location]) async {
    if (location != null) {
      setState(() {
        newLocation = location;
      });
    }
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
              child: pane),
        );
      },
    );
    setState(() {
      newLocation = null;
    });
  }

  editBuilding(OsmChange? building, [LatLng? location]) async {
    openEditor(
      BuildingEditorPane(
        building: building,
        location: location ??
            building?.location ??
            ref.read(effectiveLocationProvider),
      ),
      location ?? building?.location,
    );
  }

  editEntrance(OsmChange? entrance, [LatLng? location]) async {
    openEditor(
      EntranceEditorPane(
        entrance: entrance,
        location: location ??
            entrance?.location ??
            ref.read(effectiveLocationProvider),
      ),
      location ?? entrance?.location,
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

  String makeOneLineLabel(OsmChange element) {
    final k = getOurKind(element);
    if (k == ElementKind.building)
      return 'Building ${element["addr:housenumber"] ?? element["addr:housename"] ?? ""}'
          .trimRight();
    if (k == ElementKind.entrance)
      return 'Entrance ${element["addr:flats"] ?? element["ref"] ?? ""}'
          .trimRight();
    return element.typeAndName;
  }

  openEditorByType(OsmChange element) {
    final k = getOurKind(element);
    if (k == ElementKind.building)
      editBuilding(element);
    else if (k == ElementKind.entrance) editEntrance(element);
  }

  chooseEditorToOpen(Iterable<OsmChange> elements) async {
    if (elements.isEmpty) return;
    if (elements.length == 1) {
      return openEditorByType(elements.first);
    }
    // Many elements: present a menu.
    final result = await showDialog<OsmChange>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          for (final e in elements)
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child:
                    Text(makeOneLineLabel(e), style: TextStyle(fontSize: 20.0)),
              ),
              onPressed: () {
                Navigator.pop(context, e);
              },
            ),
        ],
      ),
    );
    if (result != null) openEditorByType(result);
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.read(effectiveLocationProvider);
    final imagery = ref.watch(selectedImageryProvider);
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    // When tracking location, move map and notify the poi list.
    ref.listen<LatLng?>(geolocationProvider, (_, LatLng? location) {
      if (location != null && ref.watch(trackingProvider)) {
        controller.move(location, controller.zoom);
        ref.read(effectiveLocationProvider.notifier).set(location);
      }
    });

    // When turning the tracking on, move the map immediately.
    ref.listen(trackingProvider, (_, bool newState) {
      if (trackLocation != null && newState) {
        controller.move(trackLocation, controller.zoom);
        ref.read(effectiveLocationProvider.notifier).set(trackLocation);
      }
    });

    ref.listen(needMapUpdateProvider, (_, next) {
      updateNearest();
    });
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      controller.move(next, controller.zoom);
      updateNearest();
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
          zoom: 18.0,
          minZoom: 16.0,
          maxZoom: 20.0,
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          plugins: [
            MapDragCreatePlugin(),
            MultiHitMarkerLayerPlugin(),
          ],
        ),
        nonRotatedLayers: [
          MultiHitMarkerLayerOptions(
            markers: [
              for (final building in nearestBuildings)
                Marker(
                  key: keys[building.databaseId],
                  point: building.location,
                  width: 100.0,
                  height: 50.0,
                  builder: (BuildContext context) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
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
                    );
                  },
                ),
              for (final entrance in nearestEntrances)
                Marker(
                  key: keys[entrance.databaseId],
                  point: entrance.location,
                  width: 100.0,
                  height: 50.0,
                  builder: (BuildContext context) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.yellow,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                        child: Text(
                          makeEntranceLabel(entrance),
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    );
                  },
                ),
            ],
            onTap: (tapped) {
              final objects =
                  tapped.map((k) => findByKey(k)).whereType<OsmChange>();
              chooseEditorToOpen(objects);
            },
          ),
          MapDragCreateOptions(
            buttons: [
              DragButton(
                  icon: Icons.house,
                  bottom: 20.0,
                  left: 20.0,
                  onDragEnd: (pos) {
                    editBuilding(null, pos);
                  },
                  onTap: () async {
                    final pos = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MapChooserPage(location: location),
                      ),
                    );
                    if (pos != null) editBuilding(null, pos);
                  }),
              DragButton(
                  icon: Icons.sensor_door,
                  bottom: 20.0,
                  right: 20.0,
                  onDragStart: () {
                    if (savedZoom == null) {
                      savedZoom = controller.zoom;
                      controller.move(controller.center, savedZoom! + 1);
                    }
                  },
                  onDragEnd: (pos) {
                    if (savedZoom != null) {
                      controller.move(controller.center, savedZoom!);
                      savedZoom = null;
                    }
                    editEntrance(null, pos);
                  },
                  onTap: () async {
                    final pos = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MapChooserPage(location: location),
                      ),
                    );
                    if (pos != null) editEntrance(null, pos);
                  }),
            ],
          ),
        ],
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
                if (!ref.watch(trackingProvider))
                  Marker(
                    point: center,
                    anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                    builder: (ctx) => Icon(Icons.location_pin),
                  ),
              ],
            ),
          ),
          if (newLocation != null)
            CircleLayerWidget(
              options: CircleLayerOptions(circles: [
                CircleMarker(
                  point: newLocation!,
                  radius: 5.0,
                  color: Colors.red,
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
