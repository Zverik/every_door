import 'dart:async';
import 'dart:math' show min, max;

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/closest_points.dart';
import 'package:every_door/widgets/pin_marker.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:every_door/widgets/loc_marker.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:every_door/widgets/walkpath.dart';
import 'package:every_door/widgets/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:every_door/helpers/tile_layers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomMapController {
  Function(Iterable<LatLng>)? zoomListener;
  MapController? mapController;
  GlobalKey? mapKey;

  setLocation({LatLng? location, double? zoom}) {
    if (mapController != null) {
      mapController!.move(location ?? mapController!.camera.center,
          zoom ?? mapController!.camera.zoom);
    }
  }

  zoomToFit(Iterable<LatLng> locations) {
    if (locations.isNotEmpty) {
      if (zoomListener != null) zoomListener!(locations);
    }
  }
}

/// General map widget for every map in Every Door. Encloses layer management,
/// interaction, additional buttons etc etc.
class CustomMap extends ConsumerStatefulWidget {
  final void Function(LatLng, double Function(LatLng))? onTap;
  final CustomMapController? controller;
  final List<Widget> layers;
  final List<MapButton> buttons;
  final bool drawZoomButtons;

  /// When there is a floating button on the screen, zoom buttons
  /// need to be moved higher.
  final bool hasFloatingButton;
  final bool drawStandardButtons;
  final bool drawPinMarker;
  final bool faintWalkPath;
  final bool interactive;
  final bool track;
  final bool onlyOSM;
  final bool allowRotation;
  final bool updateState;
  final bool switchToNavigate;

  const CustomMap({
    super.key,
    this.onTap,
    this.controller,
    this.layers = const [],
    this.buttons = const [],
    this.drawZoomButtons = true,
    this.hasFloatingButton = false,
    this.drawStandardButtons = true,
    this.drawPinMarker = true,
    this.faintWalkPath = true,
    this.interactive = true,
    this.track = true,
    this.onlyOSM = false,
    this.allowRotation = true,
    this.switchToNavigate = true,
    this.updateState = false,
  });

  @override
  ConsumerState createState() => _CustomMapState();
}

class _CustomMapState extends ConsumerState<CustomMap> {
  static const kMapZoom = 17.0;

