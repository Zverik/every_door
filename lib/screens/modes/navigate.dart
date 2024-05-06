import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:every_door/widgets/track_button.dart';
import 'package:every_door/widgets/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavigationPane extends ConsumerStatefulWidget {
  const NavigationPane({super.key});

  @override
  ConsumerState<NavigationPane> createState() => _NavigationPaneState();
}

class _NavigationPaneState extends ConsumerState<NavigationPane> {
  late LatLng center;
  final controller = MapController();
  late final StreamSubscription<MapEvent> mapSub;

  @override
  void initState() {
    super.initState();
    center = ref.read(effectiveLocationProvider);
    mapSub = controller.mapEventStream.listen(onMapEvent);
  }

  onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController ||
        event.source == MapEventSource.nonRotatedSizeChange;
    if (event is MapEventWithMove) {
      center = event.camera.center;
      if (!fromController) {
        ref.read(zoomProvider.notifier).state = event.camera.zoom;
        if (event.camera.zoom > kEditMinZoom) {
          // Switch navigation mode off
          ref.read(rotationProvider.notifier).state = 0;
          ref.read(navigationModeProvider.notifier).state = false;
        }
      }
    } else if (event is MapEventMoveEnd) {
      if (!fromController) {
        ref.read(effectiveLocationProvider.notifier).set(event.camera.center);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;
    EdgeInsets safePadding = MediaQuery.of(context).padding;

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      controller.move(next, controller.camera.zoom);
      setState(() {
        center = next;
      });
    });

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: kEditMinZoom,
            minZoom: 4.0,
            maxZoom: kEditMinZoom + 1.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all -
                  InteractiveFlag.flingAnimation -
                  InteractiveFlag.rotate,
            ),
          ),
          children: [
            AttributionWidget(kOSMImagery),
            TileLayerOptions(kOSMImagery).buildTileLayer(),
            LocationMarkerWidget(),
            // Settings button
            OverlayButtonWidget(
              alignment: leftHand ? Alignment.topRight : Alignment.topLeft,
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
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ZoomButtonsWidget(
              alignment:
                  leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
              padding: EdgeInsets.symmetric(
                horizontal:
                    0.0 + (leftHand ? safePadding.left : safePadding.right),
                vertical: 20.0,
              ),
            ),
          ],
        ),
        ApiStatusPane(),
      ],
    );
  }
}
