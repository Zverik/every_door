import 'dart:async';

import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor/building.dart';
import 'package:every_door/screens/editor/entrance.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/multi_hit.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:every_door/widgets/track_button.dart';
import 'package:every_door/widgets/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntrancesPane extends ConsumerStatefulWidget {
  final Widget? areaStatusPanel;

  const EntrancesPane({this.areaStatusPanel});

  @override
  ConsumerState<EntrancesPane> createState() => _EntrancesPaneState();
}

class _EntrancesPaneState extends ConsumerState<EntrancesPane> {
  List<OsmChange> nearest = [];
  Map<String, GlobalKey> keys = {};
  final _mapKey = GlobalKey();
  late LatLng center;
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;
  bool buildingsNeedAddresses = true;
  LatLng? newLocation;
  double? savedZoom;

  static const kOurKinds = {
    ElementKind.entrance,
    ElementKind.building,
    ElementKind.address,
  };

  @override
  void initState() {
    super.initState();
    center = ref.read(effectiveLocationProvider);
    mapSub = controller.mapEventStream.listen(onMapEvent);
    updateNearest();
  }

  onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController;
    if (event is MapEventWithMove) {
      center = event.center;
      if (!fromController) {
        ref.read(trackingProvider.state).state = false;
        ref.read(zoomProvider.state).state = event.zoom;
        if (event.zoom < kEditMinZoom) {
          // Switch navigation mode on
          ref.read(navigationModeProvider.state).state = true;
        }
        setState(() {
          // redraw center marker
        });
      }
    } else if (event is MapEventMoveEnd) {
      if (!fromController) {
        ref.read(effectiveLocationProvider.notifier).set(event.center);
      }
    } else if (event is MapEventRotateEnd) {
      if (event.source != MapEventSource.mapController) {
        double rotation = controller.rotation;
        while (rotation > 200) rotation -= 360;
        while (rotation < -200) rotation += 360;
        if (rotation.abs() < kRotationThreshold) {
          ref.read(rotationProvider.state).state = 0.0;
          controller.rotate(0.0);
        } else {
          ref.read(rotationProvider.state).state = rotation;
        }
      }
    }
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  ElementKind getOurKind(OsmChange change) {
    return detectKind(change.getFullTags(), kOurKinds);
  }

  updateNearest() async {
    final provider = ref.read(osmDataProvider);
    final location = ref.read(effectiveLocationProvider);
    const radius = kFarVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    const distance = DistanceEquirectangular();
    data = data.where((e) => distance(location, e.location) <= radius).toList();

    // Wait for country coder
    if (!CountryCoder.instance.ready) {
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
          .then((_) => !CountryCoder.instance.ready));
    }

