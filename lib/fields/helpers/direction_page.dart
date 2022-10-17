import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class DirectionValuePage extends ConsumerStatefulWidget {
  final LatLng location;
  final String? value;

  const DirectionValuePage(this.location, this.value);

  @override
  ConsumerState<DirectionValuePage> createState() => _DirectionValuePageState();
}

class _DirectionValuePageState extends ConsumerState<DirectionValuePage> {
  final controller = MapController();
  LatLng? direction;

  @override
  void initState() {
    super.initState();
    final directionValue = double.tryParse(widget.value ?? 'fail');
    if (directionValue != null) {
      // TODO: set direction location based on the angle.
    }
  }

  String? _getAngle() {
    if (direction == null) return null;
    return '0'; // TODO
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chooseLocation),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, '-');
            },
            icon: Icon(Icons.delete),
            tooltip: loc.fieldHoursClear, // TODO: new string?
          ),
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
          center: widget.location,
          zoom: 18.0,
          minZoom: 17.0,
          maxZoom: 20.0,
          rotation: ref.watch(rotationProvider),
          interactiveFlags: 0,
        ),
        nonRotatedChildren: [
          buildAttributionWidget(imagery),
        ],
        children: [
          TileLayerWidget(
            options: buildTileLayerOptions(imagery),
          ),
          LocationMarkerWidget(tracking: false),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                Marker(
                  point: widget.location,
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
          if (direction != null)
            CircleLayerWidget(
              options: CircleLayerOptions(
                circles: [
                  CircleMarker(
                    point: direction!,
                    radius: 15.0,
                    color: Colors.yellowAccent,
                    borderColor: Colors.black,
                    borderStrokeWidth: 2.0,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _getAngle());
        },
      ),
    );
  }
}
