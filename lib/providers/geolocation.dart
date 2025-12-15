import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:logging/logging.dart';

final geolocationProvider =
    NotifierProvider<GeolocationController, LatLng?>(GeolocationController.new);

final forceLocationProvider = NotifierProvider<ForceLocationController, bool>(
    ForceLocationController.new);

final trackingProvider =
    NotifierProvider<TrackingNotifier, bool>(TrackingNotifier.new);

class TrackingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }
}

class GeolocationController extends Notifier<LatLng?> {
  static final _distance = DistanceEquirectangular();
  static final _logger = Logger('GeoLocationController');

  StreamSubscription<Position>? _locSub;
  late final StreamSubscription<ServiceStatus> _statSub;
  late DateTime _stateTime;

  @override
  LatLng? build() {
    _stateTime = DateTime.now().subtract(Duration(hours: 1));
    _statSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        enableTracking();
      } else {
        disableTracking();
        state = null;
      }
    });

    ref.onDispose(() => _locSub?.cancel());
    ref.onDispose(_statSub.cancel);

    return null;
  }

  LocationSettings _makeLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        intervalDuration: Duration(seconds: 1),
        forceLocationManager: ref.read(forceLocationProvider),
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

  Future<void> _subscribeToPositions() async {
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
        forceAndroidLocationManager: ref.read(forceLocationProvider));
    if (pos != null) _updateLocation(_fromPosition(pos));

    _locSub = Geolocator.getPositionStream(
      locationSettings: _makeLocationSettings(),
    ).listen(
      onLocationEvent,
      onError: onLocationError,
    );
    _logger.fine('Subscribed to position stream');
  }

  Future<void> reloadTracking() async {
    if (ref.read(trackingProvider)) {
      if (await Geolocator.isLocationServiceEnabled()) {
        disableTracking();
        await enableTracking();
      }
    }
  }

  void disableTracking() {
    ref.read(trackingProvider.notifier).disable();
  }

  Future<void> enableTracking([BuildContext? context]) async {
    final bool tracking = ref.read(trackingProvider);
    if (tracking) return;

    // If tracking is denied forever, do nothing.
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return;

    // Request for location service if needed.
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      if (context != null && context.mounted) {
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
      ref.read(trackingProvider.notifier).enable();
    }
  }

  static LatLng _fromPosition(Position pos) =>
      LatLng(pos.latitude, pos.longitude);

  void onLocationEvent(Position pos) {
    _updateLocation(_fromPosition(pos));
  }

  void _updateLocation(LatLng newLocation) {
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

  void onLocationError(Object event) {
    _logger.warning('Location error! $event');
    disableTracking();
    state = null;
    _locSub?.cancel();
    _locSub = null;
  }
}

class ForceLocationController extends Notifier<bool> {
  static const _kForceLocationKey = 'force_location_android';

  @override
  bool build() {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    return prefs.getBool(_kForceLocationKey) ?? false;
  }

  Future<void> set(bool force) async {
    if (state == force) return;
    state = force;
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    await prefs.setBool(_kForceLocationKey, state);

    // Restart tracking if possible
    await ref.read(geolocationProvider.notifier).reloadTracking();
  }
}
