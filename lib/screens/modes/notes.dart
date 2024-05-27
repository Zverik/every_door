import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/geometry.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/editor/note.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/painter.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:every_door/widgets/style_chooser.dart';
import 'package:every_door/widgets/track_button.dart';
import 'package:every_door/widgets/walkpath.dart';
import 'package:every_door/widgets/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotesPane extends ConsumerStatefulWidget {
  final Widget? areaStatusPanel;

  const NotesPane({super.key, this.areaStatusPanel});

  @override
  ConsumerState<NotesPane> createState() => _NotesPaneState();
}

class _NotesPaneState extends ConsumerState<NotesPane> {
  static const kEnablePainter = true;
  static const kZoomOffset = 1.0;

  List<BaseNote> _notes = [];
  final controller = MapController();
  final _mapKey = GlobalKey();
  late final StreamSubscription<MapEvent> mapSub;
  LatLng? newLocation;

  @override
  initState() {
    super.initState();
    mapSub = controller.mapEventStream.listen(onMapEvent);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateNotes();
    });
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  recordMapMove(MapCamera camera) {
    ref.read(effectiveLocationProvider.notifier).set(camera.center);
    ref.read(zoomProvider.notifier).state = camera.zoom;
  }

  onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController ||
        event.source == MapEventSource.nonRotatedSizeChange;
    if (event is MapEventMoveEnd && !fromController) {
      recordMapMove(event.camera);
    }
  }

  updateNotes() async {
    final notes = await ref.read(notesProvider).fetchAllNotes(
        center: controller.camera.center, radius: kNotesVisibilityRadius);
    // .fetchAllNotes(bounds: controller.camera.visibleBounds);
    if (!mounted) return;
    setState(() {
      _notes = notes.where((n) => !n.deleting).toList();
    });
  }

  _openNoteEditor(BaseNote? note, [LatLng? location]) async {
    if (note is MapDrawing) return;

    if (location != null) {
      setState(() {
        newLocation = location;
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
      newLocation = null;
    });
  }

  List<BaseNote> findMarkerUnderTap(LatLng location) {
    final locationPx = controller.camera.latLngToScreenPoint(location);
    distanceToLocation(LatLng loc2) {
      return locationPx.distanceTo(controller.camera.latLngToScreenPoint(loc2));
    }

    const kMaxTapDistance = 30;
    final closestNotes = _notes
        .where(
            (note) => controller.camera.visibleBounds.contains(note.location))
        .where((note) => distanceToLocation(note.location) <= kMaxTapDistance)
        .toList();

    closestNotes.sort((a, b) => distanceToLocation(a.location)
        .compareTo(distanceToLocation(b.location)));
    return closestNotes;
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final tileLayer = TileLayerOptions(ref.watch(selectedImageryProvider));
    final currentTool = ref.watch(currentPaintToolProvider);
    final locked = ref.watch(drawingLockedProvider);
    ref.watch(geolocationProvider); // not using, but it triggers repaints
    final loc = AppLocalizations.of(context)!;

    // Rotate the map according to the global rotation value.
    ref.listen(rotationProvider, (_, double newValue) {
      if ((newValue - controller.camera.rotation).abs() >= 1.0)
        controller.rotate(newValue);
    });

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      controller.move(next, controller.camera.zoom);
      updateNotes();
    });
    ref.listen(notesProvider, (_, next) {
      updateNotes();
    });
    EdgeInsets safePadding = MediaQuery.of(context).padding;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                key: _mapKey,
                mapController: controller,
                options: MapOptions(
                  initialCenter: ref.read(effectiveLocationProvider),
                  minZoom: kEditMinZoom,
                  maxZoom: kEditMaxZoom,
                  initialZoom: ref.watch(zoomProvider) + kZoomOffset,
                  initialRotation: ref.watch(rotationProvider),
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all -
                        InteractiveFlag.flingAnimation -
                        InteractiveFlag.rotate,
                    rotationThreshold: kRotationThreshold,
                  ),
                  onTap: !locked
                      ? null
                      : (position, ll) {
                          final markers = findMarkerUnderTap(ll);
                          for (final note in markers) {
                            if (note is OsmNote ||
                                (note is MapNote && note.isNew)) {
                              _openNoteEditor(note);
                              break;
                            }
                          }
                        },
                ),
                children: [
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
                  WalkPathPolyline(),
                  LocationMarkerWidget(tracking: false),
                  PolylineLayer(
                    polylines: [
                      for (final drawing in _notes.whereType<MapDrawing>())
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
                    for (final osmNote in _notes.whereType<OsmNote>())
                      CircleMarker(
                        point: osmNote.location,
                        radius: 15.0,
                        color: osmNote.isChanged
                            ? Colors.yellow.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                        borderColor: Colors.black,
                        borderStrokeWidth: 1.0,
                      ),
                    for (final mapNote in _notes.whereType<MapNote>())
                      CircleMarker(
                        point: mapNote.location,
                        radius: 6.0,
                        color: Colors.lightBlueAccent.withOpacity(0.8),
                        borderColor: Colors.black,
                        borderStrokeWidth: 1.0,
                      ),
                  ]),
                  MarkerLayer(
                    markers: [
                      for (final mapNote in _notes.whereType<MapNote>())
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
                  if (locked) ...[
                    OverlayButtonWidget(
                      alignment: leftHand
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      safeBottom: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 24.0,
                      ),
                      onPressed: () {
                        ref.read(drawingLockedProvider.notifier).state = false;
                      },
                      icon: kStyleIcons[currentTool] ?? Icons.lock_open,
                    ),
                    OverlayButtonWidget(
                      alignment:
                          leftHand ? Alignment.topRight : Alignment.topLeft,
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.0,
                        vertical: 10.0,
                      ),
                      icon: Icons.menu,
                      tooltip: loc.mapSettings,
                      safeRight: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                    // Tracking button
                    OverlayButtonWidget(
                      alignment:
                          leftHand ? Alignment.topLeft : Alignment.topRight,
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.0,
                        vertical: 10.0,
                      ),
                      safeRight: true,
                      icon: Icons.my_location,
                      tooltip: loc.mapLocate,
                      onPressed: () {
                        // Jump to the current location.
                        final LatLng location = ref.read(geolocationProvider) ??
                            ref.read(effectiveLocationProvider);
                        controller.move(location, controller.camera.zoom);
                      },
                      onLongPressed: () {
                        if (ref.read(rotationProvider) != 0.0) {
                          ref.read(rotationProvider.notifier).state = 0.0;
                          controller.rotate(0.0);
                        }
                      },
                    ),
                    ZoomButtonsWidget(
                      alignment: leftHand
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.0 +
                            (leftHand ? safePadding.left : safePadding.right),
                        vertical: 100.0,
                      ),
                    ),
                  ]
                ],
              ),
              if (kEnablePainter && !locked) ...[
                PainterWidget(
                  map: controller,
                  onDrawn: (coords) {
                    if (currentTool == kToolEraser) {
                      final line = LineString(coords);
                      final crossing = _notes
                          .whereType<MapDrawing>()
                          .where((note) => line.intersects(note.path));
                      ref.read(notesProvider).deleteDrawings(crossing);
                    } else {
                      final note = MapDrawing(
                        path: LineString(coords),
                        pathType: currentTool,
                      );
                      setState(() {
                        _notes.add(note);
                      });
                      ref.read(notesProvider).saveNote(note);
                    }
                  },
                  onTap: (location) {
                    final locationPx =
                        controller.camera.latLngToScreenPoint(location);
                    distanceToLocation(LatLng loc2) {
                      return locationPx.distanceTo(
                          controller.camera.latLngToScreenPoint(loc2));
                    }

                    bool found = false;
                    final closestNotes = findMarkerUnderTap(location);
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
                        ref.read(notesProvider).deleteNote(note);
                        found = true;
                        break;
                      }
                    }
                    if (!found && currentTool == kToolEraser) {
                      // Find a map drawing under the tap and delete it.
                      double minDistance = double.infinity;
                      MapDrawing? closest;
                      for (final note in _notes.whereType<MapDrawing>()) {
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
                        ref.read(notesProvider).deleteNote(closest);
                      }
                    }
                  },
                  onMapMove: () {
                    recordMapMove(controller.camera);
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
                if (!ref.watch(notesProvider).undoIsEmpty)
                  UndoButton(
                    alignment:
                        leftHand ? Alignment.bottomRight : Alignment.bottomLeft,
                    onTap: () {
                      ref.read(notesProvider).undoChange();
                    },
                  ),
              ],
              MapDragCreateButton(
                mapKey: _mapKey,
                map: controller,
                icon: Icons.add,
                tooltip: loc.notesAddNote,
                alignment:
                    leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
                onDragEnd: (pos) {
                  _openNoteEditor(null, pos);
                },
                onTap: () async {
                  final pos = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MapChooserPage(location: controller.camera.center),
                    ),
                  );
                  if (pos != null) _openNoteEditor(null, pos);
                },
              ),
              ApiStatusPane(),
            ],
          ),
        ),
        if (widget.areaStatusPanel != null) widget.areaStatusPanel!,
      ],
    );
  }
}
