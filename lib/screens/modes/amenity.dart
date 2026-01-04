// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/modes/definitions/amenity.dart';
import 'package:every_door/widgets/area_status.dart';
import 'package:every_door/widgets/filter.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/widgets/poi_pane.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class AmenityPane extends ConsumerStatefulWidget {
  final AmenityModeDefinition def;

  const AmenityPane(this.def, {super.key});

  @override
  ConsumerState createState() => _AmenityPageState();
}

class _AmenityPageState extends ConsumerState<AmenityPane> {
  static const kFarDistance =
      150; // when we turn to "far location" mode, meters

  final _controller = CustomMapController();
  bool farFromUser = false;

  @override
  void initState() {
    super.initState();

    widget.def.addListener(onDefChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateFarFromUser();
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

  @override
  void didUpdateWidget(covariant AmenityPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resubscribe, as per this method documentation.
    oldWidget.def.removeListener(onDefChange);
    widget.def.addListener(onDefChange);
  }

  void updateFarFromUser() {
    final gpsLocation = ref.read(geolocationProvider);
    bool newFar;
    if (gpsLocation != null) {
      final location = ref.read(effectiveLocationProvider);
      final distance = DistanceEquirectangular();
      newFar = distance(location, gpsLocation) >= kFarDistance;
    } else {
      newFar = true;
    }

    if (newFar != farFromUser) {
      setState(() {
        farFromUser = newFar;
      });
    }
  }

  Future<void> updateNearest([LatLngBounds? bounds]) async {
    bounds ??= ref.read(visibleBoundsProvider);
    if (bounds == null) return;
    await widget.def.updateNearest(bounds);

    // Zoom automatically only when tracking location.
    if (mounted && ref.read(trackingProvider)) {
      _controller.zoomToFit(widget.def.nearest
          .take(widget.def.maxTileCount)
          .map((e) => e.location));
    }
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
    ref.listen(poiFilterProvider, (_, next) {
      updateNearest();
    });
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      updateFarFromUser();
    });
    ref.listen(visibleBoundsProvider, (_, next) {
      updateNearest(next);
    });

    final screenSize = MediaQuery.of(context).size;
    final isWide =
        screenSize.width > screenSize.height && screenSize.height < 600;

    final Widget bottomPane;
    if (apiStatus != ApiStatus.idle) {
      bottomPane = Expanded(
        flex: farFromUser ? 10 : 23,
        child: buildApiStatusPane(context, apiStatus),
      );
    } else {
      // We want to constraint vertical size, so that tiles
      // don't take precious space from the map.
      final bottomPaneChild = SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: isWide,
        child: PoiPane(
          amenities: widget.def.nearest.take(widget.def.maxTileCount).toList(),
          describer: widget.def.describer,
          getAmenityData: widget.def.getAmenityData,
          onTap: (amenity) {
            ref.read(microZoomedInProvider.notifier).state = null;
            widget.def.openEditor(context: context, element: amenity);
          },
        ),
      );
      final mediaHeight = MediaQuery.of(context).size.height;
      if (isWide || mediaHeight <= 600)
        bottomPane = Expanded(
          flex: farFromUser ? 10 : 23,
          child: bottomPaneChild,
        );
      else
        bottomPane = SizedBox(
          height: farFromUser && mediaHeight < 900 ? 300 : 400,
          child: bottomPaneChild,
        );
    }

    return Stack(
      children: [
        Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 10,
              child: CustomMap(
                controller: _controller,
                drawZoomButtons: farFromUser,
                updateState: true,
                layers: [
                  ...widget.def.overlays.map((i) => i.buildLayer()),
                  ...widget.def.mapLayers(),
                  widget.def.otherObjectsLayer(),
                  MarkerLayer(
                    markers: [
                      for (var i = widget.def.nearest.length - 1; i >= 0; i--)
                        Marker(
                          point: widget.def.nearest[i].location,
                          rotate: true,
                          child:
                              widget.def.buildMarker(i, widget.def.nearest[i]),
                        ),
                    ],
                  ),
                ],
                buttons: [
                  // Filter button
                  MapButton(
                    icon: MultiIcon(
                        fontIcon: ref.watch(poiFilterProvider).isNotEmpty
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined),
                    tooltip: loc.mapFilter,
                    onPressed: (_) {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            color: Colors.white,
                            height: 250.0,
                            padding: EdgeInsets.all(15.0),
                            child: PoiFilterPane(),
                          );
                        },
                      );
                    },
                  ),
                  ...widget.def.buttons,
                ],
              ),
            ),
            isWide
                ? RotatedBox(quarterTurns: 3, child: AreaStatusPanel())
                : AreaStatusPanel(),
            bottomPane,
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
            widget.def.openEditor(context: context, location: pos);
          },
          onTap: () async {
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

  Widget buildApiStatusPane(BuildContext context, ApiStatus apiStatus) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20.0),
        Text(
          getApiStatusLoc(apiStatus, loc),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }
}
