import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/widgets/area_status.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/multi_hit.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntrancesPane extends ConsumerStatefulWidget {
  final EntrancesModeDefinition def;

  const EntrancesPane(this.def, {super.key});

  @override
  ConsumerState<EntrancesPane> createState() => _EntrancesPaneState();
}

class _EntrancesPaneState extends ConsumerState<EntrancesPane> {
  final _controller = CustomMapController();
  final Map<String, GlobalKey> _globalKeys = {};

  @override
  void initState() {
    super.initState();
    widget.def.addListener(onDefChange);
    updateNearest();
  }

  @override
  void dispose() {
    widget.def.removeListener(onDefChange);
    super.dispose();
  }

  void onDefChange() {
    if (mounted) setState(() {});
  }

  Future<void> updateNearest() async {
    await widget.def.updateNearest();

    // Prepare a map of global keys for [MultiHitMarkerLayer].
    for (final e in widget.def.nearest) {
      if (!_globalKeys.containsKey(e.databaseId)) {
        _globalKeys[e.databaseId] = GlobalKey();
      }
    }
  }

  OsmChange? findByKey(Key key) {
    if (key is! GlobalKey) return null;
    for (final e in widget.def.nearest) {
      if (_globalKeys[e.databaseId] == key) return e;
    }
    return null;
  }

  Future<void> chooseEditorToOpen(Iterable<OsmChange> elements) async {
    if (elements.isEmpty) return;
    if (elements.length == 1) {
      widget.def.openEditor(
        context: context,
        element: elements.first,
      );
      return;
    }
    // Many elements: present a menu.
    final result = await showDialog<OsmChange>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          for (final e in elements)
            SimpleDialogOption(
              child: widget.def.disambiguationLabel(context, e),
              onPressed: () {
                Navigator.pop(context, e);
              },
            ),
        ],
      ),
    );
    if (result != null && mounted) {
      widget.def.openEditor(
        context: context,
        element: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final primaryButton = widget.def.getButton(context, true);
    final secondaryButton = widget.def.getButton(context, false);

    ref.watch(imageryIsBaseProvider); // to update the overlay

    ref.listen(needMapUpdateProvider, (_, next) {
      updateNearest();
    });
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      updateNearest();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(children: [
            CustomMap(
              controller: _controller,
              drawPinMarker: false,
              updateState: true,
              hasFloatingButton: primaryButton != null,
              layers: [
                ...widget.def.mapLayers(),
                MultiHitMarkerLayer(
                  markers: [
                    for (final element in widget.def.nearest)
                      widget.def.buildMarker(element)?.buildMarker(
                            key: _globalKeys[element.databaseId],
                            point: element.location,
                          ),
                  ],
                  onTap: (tapped) {
                    final objects =
                        tapped.map((k) => findByKey(k)).whereType<OsmChange>();
                    chooseEditorToOpen(objects);
                  },
                ),
                if (widget.def.newLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: widget.def.newLocation!,
                        radius: 5.0,
                        color: Colors.red,
                      ),
                    ],
                  ),
              ],
            ),
            if (primaryButton != null)
              DraggableEditButton(
                controller: _controller,
                icon: primaryButton,
                alignment:
                    leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
                adjustZoom: widget.def.adjustZoomPrimary,
                onEditor: (context, pos) {
                  widget.def.openEditor(
                    context: context,
                    isPrimary: true,
                    location: pos,
                  );
                },
              ),
            if (secondaryButton != null)
              DraggableEditButton(
                controller: _controller,
                icon: secondaryButton,
                alignment:
                    !leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
                adjustZoom: widget.def.adjustZoomSecondary,
                onEditor: (context, pos) {
                  widget.def.openEditor(
                    context: context,
                    isPrimary: false,
                    location: pos,
                  );
                },
              ),
            ApiStatusPane(),
          ]),
        ),
        AreaStatusPanel(),
      ],
    );
  }
}

class DraggableEditButton extends StatefulWidget {
  final MultiIcon icon;
  final double adjustZoom;
  final Function(BuildContext, LatLng) onEditor;
  final CustomMapController controller;
  final Alignment alignment;

  const DraggableEditButton({
    super.key,
    required this.controller,
    required this.icon,
    this.adjustZoom = 0.0,
    required this.onEditor,
    this.alignment = Alignment.bottomRight,
  });

  @override
  State<DraggableEditButton> createState() => _DraggableEditButtonState();
}

class _DraggableEditButtonState extends State<DraggableEditButton> {
  double? _savedZoom;

  @override
  Widget build(BuildContext context) {
    return MapDragCreateButton(
      map: widget.controller,
      icon: widget.icon,
      alignment: widget.alignment,
      onDragStart: () {
        final adjust = widget.adjustZoom;
        if (adjust != 0.0 && _savedZoom == null) {
          final controller = widget.controller.mapController!;
          _savedZoom = controller.camera.zoom;
          controller.move(controller.camera.center, _savedZoom! + adjust);
        }
      },
      onDragEnd: (pos) {
        if (_savedZoom != null) {
          final controller = widget.controller.mapController!;
          controller.move(controller.camera.center, _savedZoom!);
          _savedZoom = null;
        }
        widget.onEditor(context, pos);
      },
      onTap: () async {
        final pos = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapChooserPage(),
          ),
        );
        if (pos != null && context.mounted) {
          widget.onEditor(context, pos);
        }
      },
    );
  }
}