  final MapController _controller = MapController();
  final _mapKey = GlobalKey();
  LatLng? _center;
  StreamSubscription<MapEvent>? mapSub;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.zoomListener = onControllerZoom;
      widget.controller!.mapKey = _mapKey;
    }
  }

  @override
  void dispose() {
    widget.controller?.mapController = null;
    widget.controller?.mapKey = null;
    mapSub?.cancel();
    super.dispose();
  }

  void onMapReady() {
    if (widget.updateState) {
      mapSub = _controller.mapEventStream.listen(onMapEvent);
    }
    widget.controller?.mapController = _controller;
    _center = _controller.camera.center;
    setState(() {});
  }

  void onMapEvent(MapEvent event) {
    bool fromController = event.source == MapEventSource.mapController ||
        event.source == MapEventSource.nonRotatedSizeChange;

    if (event is MapEventWithMove) {
      if (!fromController) {
        ref.read(trackingProvider.notifier).state = false;
        ref.read(zoomProvider.notifier).state = event.camera.zoom;
        if (widget.switchToNavigate) {
          final bool isNavigating = ref.read(navigationModeProvider);
          if (isNavigating) {
            if (event.camera.zoom > kEditMinZoom) {
              // Switch navigation mode off
              ref.read(navigationModeProvider.notifier).state = false;
            }
          } else if (event.camera.zoom < kEditMinZoom) {
            // Switch navigation mode on
            ref.read(navigationModeProvider.notifier).state = true;
            ref.read(rotationProvider.notifier).state = 0;
          }
        }
      }
      if (event.camera.center != _center) {
        _center = _controller.camera.center;
        setState(() {});
      }
    } else if (event is MapEventMoveEnd) {
      if (!fromController) {
        ref.read(effectiveLocationProvider.notifier).set(event.camera.center);
      }
    } else if (event is MapEventRotateEnd) {
      if (event.source != MapEventSource.mapController) {
        double rotation = _controller.camera.rotation;
        while (rotation > 200) rotation -= 360;
        while (rotation < -200) rotation += 360;
        if (rotation.abs() < kRotationThreshold) {
          ref.read(rotationProvider.notifier).state = 0.0;
          _controller.rotate(0.0);
        } else {
          ref.read(rotationProvider.notifier).state = rotation;
        }
      }
    }
  }

  double _calculateZoom(Iterable<LatLng> locations, EdgeInsets padding) {
    // Add a virtual location to keep center.
    // Here we don't reproject, since on low zooms Mercator could be considered equirectandular.
    // Taking first 9, for we display only 9.
    final bounds = LatLngBounds.fromPoints(locations.take(9).toList());
    final center = _controller.camera.center;
    final dlat = max(
      (bounds.north - center.latitude).abs(),
      (bounds.south - center.latitude).abs(),
    );
    final dlon = max(
      (bounds.east - center.longitude).abs(),
      (bounds.west - center.longitude).abs(),
    );
    final newBounds = LatLngBounds(
      LatLng(center.latitude - dlat, center.longitude - dlon),
      LatLng(center.latitude + dlat, center.longitude + dlon),
    );
    return CameraFit.bounds(
            bounds: newBounds, padding: padding, maxZoom: kMapZoom + 1)
        .fit(_controller.camera)
        .zoom;
  }

  onControllerZoom(Iterable<LatLng> locations) {
    const kPadding = EdgeInsets.all(12.0);
    const kZoomThreshold = 0.2;
    const kTooCloseThreshold = 10.0; // meters. I know, bad.

    double zoom = _calculateZoom(locations, kPadding);
    if (zoom < kMapZoom - 1 && locations.length >= 6) {
      // When outliers are too far, we can skip them I guess.
      zoom = _calculateZoom(locations.take(locations.length - 2), kPadding);
    }

    final curZoom = _controller.camera.zoom;
    double maxZoomHere = kMapZoom;
    if (zoom > kMapZoom && zoom > curZoom) {
      // Overzoom only if points are too close.
      if (closestPairDistance(locations) <= kTooCloseThreshold) maxZoomHere++;
    }
    if (zoom < kMapZoom - 1)
      zoom = min(curZoom, kMapZoom - 1);
    else if (zoom > maxZoomHere) zoom = max(curZoom, maxZoomHere);
    if ((zoom - curZoom).abs() >= kZoomThreshold) {
      _controller.move(_controller.camera.center, zoom);
      ref.read(zoomProvider.notifier).state = zoom;
    }
  }

  void onMapTap(TapPosition pos, LatLng location) {
    final locationPx = _controller.camera.latLngToScreenOffset(location);

    double distanceToLocation(LatLng loc2) {
      return (locationPx - _controller.camera.latLngToScreenOffset(loc2))
          .distance;
    }

    if (widget.onTap != null) {
      widget.onTap!(location, distanceToLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    // TODO: move those two to tracking provider
    if (widget.track) {
      // When tracking location, move map and notify the poi list.
      ref.listen<LatLng?>(geolocationProvider, (_, LatLng? location) {
        if (location != null && ref.watch(trackingProvider)) {
          _controller.move(location, _controller.camera.zoom);
          ref.read(effectiveLocationProvider.notifier).set(location);
        }
      });

      // When turning the tracking on, move the map immediately.
      ref.listen(trackingProvider, (_, bool newState) {
        if (trackLocation != null && newState) {
          _controller.move(trackLocation, _controller.camera.zoom);
          ref.read(effectiveLocationProvider.notifier).set(trackLocation);
        }
      });
    }

    ref.watch(geolocationProvider); // not using, but it triggers repaints

    // Rotate the map according to the global rotation value.
    ref.listen(rotationProvider, (_, double newValue) {
      if ((newValue - _controller.camera.rotation).abs() >= 1.0) {
        _controller.rotate(newValue);
      }
    });

    // Update map position when changing panes.
    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      _controller.move(next, _controller.camera.zoom);
    });

    final imagery = ref.watch(selectedImageryProvider);
    final isNavigating = ref.read(navigationModeProvider);
    final tileLayer = TileLayerOptions(imagery);
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;

    return FlutterMap(
      mapController: _controller,
      key: _mapKey,
      options: MapOptions(
        initialCenter: ref.watch(effectiveLocationProvider),
        initialRotation: ref.watch(rotationProvider),
        initialZoom: ref.watch(zoomProvider),
        minZoom: isNavigating ? 4.0 : kEditMinZoom - 0.1,
        maxZoom: isNavigating ? kEditMinZoom + 0.1 : kEditMaxZoom,
        interactionOptions: InteractionOptions(
          flags: !widget.interactive
              ? InteractiveFlag.none
              : InteractiveFlag.all -
                  InteractiveFlag.flingAnimation -
                  (widget.allowRotation ? 0 : InteractiveFlag.rotate),
          rotationThreshold: kRotationThreshold,
        ),
        onMapReady: onMapReady,
        onTap: widget.onTap == null ? null : onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate: tileLayer.urlTemplate,
          wmsOptions: tileLayer.wmsOptions,
          tileProvider: tileLayer.tileProvider,
          minNativeZoom: tileLayer.minNativeZoom,
          maxNativeZoom: tileLayer.maxNativeZoom,
          maxZoom: tileLayer.maxZoom,
          tileDimension: tileLayer.tileSize,
          tms: tileLayer.tms,
          subdomains: tileLayer.subdomains,
          additionalOptions: tileLayer.additionalOptions,
          userAgentPackageName: tileLayer.userAgentPackageName,
          reset: tileResetController.stream,
        ),
        LocationMarkerWidget(),
        WalkPathPolyline(faint: widget.faintWalkPath),
        AttributionWidget(imagery),
        ...widget.layers,
        if (widget.drawPinMarker &&
            _center != null &&
            (!ref.watch(trackingProvider) || trackLocation == null))
          MarkerLayer(markers: [PinMarker(_center!)]),
        if (widget.drawStandardButtons)
          // Settings button
          OverlayButtonWidget(
            alignment: leftHand ? Alignment.topRight : Alignment.topLeft,
            padding: EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 10.0,
            ),
            icon: Icons.menu,
            tooltip: loc.mapSettings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        MapButtonColumn(
          alignment: leftHand ? Alignment.topLeft : Alignment.topRight,
          buttons: [
            ...widget.buttons,
            if (widget.drawStandardButtons)
              // Tracking button
              MapButton(
                enabled: !ref.watch(trackingProvider) && trackLocation != null,
                icon: Icons.my_location,
                tooltip: loc.mapLocate,
                onPressed: () {
                  ref
                      .read(geolocationProvider.notifier)
                      .enableTracking(context);
                },
                onLongPressed: () {
                  if (ref.read(rotationProvider) != 0.0) {
                    ref.read(rotationProvider.notifier).state = 0.0;
                    _controller.rotate(0.0);
                  } else {
                    ref
                        .read(geolocationProvider.notifier)
                        .enableTracking(context);
                  }
                },
              ),
          ],
          safeRight: true,
        ),
        if (widget.drawZoomButtons)
          ZoomButtonsWidget(
            alignment: leftHand ? Alignment.bottomLeft : Alignment.bottomRight,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: widget.hasFloatingButton ? 100.0 : 20.0),
          ),
      ],
    );
  }
}
