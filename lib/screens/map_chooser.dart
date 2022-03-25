import 'dart:async';

import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/screens/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapChooserPage extends ConsumerStatefulWidget {
  final LatLng location;
  final bool creating;

  const MapChooserPage({required this.location, this.creating = false});

  @override
  _MapChooserPageState createState() => _MapChooserPageState();
}

class _MapChooserPageState extends ConsumerState<MapChooserPage> {
  late LatLng location;
  late LatLng center;
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;
  late final StreamSubscription<Position> locSub;

  @override
  void initState() {
    super.initState();
    location = widget.location;
    center = location;
    mapSub = controller.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = event.targetCenter;
        });
      }
    });
  }

  @override
  void dispose() {
    mapSub.cancel();
    // locSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose location'),
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
          center: location,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          if (widget.creating) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TypeChooserPage(creatingLocation: controller.center)),
            );
          } else {
            Navigator.pop(context, controller.center);
          }
        },
      ),
    );
  }
}
