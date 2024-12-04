import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

final geoIntentProvider = Provider((ref) => GeoIntentController(ref));

class GeoIntentController {
  static final _logger = Logger('GeoIntentController');
  final Ref _ref;

  GeoIntentController(this._ref) {
    initStreamListener();
  }

  initStreamListener() async {
    await for (final uri in AppLinks().uriLinkStream) {
      _handleGeoIntent(uri);
    }
  }

  checkLatestIntent() async {
    final latest = await AppLinks().getLatestLink();
    if (latest != null) _handleGeoIntent(latest);
  }

  _handleGeoIntent(Uri uri) {
    if (uri.scheme == 'geo' && uri.path.isNotEmpty) {
      _logger.info('Got geo uri $uri');
      final location = _parseLatLngFromGeoUri(uri);
      if (location != null) {
        _ref.read(geolocationProvider.notifier).disableTracking();
        _ref.read(effectiveLocationProvider.notifier).set(location);
      }
    }
  }

  LatLng? _parseLatLngFromGeoUri(Uri uri) {
    try {
      final coords = uri.path.split(',');
      if (coords.length == 2) {
        final lat = double.parse(coords[0]);
        final lng = double.parse(coords[1]);
        return LatLng(lat, lng);
      }
    } catch (e) {
      _logger.warning('Failed to parse coordinates: $e');
    }
    return null;
  }
}