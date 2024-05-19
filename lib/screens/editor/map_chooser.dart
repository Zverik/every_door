import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/helpers/pin_marker.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/walkpath.dart';
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
  ConsumerState createState() => _MapChooserPageState();
}

class _MapChooserPageState extends ConsumerState<MapChooserPage> {
  late LatLng center;
  List<OsmChange> nearestPOI = [];
  List<BaseNote> nearestNotes = [];
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;

  @override
  void initState() {
    super.initState();
    center = widget.location;
    mapSub = controller.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = event.camera.center;
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
    // Fetch OSM notes as well.
    final notes = await ref
        .read(notesProvider)
        .fetchAllNotes(center: location, radius: kNotesVisibilityRadius);
    // Update the map.
    setState(() {
      nearestPOI = data;
      nearestNotes = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final tileLayer = TileLayerOptions(imagery);
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
            tooltip: loc.navImagery,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: widget.location,
          initialZoom: widget.closer ? 19.0 : 18.0,
          minZoom: 17.0,
          maxZoom: kEditMaxZoom,
          initialRotation: ref.watch(rotationProvider),
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all -
                InteractiveFlag.flingAnimation -
                InteractiveFlag.rotate,
            rotationThreshold: kRotationThreshold,
          ),
        ),
        children: [
          AttributionWidget(imagery),
          TileLayer(
            urlTemplate: tileLayer.urlTemplate,
            wmsOptions: tileLayer.wmsOptions,
            tileProvider: tileLayer.tileProvider,
            minNativeZoom: tileLayer.minNativeZoom,
            maxNativeZoom: tileLayer.maxNativeZoom,
            maxZoom: tileLayer.maxZoom,
            tileSize: tileLayer.tileSize,
            tms: tileLayer.tms,
            subdomains: tileLayer.subdomains,
            additionalOptions: tileLayer.additionalOptions,
            userAgentPackageName: tileLayer.userAgentPackageName,
            reset: tileResetController.stream,
          ),
          PolylineLayer(
            polylines: [
              for (final drawing in nearestNotes.whereType<MapDrawing>())
                Polyline(
                  points: drawing.path.nodes,
                  color: drawing.style.color,
                  strokeWidth: drawing.style.stroke / 3,
                  isDotted: drawing.style.dashed,
                  borderColor: drawing.style.casing.withAlpha(30),
                  borderStrokeWidth: 2.0,
                ),
            ],
          ),
          WalkPathPolyline(),
          LocationMarkerWidget(tracking: false),
          if (trackLocation != null)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: center,
                  radius: 2.0,
                  color: Colors.yellowAccent,
                ),
              ],
            ),
          CircleLayer(
            circles: [
              for (final note in nearestNotes.whereType<OsmNote>())
                CircleMarker(
                  point: note.location,
                  radius: 9.0,
                  color: Colors.grey,
                ),
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
          MarkerLayer(
            markers: [PinMarker(center)],
          ),
          ZoomButtonsWidget(
            alignment: leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
            padding: EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 100.0,
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
