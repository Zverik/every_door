// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/note_state.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/editor/note.dart';
import 'package:every_door/screens/modes/definitions/notes.dart';
import 'package:every_door/widgets/area_status.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/painter.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:every_door/widgets/style_chooser.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class NotesPane extends ConsumerStatefulWidget {
  final NotesModeDefinition def;

  const NotesPane(this.def, {super.key});

  @override
  ConsumerState<NotesPane> createState() => _NotesPaneState();
}

class _NotesPaneState extends ConsumerState<NotesPane> {
  final _controller = CustomMapController();
  LatLng? _newLocation;

  @override
  initState() {
    super.initState();
    widget.def.addListener(onDefChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateNotes();
      // Disable location tracking.
      ref.read(trackingProvider.notifier).disable();
      // Load the note state
      ref.read(noteIsOsmProvider);
    });
  }

  @override
  void didUpdateWidget(covariant NotesPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resubscribe, as per this method documentation.
    oldWidget.def.removeListener(onDefChange);
    widget.def.addListener(onDefChange);
  }

  @override
  void dispose() {
    widget.def.removeListener(onDefChange);
    super.dispose();
  }

  void onDefChange() {
    if (mounted) setState(() {});
  }

  void recordMapMove(MapCamera camera) {
    ref.read(effectiveLocationProvider.notifier).set(camera.center);
    ref.read(zoomProvider.notifier).state = camera.zoom;
    ref.read(visibleBoundsProvider.notifier).update(camera.visibleBounds);
  }

  void updateNotes() async {
    final bounds = ref.read(visibleBoundsProvider);
    if (bounds == null) return;
    await widget.def.updateNearest(bounds);
  }

  Future<void> _openNoteEditor(BaseNote? note, [LatLng? location]) async {
    if (note is MapDrawing) return;

    if (location != null) {
      setState(() {
        _newLocation = location;
      });
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => NoteEditorPane(
        note: note,
        location:
            location ?? note?.location ?? ref.read(effectiveLocationProvider),
      ),
    );
    setState(() {
      _newLocation = null;
    });
  }

  List<BaseNote> findClosestNotes(
      LatLng location, double Function(LatLng) distance) {
    const kMaxTapDistance = 30;
    final camera = _controller.mapController!.camera;
    final closestNotes = widget.def.notes
        .where((note) => camera.visibleBounds.contains(note.location))
        .where((note) => distance(note.location) <= kMaxTapDistance)
        .toList();

    closestNotes
        .sort((a, b) => distance(a.location).compareTo(distance(b.location)));

    return closestNotes;
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final currentTool = ref.watch(currentPaintToolProvider);
    final locked = ref.watch(drawingLockedProvider);
    final loc = AppLocalizations.of(context)!;

    ref.listen(notesProvider, (_, next) {
      updateNotes();
    });
    ref.listen(visibleBoundsProvider, (_, next) {
      updateNotes();
    });

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomMap(
                controller: _controller,
                onTap: !locked
                    ? null
                    : (ll, dist) {
                        final notes = findClosestNotes(ll, dist);
                        for (final note in notes) {
                          if (note is OsmNote ||
                              (note is MapNote && note.isNew)) {
                            _openNoteEditor(note);
                            break;
                          }
                        }
                      },
                drawPinMarker: false,
                faintWalkPath: false,
                drawStandardButtons: locked,
                drawZoomButtons: locked,
                hasFloatingButton: true,
                updateState: true,
                layers: [
                  ...widget.def.overlays.map((i) => i.buildLayer()),
                  ...widget.def.mapLayers(),
                  PolylineLayer(
                    polylines: [
                      for (final drawing
                          in widget.def.notes.whereType<MapDrawing>())
                        Polyline(
                          points: drawing.path.nodes,
                          color: drawing.style.color,
                          strokeWidth: drawing.style.stroke,
                          pattern: drawing.style.dashed
                              ? StrokePattern.dashed(segments: const [10, 13])
                              : const StrokePattern.solid(),
                          borderColor: drawing.style.casing.withAlpha(30),
                          borderStrokeWidth: 6.0,
                        ),
                    ],
                  ),
                  CircleLayer(circles: [
                    for (final osmNote in widget.def.notes.whereType<OsmNote>())
                      CircleMarker(
                        point: osmNote.location,
                        radius: 15.0,
                        color: osmNote.isChanged
                            ? Colors.yellow.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.8),
                        borderColor: Colors.black,
                        borderStrokeWidth: 1.0,
                      ),
                    for (final mapNote in widget.def.notes.whereType<MapNote>())
                      CircleMarker(
                        point: mapNote.location,
                        radius: 6.0,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                        borderColor: Colors.black,
                        borderStrokeWidth: 1.0,
                      ),
                  ]),
                  MarkerLayer(
                    markers: [
                      for (final mapNote
                          in widget.def.notes.whereType<MapNote>())
                        Marker(
                          point: mapNote.location,
                          rotate: true,
                          alignment: Alignment.topRight,
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Text(
                                    mapNote.message,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_newLocation != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _newLocation!,
                          radius: 5.0,
                          color: Colors.red,
                        ),
                      ],
                    ),
                ],
                buttons: widget.def.buttons.toList(),
              ),
              if (locked)
                OverlayButtonWidget(
                  alignment:
                      leftHand ? Alignment.bottomRight : Alignment.bottomLeft,
                  safeBottom: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 24.0,
                  ),
                  onPressed: (_) {
                    ref.read(drawingLockedProvider.notifier).state = false;
                  },
                  icon: kStyleIcons[currentTool] ?? Icons.lock_open,
                ),
              if (!locked && _controller.mapController != null) ...[
                PainterWidget(
                  map: _controller.mapController!,
                  onDrawn: (coords) {
                    if (currentTool == kToolEraser) {
                      final line = LineString(coords);
                      final crossing = widget.def.notes
                          .whereType<MapDrawing>()
                          .where((note) => line.intersects(note.path));
                      ref.read(notesProvider.notifier).deleteDrawings(crossing);
                    } else {
                      final note = MapDrawing(
                        path: LineString(coords),
                        pathType: currentTool,
                      );
                      setState(() {
                        widget.def.notes.add(note);
                      });
                      ref.read(notesProvider.notifier).saveNote(note);
                    }
                  },
                  onTap: (location) {
                    final controller = _controller.mapController!;
                    final locationPx =
                        controller.camera.latLngToScreenOffset(location);
                    double distanceToLocation(LatLng loc2) {
                      return (locationPx -
                              controller.camera.latLngToScreenOffset(loc2))
                          .distance;
                    }

                    bool found = false;
                    final closestNotes =
                        findClosestNotes(location, distanceToLocation);
                    for (final note in closestNotes) {
                      if (note is OsmNote ||
                          (note is MapNote &&
                              note.isNew &&
                              currentTool != kToolEraser)) {
                        _openNoteEditor(note);
                        found = true;
                        break;
                      } else if (note is MapNote &&
                          currentTool == kToolEraser) {
                        // Tapping on a note in eraser mode deletes it.
                        ref.read(notesProvider.notifier).deleteNote(note);
                        found = true;
                        break;
                      }
                    }
                    if (!found && currentTool == kToolEraser) {
                      // Find a map drawing under the tap and delete it.
                      double minDistance = double.infinity;
                      MapDrawing? closest;
                      for (final note
                          in widget.def.notes.whereType<MapDrawing>()) {
                        if (note.path.bounds.contains(location)) {
                          final closestPoint = note.path.closestPoint(location);
                          final distance = distanceToLocation(closestPoint);
                          if (distance < minDistance) {
                            minDistance = distance;
                            closest = note;
                          }
                        }
                      }
                      if (closest != null) {
                        ref.read(notesProvider.notifier).deleteNote(closest);
                      }
                    }
                  },
                  onMapMove: () {
                    recordMapMove(_controller.mapController!.camera);
                    updateNotes();
                  },
                  style:
                      kTypeStyles[currentTool] ?? kTypeStyles[kToolScribble]!,
                ),
                StyleChooserButton(
                  style: currentTool,
                  alignment:
                      leftHand ? Alignment.bottomRight : Alignment.bottomLeft,
                  onChange: (newStyle) {
                    setState(() {
                      ref.read(currentPaintToolProvider.notifier).state =
                          newStyle;
                    });
                  },
                  onLock: () {
                    ref.read(drawingLockedProvider.notifier).state = true;
                  },
                ),
                if (!ref.watch(notesProvider.notifier).undoIsEmpty)
                  UndoButton(
                    alignment:
                        leftHand ? Alignment.bottomRight : Alignment.bottomLeft,
                    onTap: () {
                      ref.read(notesProvider.notifier).undoChange();
                    },
                  ),
              ],
              MapDragCreateButton(
                map: _controller,
                icon: MultiIcon(
                  fontIcon: Icons.add,
                  tooltip: loc.notesAddNote,
                ),
                alignment:
                    leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
                onDragEnd: (pos) {
                  _openNoteEditor(null, pos);
                },
                onTap: () async {
                  final location = ref.read(effectiveLocationProvider);
                  final pos = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapChooserPage(location: location),
                    ),
                  );
                  if (pos != null) _openNoteEditor(null, pos);
                },
              ),
              ApiStatusPane(),
            ],
          ),
        ),
        AreaStatusPanel(),
      ],
    );
  }
}
