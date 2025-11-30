import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/modes/definitions/classic.dart';
import 'package:every_door/widgets/area_status.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class ClassicModePane extends ConsumerStatefulWidget {
  final ClassicModeDefinition def;

  const ClassicModePane(this.def, {super.key});

  @override
  ConsumerState createState() => _ClassicModePageState();
}

class _ClassicModePageState extends ConsumerState<ClassicModePane> {
  final _controller = CustomMapController();

  @override
  void initState() {
    super.initState();

    widget.def.addListener(onDefChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateNearest();
    });
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
  }

  @override
  Widget build(BuildContext context) {
    final apiStatus = ref.watch(apiStatusProvider);
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;

    ref.listen(editorModeProvider, (_, next) {
      updateNearest();
    });
    ref.listen(needMapUpdateProvider, (_, next) {
      updateNearest();
    });
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      updateNearest();
    });

    final screenSize = MediaQuery.of(context).size;
    final isWide =
        screenSize.width > screenSize.height && screenSize.height < 600;

    return Stack(
      children: [
        Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 10,
              child: Stack(
                children: [
                  CustomMap(
                    controller: _controller,
                    updateState: true,
                    hasFloatingButton: widget.def.nearestPOI.isEmpty && !isWide,
                    layers: [
                      ...widget.def.overlays.map((i) => i.buildLayer()),
                      ...widget.def.mapLayers(),
                      MarkerLayer(
                        markers: [
                          for (var i = widget.def.nearestPOI.length - 1;
                              i >= 0;
                              i--)
                            Marker(
                              point: widget.def.nearestPOI[i].location,
                              rotate: true,
                              child: GestureDetector(
                                child: widget.def
                                    .buildMarker(widget.def.nearestPOI[i]),
                                onTap: () {
                                  widget.def.openEditor(
                                      context: context,
                                      element: widget.def.nearestPOI[i]);
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                    buttons: widget.def.buttons.toList(),
                  ),
                  ApiStatusPane(),
                ],
              ),
            ),
            isWide
                ? RotatedBox(quarterTurns: 3, child: AreaStatusPanel())
                : AreaStatusPanel(),
          ],
        ),
        MapDragCreateButton(
          map: _controller,
          icon: MultiIcon(
            fontIcon: Icons.add,
            tooltip: loc.notesAddNote,
          ),
          alignment: leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
          onDragEnd: (pos) {
            ref.read(microZoomedInProvider.notifier).state = null;
            widget.def.openEditor(context: context, location: pos);
          },
          onTap: () async {
            ref.read(microZoomedInProvider.notifier).state = null;
            final location = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapChooserPage(),
                fullscreenDialog: true,
              ),
            );
            if (context.mounted && location != null) {
              widget.def.openEditor(context: context, location: location);
            }
          },
        ),
      ],
    );
  }
}
