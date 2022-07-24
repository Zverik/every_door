import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/widgets/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class NotesPane extends ConsumerStatefulWidget {
  final Widget? areaStatusPanel;

  const NotesPane({Key? key, this.areaStatusPanel}) : super(key: key);

  @override
  ConsumerState<NotesPane> createState() => _NotesPaneState();
}

class _NotesPaneState extends ConsumerState<NotesPane> {
  List<LatLng> _coordsFromOffsets(List<Offset> offsets) {
    final result = <LatLng>[];
    // TODO
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: ref.read(effectiveLocationProvider),
                  zoom: 17.0,
                  interactiveFlags:
                      InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom,
                  rotation: ref.watch(rotationProvider),
                  rotationThreshold: kRotationThreshold,
                ),
                children: [
                  TileLayerWidget(
                    options: buildTileLayerOptions(
                        ref.watch(selectedImageryProvider)),
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
                ],
              ),
              PainterWidget(
                onDrawn: (offsets) {
                  print('Got line.');
                },
                color: Colors.white,
                dashed: true,
              ),
            ],
          ),
        ),
        if (widget.areaStatusPanel != null) widget.areaStatusPanel!,
      ],
    );
  }
}
