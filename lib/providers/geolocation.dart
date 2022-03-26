import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final geolocationProvider =
    StateNotifierProvider<GeolocationController, LatLng?>(
        (ref) => GeolocationController(ref));
final trackingProvider = StateProvider<bool>((ref) => false);

class GeolocationController extends StateNotifier<LatLng?> {
  StreamSubscription<Position>? locSub;
  late final StreamSubscription<ServiceStatus> statSub;
  final Ref _ref;

  GeolocationController(this._ref) : super(null) {
    statSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        enableTracking();
      } else {
        disableTracking();
      }
    });
    // initGeolocator();
  }

  initGeolocator() async {
    await locSub?.cancel();
    locSub = null;

    if (!await Geolocator.isLocationServiceEnabled()) {
      disableTracking();
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        print('Geolocation denied');
        disableTracking();
        return;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      print('Geolocation denied forever');
      disableTracking();
      return;
    }

    final pos = await Geolocator.getLastKnownPosition();
    if (pos != null) state = _fromPosition(pos);

    locSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    ).listen(
      onLocationEvent,
      onError: onLocationError,
    );
  }

  disableTracking() {
    _ref.read(trackingProvider.state).state = false;
  }

  enableTracking([BuildContext? context]) async {
    final bool tracking = _ref.read(trackingProvider);
    if (tracking) return;

    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      if (context != null) {
        final loc = null; // TODO AppLocalizations.of(context);
        await showOkAlertDialog(
          title: loc?.enableGPS ?? 'Enable GPS',
          message: loc?.enableGPSMessage ?? 'Please enable location services.',
          context: context,
        );
        await Geolocator.openLocationSettings();
      } else return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        final loc = null; // TODO AppLocalizations.of(context);
        await showOkAlertDialog(
          title: loc?.enableLocation ?? 'Enable Location',
          message: loc?.enableLocationMessage ??
              'Please allow location access for the app.',
          context: context,
        );
        await Geolocator.openAppSettings();
      } else return;
    }

    // Check for active GPS tracking
    if (locSub == null) {
      await initGeolocator();
    }

    if (locSub != null) {
      _ref.read(trackingProvider.state).state = true;
    }
  }

  static LatLng _fromPosition(Position pos) =>
      LatLng(pos.latitude, pos.longitude);

  void onLocationEvent(Position pos) {
    state = _fromPosition(pos);
  }

  onLocationError(event) {
    print('Location error! $event');
    disableTracking();
    state = null;
    locSub?.cancel();
    locSub = null;
  }

  @override
  void dispose() {
    locSub?.cancel();
    statSub.cancel();
    super.dispose();
  }
}
