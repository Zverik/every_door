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
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/widgets/poi_pane.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
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

  Future<void> updateNearest() async {
    final int radius = farFromUser ? kFarVisibilityRadius : kVisibilityRadius;

    await widget.def.updateNearest(forceRadius: radius);

    // Zoom automatically only when tracking location.
    if (mounted && ref.read(trackingProvider)) {
      _controller.zoomToFit(widget.def.nearestPOI.map((e) => e.location));
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
      updateNearest();
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
          widget.def.nearestPOI,
          isCountedOld: widget.def.isCountedOld,
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
                  ...widget.def.mapLayers(),
                  CircleLayer(
                    circles: [
                      for (final objLocation in widget.def.otherPOI)
                        CircleMarker(
                          point: objLocation,
                          color: Colors.black.withValues(alpha: 0.4),
                          radius: 2.0,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (var i = widget.def.nearestPOI.length - 1;
                          i >= 0;
                          i--)
                        Marker(
                          point: widget.def.nearestPOI[i].location,
                          rotate: true,
                          child: widget.def
                              .buildMarker(i, widget.def.nearestPOI[i]),
                        ),
                    ],
                  ),
                ],
                buttons: [
                  // Filter button
                  MapButton(
                    icon: ref.watch(poiFilterProvider).isNotEmpty
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    tooltip: loc.mapFilter,
                    onPressed: () {
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
            widget.def.openEditor(context, pos);
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
              widget.def.openEditor(context, location);
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
