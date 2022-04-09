import 'dart:async';

import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
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
    center = LatLng(0.0, 0.0); // TODO
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
    final location = center;
    // TODO: Get nearest buildings and nearest entrances.
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final LatLng? trackLocation = ref.watch(geolocationProvider);

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
      body: FlutterMap(
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
