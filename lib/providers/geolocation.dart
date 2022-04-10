import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/helpers/equirectangular.dart';
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
  StreamSubscription<Position>? _locSub;
  late final StreamSubscription<ServiceStatus> _statSub;
  final Ref _ref;
  LatLng? location;
  late DateTime _stateTime;

  GeolocationController(this._ref) : super(null) {
    _stateTime = DateTime.now();
    _statSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        enableTracking();
      } else {
        disableTracking();
      }
    });
    // initGeolocator();
  }

  initGeolocator() async {
    await _locSub?.cancel();
    _locSub = null;

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
    if (pos != null) _updateLocation(_fromPosition(pos));

    _locSub = Geolocator.getPositionStream(
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
        final loc = AppLocalizations.of(context);
        await showOkAlertDialog(
          title: loc?.enableGPS ?? 'Enable GPS',
          message: loc?.enableGPSMessage ?? 'Please enable location services.',
          context: context,
        );
        await Geolocator.openLocationSettings();
      } else
        return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        final loc = AppLocalizations.of(context);
        await showOkAlertDialog(
          title: loc?.enableLocation ?? 'Enable Location',
          message: loc?.enableLocationMessage ??
              'Please allow location access for the app.',
          context: context,
        );
        await Geolocator.openAppSettings();
      } else
        return;
    }

    // Check for active GPS tracking
    if (_locSub == null) {
      await initGeolocator();
    }

    if (_locSub != null) {
      _ref.read(trackingProvider.state).state = true;
    }
  }

  static LatLng _fromPosition(Position pos) =>
      LatLng(pos.latitude, pos.longitude);

  void onLocationEvent(Position pos) {
    _updateLocation(_fromPosition(pos));
  }

  _updateLocation(LatLng newLocation) {
    location = newLocation;

    // Update state location only if it's far, time passed, or it is null.
    const kLocationThreshold = 10; // meters
    const kLocationInterval = Duration(seconds: 10);
    final distance = DistanceEquirectangular();
    final oldState = state;

    if (oldState == null ||
        DateTime.now().difference(_stateTime) >= kLocationInterval ||
        distance(oldState, newLocation) > kLocationThreshold) {
      state = location;
      _stateTime = DateTime.now();
    }
  }

  onLocationError(event) {
    print('Location error! $event');
    disableTracking();
    state = null;
    _locSub?.cancel();
    _locSub = null;
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _statSub.cancel();
    super.dispose();
  }
}