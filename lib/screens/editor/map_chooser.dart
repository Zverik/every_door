import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/widgets/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapChooserPage extends ConsumerStatefulWidget {
  final LatLng location;
  final bool creating;
  final bool closer;

  const MapChooserPage({
    required this.location,
    this.creating = false,
    this.closer = false,
  });

  @override
  _MapChooserPageState createState() => _MapChooserPageState();
}

class _MapChooserPageState extends ConsumerState<MapChooserPage> {
  late LatLng center;
  List<OsmChange> nearestPOI = [];
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;

  @override
  void initState() {
    super.initState();
    center = widget.location;
    mapSub = controller.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = event.targetCenter;
        });
      } else if (event is MapEventMoveEnd) {
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
    final filter = ref.read(poiFilterProvider);
    final editorMode = ref.read(editorModeProvider);
    final location = center;
    // Query for amenities around the location.
    List<OsmChange> data =
        await provider.getElements(location, kVisibilityRadius);
    // Filter for amenities (or not amenities).
    data = data.where((e) {
      switch (e.kind) {
        case ElementKind.amenity:
          return editorMode == EditorMode.poi;
        case ElementKind.micro:
          return editorMode == EditorMode.micromapping;
        case ElementKind.building:
          return false;
        case ElementKind.entrance:
          return true;
        default:
          return e.isNew;
      }
    }).toList();
    // Apply the building filter.
    if (filter.isNotEmpty) {
      data = data.where((e) => filter.matches(e)).toList();
    }
    // Update the map.
    setState(() {
      nearestPOI = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chooseLocation),
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
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          center: widget.location,
          zoom: widget.closer ? 19.0 : 18.0,
          minZoom: 17.0,
          maxZoom: 20.0,
          rotation: ref.watch(rotationProvider),
          rotationThreshold: kRotationThreshold,
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          plugins: [ZoomButtonsPlugin()],
        ),
        nonRotatedLayers: [
          ZoomButtonsOptions(
            alignment: leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
            padding: EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 100.0,
            ),
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
                  CircleMarker(
                    point: center,
                    radius: 2.0,
                    color: Colors.yellowAccent,
                  ),
                ],
              ),
            ),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                Marker(
                  point: center,
                  rotate: true,
                  rotateOrigin: Offset(0.0, -5.0),
                  rotateAlignment: Alignment.bottomCenter,
                  anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                  builder: (ctx) =>
                      Icon(Icons.location_pin, color: Colors.black),
                ),
              ],
            ),
          ),
          CircleLayerWidget(
            options: CircleLayerOptions(
              circles: [
                for (final poi in nearestPOI)
                  CircleMarker(
                    point: poi.location,
                    radius: 3.0,
                    color: poi.kind == ElementKind.entrance
                        ? Colors.black
                        : !poi.isModified
                            ? Colors.greenAccent
                            : Colors.yellow,
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          if (widget.creating) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TypeChooserPage(location: center)),
            );
          } else {
            Navigator.pop(context, center);
          }
        },
      ),
    );
  }
}
