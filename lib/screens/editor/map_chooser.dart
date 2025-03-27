import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/widgets/pin_marker.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
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
  final LatLng? location;
  final bool creating;

  const MapChooserPage({
    this.location,
    this.creating = false,
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
    center = widget.location ?? ref.read(effectiveLocationProvider);
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
      if (editorMode.isOurKind(e)) return true;
      if (ElementKind.building.matchesChange(e)) return false;
      if (ElementKind.entrance.matchesChange(e)) return true;
      return e.isNew;
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
    final isOSM = imagery == ref.watch(baseImageryProvider);
    final tileLayer = TileLayerOptions(imagery);
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;

    double initialZoom = ref.watch(zoomProvider);
    if (initialZoom < 18) initialZoom = 18;

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
            icon: Icon(isOSM ? Icons.map_outlined : Icons.map),
            tooltip: loc.navImagery,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: initialZoom,
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
          tileLayer.buildTileLayer(reset: true),
          ...ref.watch(overlayImageryProvider),
          AttributionWidget(imagery),
          PolylineLayer(
            polylines: [
              for (final drawing in nearestNotes
                  .whereType<MapDrawing>()
                  .where((d) => !d.deleting))
                Polyline(
                  points: drawing.path.nodes,
                  color: drawing.style.color,
                  strokeWidth: drawing.style.stroke / 3,
                  pattern: drawing.style.dashed
                      ? StrokePattern.dashed(segments: const [10, 13])
                      : const StrokePattern.solid(),
                  borderColor: drawing.style.casing.withAlpha(30),
                  borderStrokeWidth: 2.0,
                ),
            ],
          ),
          WalkPathPolyline(),
          LocationMarkerWidget(),
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
                  color: ElementKind.entrance.matchesChange(poi)
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
          Scalebar(
            alignment: !leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
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
