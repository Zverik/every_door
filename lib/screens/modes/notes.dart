import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/notes.dart';
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
  static const kToolEraser = "eraser";
  static const kToolNote = "note";

  String _currentTool = "scribble";
  List<BaseNote> _notes = [];
  final controller = MapController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateNotes();
    });
  }

  List<LatLng> _coordsFromOffsets(List<Offset> offsets) {
    final result = <LatLng>[];
    for (final offset in offsets) {
      final loc = controller.pointToLatLng(CustomPoint(offset.dx, offset.dy));
      if (loc != null) result.add(loc);
    }
    return result;
  }

  updateNotes() async {
    final location = ref.read(effectiveLocationProvider);
    final notes = await ref.read(notesProvider).fetchAllNotes(location);
    if (!mounted) return;
    setState(() {
      _notes = notes;
    });
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
                mapController: controller,
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
                  PolylineLayerWidget(
                      options: PolylineLayerOptions(
                    polylines: [
                      for (final drawing in _notes.whereType<MapDrawing>())
                        Polyline(
                          points: drawing.coordinates,
                          color: drawing.style.color,
                          strokeWidth: drawing.style.stroke,
                          isDotted: drawing.style.dashed,
                          borderColor: drawing.style.casing,
                        ),
                    ],
                  )),
                ],
              ),
              if (kTypeStyles.containsKey(_currentTool))
                PainterWidget(
                  onDrawn: (offsets) {
                    final note = MapDrawing(
                      coordinates: _coordsFromOffsets(offsets),
                      pathType: _currentTool,
                    );
                    setState(() {
                      _notes.add(note);
                    });
                    ref.read(notesProvider).saveNote(note);
                  },
                  style: kTypeStyles[_currentTool]!,
                ),
            ],
          ),
        ),
        if (widget.areaStatusPanel != null) widget.areaStatusPanel!,
      ],
    );
  }
}
