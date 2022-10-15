import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:location/location.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final geolocationProvider =
    StateNotifierProvider<GeolocationController, LatLng?>(
        (ref) => GeolocationController(ref));
final forceLocationProvider =
    StateNotifierProvider<ForceLocationController, bool>(
        (ref) => ForceLocationController(ref));
final trackingProvider = StateProvider<bool>((ref) => false);
final rotationProvider = StateProvider<double>((ref) => 0.0);

class GeolocationController extends StateNotifier<LatLng?> {
  static final _distance = DistanceEquirectangular();
  static final _logger = Logger('GeoLocationController');

  final Ref _ref;
  late DateTime _stateTime;
  StreamSubscription<LocationData>? _locSub;

  GeolocationController(this._ref) : super(null) {
    _stateTime = DateTime.now();
  }

  _subscribeToPositions() async {
    await _locSub?.cancel();
    _locSub = null;

    if (!await Location.instance.serviceEnabled()) {
      disableTracking();
      return;
    }

    PermissionStatus perm = await Location.instance.hasPermission();
    if (perm == PermissionStatus.denied) {
      try {
        perm = await Location.instance.requestPermission();
      } on Exception catch (e) {
        _logger.warning('Permission request failed', e);
        return;
      }
    }

    if (perm == PermissionStatus.denied ||
        perm == PermissionStatus.deniedForever) {
      _logger.info('Geolocation denied');
      disableTracking();
      return;
    }

    // final pos = _fromPosition(await Location.instance.getLocation());
    // if (pos != null) _updateLocation(pos);

    _locSub = Location.instance.onLocationChanged.listen(
      onLocationEvent,
      onError: onLocationError,
    );
    _logger.info('Subscribed to position stream');
  }

  reloadTracking() async {
    if (_ref.read(trackingProvider)) {
      if (await Location.instance.serviceEnabled()) {
        disableTracking();
        await enableTracking();
      }
    }
  }

  disableTracking() {
    _ref.read(trackingProvider.state).state = false;
  }

  enableTracking([BuildContext? context]) async {
    final bool tracking = _ref.read(trackingProvider);
    if (tracking) return;

    // Wait until we get forceLocation value.
    if (!_ref.read(forceLocationProvider.notifier).loaded) {
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 50))
          .then((_) => !_ref.read(forceLocationProvider.notifier).loaded));
    }

    final permission = await Location.instance.hasPermission();
    if (permission == PermissionStatus.deniedForever) {
      return;
    } else if (permission == PermissionStatus.denied) {
      await Location.instance.requestPermission();
    }

    final isLocationEnabled = await Location.instance.serviceEnabled();
    if (!isLocationEnabled) {
      await Location.instance.requestService();
    }

    // Check for active GPS tracking
    if (_locSub == null) {
      await _subscribeToPositions();
    }

    if (_locSub != null) {
      _ref.read(trackingProvider.state).state = true;
    }
  }

  void onLocationEvent(LocationData pos) {
    final loc = _fromPosition(pos);
    if (loc != null) _updateLocation(loc);
  }

  onLocationError(event) {
    _logger.warning('Location error! $event');
    disableTracking();
    state = null;
    _locSub?.cancel();
    _locSub = null;
  }

  static LatLng? _fromPosition(LocationData pos) =>
      pos.latitude == null || pos.longitude == null
          ? null
          : LatLng(pos.latitude!, pos.longitude!);

  _updateLocation(LatLng newLocation) {
    if (!kSlowDownGPS) {
      state = newLocation;
      return;
    }

    // Update state location only if it's far, time passed, or it is null.
    const kLocationThreshold = 10; // meters
    const kLocationInterval = Duration(seconds: 10);
    final oldState = state;

    if (oldState == null ||
        DateTime.now().difference(_stateTime) >= kLocationInterval ||
        _distance(oldState, newLocation) > kLocationThreshold) {
      state = newLocation;
      _stateTime = DateTime.now();
    }
  }
}

class ForceLocationController extends StateNotifier<bool> {
  static const _kForceLocationKey = 'force_location_android';
  final Ref _ref;
  bool loaded = false;

  ForceLocationController(this._ref) : super(false) {
    _read();
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kForceLocationKey) ?? false;
    loaded = true;
  }

  set(bool force) async {
    if (state == force) return;
    state = force;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kForceLocationKey, state);

    // Restart tracking if possible
    await _ref.read(geolocationProvider.notifier).reloadTracking();
  }
}