    if (!mounted) return;
    setState(() {
      nearest = data.where((e) => kOurKinds.contains(getOurKind(e))).toList();
      for (final c in nearest) {
        if (!keys.containsKey(c.databaseId)) {
          keys[c.databaseId] = GlobalKey();
        }
      }
      buildingsNeedAddresses = !CountryCoder.instance.isIn(
        lat: location.latitude,
        lon: location.longitude,
        inside: 'Q55', // Netherlands
      );
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
    for (final e in nearest) if (e.databaseId == databaseId) return e;
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
      builder: (context) => pane,
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
    const kMaxNumberLength = 6;
    final needsAddress = buildingsNeedAddresses &&
        (building['building'] == null ||
            kBuildingNeedsAddress.contains(building['building']));
    String number = building['addr:housenumber'] ??
        building['addr:housename'] ??
        (needsAddress ? '?' : '');
    if (number.length > kMaxNumberLength) {
      final spacePos = number.indexOf(' ');
      if (spacePos > 0) number = number.substring(0, spacePos);
      if (number.length > kMaxNumberLength)
        number = number.substring(0, kMaxNumberLength - 1);
      number = number + '…';
    }

    return number;
  }

  String makeEntranceLabel(OsmChange entrance) {
    final flats = entrance['addr:flats'];
    final ref = entrance['ref'];
    const kNeedsData = {'staircase', 'yes'};
    if (flats == null && ref == null)
      return kNeedsData.contains(entrance['entrance']) ? '?' : '';
    String label = [ref, flats].whereType<String>().join(': ');
    while (label.length > 11) {
      // 11 is "10: 123-456".
      if (!RegExp(r'\d').hasMatch(label)) {
        label = label.substring(0, 10) + '…';
        break;
      }
      label = label.replaceFirst(RegExp(r'\s*\d+[^\d]*$'), '…');
    }
    return label;
  }

  bool isComplete(OsmChange element) {
    switch (getOurKind(element)) {
      case ElementKind.building:
        return element['building:levels'] != null;
      case ElementKind.entrance:
        const kNeedsData = {'staircase', 'yes'};
        return (kNeedsData.contains(element['entrance'])
                ? (element['addr:flats'] ?? element['addr:unit']) != null
                : true) &&
            element['entrance'] != 'yes';
      case ElementKind.address:
        // Always draw white.
        return false;
      default:
        return true;
    }
  }

  BoxDecoration makeLabelDecoration(OsmChange element) {
    final complete = isComplete(element);
    final kind = getOurKind(element);
    final opacity = kind == ElementKind.entrance ? 0.8 : 0.6;
    return BoxDecoration(
      border: Border.all(
        color: complete ? Colors.black : Colors.black.withOpacity(0.3),
        width: complete ? 1.0 : 1.0,
      ),
      borderRadius:
          BorderRadius.circular(kind == ElementKind.address ? 5.0 : 13.0),
      color: complete
          ? Colors.yellow.withOpacity(opacity)
          : Colors.white.withOpacity(opacity),
    );
  }

  String makeOneLineLabel(BuildContext context, OsmChange element) {
    final loc = AppLocalizations.of(context)!;
    switch (getOurKind(element)) {
      case ElementKind.building:
        return loc
            .buildingX(
                element["addr:housenumber"] ?? element["addr:housename"] ?? '')
            .trim();
      case ElementKind.address:
        return loc
            .addressX(
                element["addr:housenumber"] ?? element["addr:housename"] ?? '')
            .trim();
      case ElementKind.entrance:
        final label = [element['ref'], element['addr:flats']]
            .whereType<String>()
            .join(': ');
        return loc.entranceX(label).trim();
      default:
        return element.typeAndName;
    }
  }

  openEditorByType(OsmChange element) {
    final k = getOurKind(element);
    if (k == ElementKind.building || k == ElementKind.address)
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
                child: Text(makeOneLineLabel(context, e),
                    style: TextStyle(fontSize: 20.0)),
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
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    final loc = AppLocalizations.of(context)!;

    // When tracking location, move map and notify the poi list.
    ref.listen<LatLng?>(geolocationProvider, (_, LatLng? location) {
      if (location != null && ref.watch(trackingProvider)) {
        controller.move(location, controller.zoom);
        ref.read(effectiveLocationProvider.notifier).set(location);
      }
    });

    // Rotate the map according to the global rotation value.
    ref.listen(rotationProvider, (_, double newValue) {
      if ((newValue - controller.rotation).abs() >= 1.0)
        controller.rotate(newValue);
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

    // Safe area from the left/right side.
    EdgeInsets safePadding = MediaQuery.of(context).padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(children: [
            FlutterMap(
              key: _mapKey,
              mapController: controller,
              options: MapOptions(
                center: center,
                zoom: ref.watch(zoomProvider),
                minZoom: kEditMinZoom - 0.1,
                maxZoom: kEditMaxZoom,
                rotation: ref.watch(rotationProvider),
                rotationThreshold: kRotationThreshold,
                interactiveFlags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.rotate,
                plugins: [
                  MapDragCreatePlugin(),
                  MultiHitMarkerLayerPlugin(),
                  ZoomButtonsPlugin(),
                  OverlayButtonPlugin(),
                ],
              ),
              layers: [
                MultiHitMarkerLayerOptions(
                  markers: [
                    for (final building in nearest
                        .where((el) => getOurKind(el) == ElementKind.building))
                      Marker(
                        key: keys[building.databaseId],
                        point: building.location,
                        width: 120.0,
                        height: 60.0,
                        rotate: true,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              decoration: makeLabelDecoration(building),
                              padding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                              constraints: BoxConstraints(minWidth: 35.0),
                              child: Text(
                                makeBuildingLabel(building),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: kFieldFontSize),
                              ),
                            ),
                          );
                        },
                      ),
                    for (final address in nearest
                        .where((el) => getOurKind(el) == ElementKind.address))
                      Marker(
                        key: keys[address.databaseId],
                        point: address.location,
                        rotate: true,
                        width: 90.0,
                        height: 50.0,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              color: Colors.transparent,
                              child: Container(
                                decoration: makeLabelDecoration(address),
                                padding: EdgeInsets.symmetric(
                                  vertical: 3.0,
                                  horizontal: 3.0,
                                ),
                                child: Text(
                                  makeBuildingLabel(address),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    for (final entrance in nearest
                        .where((el) => getOurKind(el) == ElementKind.entrance))
                      Marker(
                        key: keys[entrance.databaseId],
                        point: entrance.location,
                        width: 50.0,
                        height: 50.0,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              color: Colors.transparent,
                              child: Container(
                                decoration: makeLabelDecoration(entrance),
                                child: SizedBox(width: 20.0, height: 20.0),
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
              ],
              nonRotatedLayers: [
                MapDragCreateOptions(
                  mapKey: _mapKey,
                  buttons: [
                    DragButton(
                        icon: Icons.house,
                        tooltip: loc.entrancesAddBuilding,
                        bottom: 20.0,
                        left: leftHand ? null : 10.0 + safePadding.left,
                        right: !leftHand ? null : 10.0 + safePadding.right,
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
                        tooltip: loc.entrancesAddEntrance,
                        bottom: 20.0,
                        left: !leftHand ? null : 10.0 + safePadding.left,
                        right: leftHand ? null : 10.0 + safePadding.right,
                        onDragStart: () {
                          if (savedZoom == null) {
                            savedZoom = controller.zoom;
                            controller.move(
                                controller.center, savedZoom! + 0.7);
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
                // Settings button
                OverlayButtonOptions(
                  alignment: leftHand ? Alignment.topRight : Alignment.topLeft,
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 10.0,
                  ),
                  icon: Icons.menu,
                  tooltip: loc.mapSettings,
                  safeRight: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                // Tracking button
                OverlayButtonOptions(
                  alignment: leftHand ? Alignment.topLeft : Alignment.topRight,
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 10.0,
                  ),
                  enabled:
                      !ref.watch(trackingProvider) && trackLocation != null,
                  safeRight: true,
                  icon: Icons.my_location,
                  tooltip: loc.mapLocate,
                  onPressed: () {
                    ref
                        .read(geolocationProvider.notifier)
                        .enableTracking(context);
                  },
                  onLongPressed: () {
                    if (ref.read(rotationProvider) != 0.0) {
                      ref.read(rotationProvider.state).state = 0.0;
                      controller.rotate(0.0);
                    } else {
                      ref
                          .read(geolocationProvider.notifier)
                          .enableTracking(context);
                    }
                  },
                ),
                ZoomButtonsOptions(
                  alignment:
                      leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        0.0 + (leftHand ? safePadding.left : safePadding.right),
                    vertical: 100.0,
                  ),
                ),
              ],
              nonRotatedChildren: [
                buildAttributionWidget(imagery),
              ],
              children: [
                TileLayerWidget(
                  options: buildTileLayerOptions(imagery),
                ),
                LocationMarkerWidget(),
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
            ApiStatusPane(),
          ]),
        ),
        if (widget.areaStatusPanel != null) widget.areaStatusPanel!,
      ],
    );
  }
}
