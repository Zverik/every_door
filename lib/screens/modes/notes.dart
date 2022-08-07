import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/editor/note.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotesPane extends ConsumerStatefulWidget {
  final Widget? areaStatusPanel;

  const NotesPane({Key? key, this.areaStatusPanel}) : super(key: key);

  @override
  ConsumerState<NotesPane> createState() => _NotesPaneState();
}

class _NotesPaneState extends ConsumerState<NotesPane> {
  static const kToolEraser = "eraser";
  static const kToolNote = "note";
  static const kToolScribble = "scribble";

  String _currentTool = kToolNote;
  List<BaseNote> _notes = [];
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;
  final _mapKey = GlobalKey();
  LatLng? newLocation;

  @override
  initState() {
    super.initState();
    mapSub = controller.mapEventStream.listen(onMapEvent);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateNotes();
    });
  }

  onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController;
    if (event is MapEventMoveEnd && !fromController) {
      updateNotes();
    }
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
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
    final location = controller.center;
    final notes = await ref.read(notesProvider).fetchAllNotes(location);
    if (!mounted) return;
    setState(() {
      _notes = notes.where((n) => !n.deleting).toList();
    });
  }

  _openNoteEditor(OsmNote? note, [LatLng? location]) async {
    if (location != null) {
      setState(() {
        newLocation = location;
      });
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NoteEditorPane(
        note: note,
        location:
            location ?? note?.location ?? ref.read(effectiveLocationProvider),
      ),
    );
    setState(() {
      newLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;
    EdgeInsets safePadding = MediaQuery.of(context).padding;

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      controller.move(next, controller.zoom);
      updateNotes();
    });
    ref.listen(notesProvider, (_, next) {
      updateNotes();
    });

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                key: _mapKey,
                mapController: controller,
                options: MapOptions(
                  center: ref.read(effectiveLocationProvider),
                  minZoom: 15.0,
                  maxZoom: 20.0,
                  zoom: 17.0,
                  // TODO: remove drag when adding map drawing
                  interactiveFlags: InteractiveFlag.pinchMove |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag,
                  rotation: ref.watch(rotationProvider),
                  rotationThreshold: kRotationThreshold,
                  plugins: [MapDragCreatePlugin()],
                ),
                children: [
                  TileLayerWidget(
                    options: buildTileLayerOptions(
                        ref.watch(selectedImageryProvider)),
                  ),
                  LocationMarkerWidget(tracking: false),
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
                  MarkerLayerWidget(
                    options: MarkerLayerOptions(
                      markers: [
                        for (final osmNote in _notes.whereType<OsmNote>())
                          Marker(
                            point: osmNote.location,
                            width: 50.0,
                            height: 50.0,
                            builder: (BuildContext context) {
                              return Center(
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    color: Colors.transparent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: osmNote.isChanged
                                            ? Colors.yellow.withOpacity(0.8)
                                            : Colors.white.withOpacity(0.8),
                                      ),
                                      child:
                                          SizedBox(width: 30.0, height: 30.0),
                                    ),
                                  ),
                                  onTap: () {
                                    _openNoteEditor(osmNote);
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                nonRotatedLayers: [
                  MapDragCreateOptions(
                    mapKey: _mapKey,
                    buttons: [
                      DragButton(
                        icon: Icons.add,
                        tooltip: loc.notesAddNote,
                        bottom: 20.0,
                        left: !leftHand ? null : 10.0 + safePadding.left,
                        right: leftHand ? null : 10.0 + safePadding.right,
                        onDragEnd: (pos) {
                          _openNoteEditor(null, pos);
                        },
                        onTap: () async {
                          final pos = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MapChooserPage(location: controller.center),
                            ),
                          );
                          if (pos != null) _openNoteEditor(null, pos);
                        },
                      ),
                    ],
                  ),
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
                    // ref.read(notesProvider).saveNote(note);
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
