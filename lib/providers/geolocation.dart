// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final geolocationProvider =
    StateNotifierProvider<GeolocationController, LatLng?>(
        (ref) => GeolocationController(ref));
final forceLocationProvider =
    StateNotifierProvider<ForceLocationController, bool>(
        (ref) => ForceLocationController(ref));
final trackingProvider = StateProvider<bool>((ref) => false);

class GeolocationController extends StateNotifier<LatLng?> {
  static final _distance = DistanceEquirectangular();
  static final _logger = Logger('GeoLocationController');

  StreamSubscription<Position>? _locSub;
  late final StreamSubscription<ServiceStatus> _statSub;
  final Ref _ref;
  late DateTime _stateTime;

  GeolocationController(this._ref) : super(null) {
    _stateTime = DateTime.now().subtract(Duration(hours: 1));
    _statSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        enableTracking();
      } else {
        disableTracking();
        state = null;
      }
    });
  }

  LocationSettings _makeLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        intervalDuration: Duration(seconds: 1),
        forceLocationManager: _ref.read(forceLocationProvider),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.best,
      );
    }
  }

  _subscribeToPositions() async {
    await _locSub?.cancel();
    _locSub = null;

    if (!await Geolocator.isLocationServiceEnabled()) {
      disableTracking();
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      try {
        perm = await Geolocator.requestPermission();
      } on Exception catch (e) {
        _logger.warning('Permission request failed', e);
        return;
      }
      if (perm == LocationPermission.denied) {
        _logger.info('Geolocation denied');
        disableTracking();
        return;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      _logger.info('Geolocation denied forever');
      disableTracking();
      return;
    }

    final pos = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: _ref.read(forceLocationProvider));
    if (pos != null) _updateLocation(_fromPosition(pos));

    _locSub = Geolocator.getPositionStream(
      locationSettings: _makeLocationSettings(),
    ).listen(
      onLocationEvent,
      onError: onLocationError,
    );
    _logger.info('Subscribed to position stream');
  }

  reloadTracking() async {
    if (_ref.read(trackingProvider)) {
      if (await Geolocator.isLocationServiceEnabled()) {
        disableTracking();
        await enableTracking();
      }
    }
  }

  disableTracking() {
    _ref.read(trackingProvider.notifier).state = false;
  }

  enableTracking([BuildContext? context]) async {
    final bool tracking = _ref.read(trackingProvider);
    if (tracking) return;

    // If tracking is denied forever, do nothing.
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return;

    // Wait until we get forceLocation value.
    if (!_ref.read(forceLocationProvider.notifier).loaded) {
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 50))
          .then((_) => !_ref.read(forceLocationProvider.notifier).loaded));
    }

    // Request for location service if needed.
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

    // Check for active GPS tracking
    if (_locSub == null) {
      await _subscribeToPositions();
    }

    if (_locSub != null) {
      _ref.read(trackingProvider.notifier).state = true;
    }
  }

  static LatLng _fromPosition(Position pos) =>
      LatLng(pos.latitude, pos.longitude);

  void onLocationEvent(Position pos) {
    _updateLocation(_fromPosition(pos));
  }

  _updateLocation(LatLng newLocation) {
    if (!kSlowDownGPS) {
      state = newLocation;
      return;
    }

    // Update state location only if it's far, time passed, or it is null.
    const kLocationThreshold = 5; // meters
    const kLocationInterval = Duration(seconds: 10);
    final oldState = state;

    if (oldState == null ||
        DateTime.now().difference(_stateTime) >= kLocationInterval ||
        _distance(oldState, newLocation) > kLocationThreshold) {
      state = newLocation;
      _stateTime = DateTime.now();
    }
  }

  onLocationError(event) {
    _logger.warning('Location error! $event');
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
