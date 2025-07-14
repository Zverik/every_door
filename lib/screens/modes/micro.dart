import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/widgets/area_status.dart';
import 'package:every_door/widgets/legend.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/map_drag_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/widgets/poi_pane.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class MicromappingPane extends ConsumerStatefulWidget {
  final MicromappingModeDefinition def;

  const MicromappingPane(this.def, {super.key});

  @override
  ConsumerState createState() => _MicromappingPageState();
}

class _MicromappingPageState extends ConsumerState<MicromappingPane> {
  // How much to zoom in when tapping a bunch of elements in micromapping.
  static const kMicromappingTapZoom = 19.0;

  final _controller = CustomMapController();
  List<OsmChange>? _microPOI;
  double? _savedZoom;

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
    // Disabling updates in zoomed in mode.
    if (ref.read(microZoomedInProvider) != null) return;

    await widget.def.updateNearest();

    if (mounted) {
      widget.def.updateLegend(context);
    }

    // Zoom automatically only when tracking location.
    if (mounted && ref.read(trackingProvider)) {
      _controller.zoomToFit(widget.def.nearestPOI.map((e) => e.location));
    }
  }

  Future<void> micromappingTap(LatLng position, double Function(LatLng) distance) async {
    List<OsmChange> amenitiesAtCenter = widget.def.nearestPOI
        .where((element) => distance(element.location) <= kTapRadius)
        .toList();

    if (amenitiesAtCenter.isEmpty) return;
    if (amenitiesAtCenter.length == 1 ||
        ref.read(microZoomedInProvider) != null ||
        !widget.def.enableZoomingIn) {
      if (amenitiesAtCenter.length > 1) {
        // Sort by distance.
        amenitiesAtCenter.sort(
            (a, b) => distance(a.location).compareTo(distance(b.location)));
      }
      // Open the editor for the first object.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: amenitiesAtCenter.first),
          fullscreenDialog: true,
        ),
      );
      // When finished, reset zoomed in state.
      ref.read(microZoomedInProvider.notifier).state = null;
      _microPOI = null;
      updateNearest();
    } else {
      // Multiple amenities: zoom in and enhance.
      ref.read(microZoomedInProvider.notifier).state = LatLngBounds.fromPoints(
          amenitiesAtCenter.map((a) => a.location).toList());
      // Disable tracking.
      ref.read(trackingProvider.notifier).state = false;
      // updateNearest(forceLocation: area.center);
      setState(() {
        _microPOI = amenitiesAtCenter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZoomedIn =
        ref.watch(microZoomedInProvider) != null && _microPOI != null;
    final poi = isZoomedIn ? _microPOI ?? const [] : widget.def.nearestPOI;

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
      updateNearest();
    });
    ref.listen<LatLngBounds?>(microZoomedInProvider, (_, next) {
      // Only update when returning from the mode.
      if (next == null) {
        _microPOI = null;
        updateNearest();
      }
    });

    // For micromapping, zoom in and out.
    ref.listen<LatLngBounds?>(microZoomedInProvider,
        (_, LatLngBounds? newState) {
      final controller = _controller.mapController;
      if (controller == null) return;
      double oldZoom = controller.camera.zoom;
      double targetZoom =
          newState != null ? kMicromappingTapZoom : (_savedZoom ?? oldZoom);
      if (newState != null && targetZoom < oldZoom) targetZoom = oldZoom;
      _savedZoom = oldZoom;
      controller.move(newState?.center ?? controller.camera.center, targetZoom);
    });

    final screenSize = MediaQuery.of(context).size;
    final isWide =
        screenSize.width > screenSize.height && screenSize.height < 600;

    final Widget bottomPane;
    if (apiStatus != ApiStatus.idle) {
      bottomPane = Expanded(
        flex: 10,
        child: buildApiStatusPane(context, apiStatus),
      );
    } else if (isZoomedIn) {
      // We want to constraint vertical size, so that tiles
      // don't take precious space from the map.
      final bottomPaneChild = SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: isWide,
        child: PoiPane(_microPOI ?? const []),
      );
      final mediaHeight = MediaQuery.of(context).size.height;
      if (isWide || mediaHeight <= 600)
        bottomPane = Expanded(
          flex: 10,
          child: bottomPaneChild,
        );
      else
        bottomPane = SizedBox(
          height: mediaHeight < 900 ? 300 : 400,
          child: bottomPaneChild,
        );
    } else if (!isWide) {
      bottomPane = LegendPane(widget.def.legend);
    } else {
      bottomPane = SizedBox(
        child: SingleChildScrollView(
          child: SafeArea(
            left: false,
            bottom: false,
            right: false,
            child: LegendPane(widget.def.legend),
          ),
        ),
        width: 200.0,
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
                onTap: micromappingTap,
                updateState: true,
                hasFloatingButton: widget.def.nearestPOI.isEmpty && !isWide,
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
                      for (var i = poi.length - 1; i >= 0; i--)
                        Marker(
                          point: poi[i].location,
                          rotate: true,
                          child: widget.def.buildMarker(i, poi[i], isZoomedIn),
                        ),
                    ],
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
            ref.read(microZoomedInProvider.notifier).state = null;
            widget.def.openEditor(context, pos);
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
