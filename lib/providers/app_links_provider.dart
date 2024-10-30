import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

final appLinksProvider = Provider((ref) => AppLinks());

final uriLinkStreamProvider = StreamProvider<Uri?>((ref) async* {
  final appLinks = ref.watch(appLinksProvider);
  await for (final uri in appLinks.uriLinkStream) {
    if (uri.scheme == 'geo' && uri.path.isNotEmpty) {
      _handleGeoIntent(uri, ref);
    }

    yield uri;
  }
});

void _handleGeoIntent(Uri uri, StreamProviderRef<Uri?> ref) {
  final location = _parseLatLngFromGeoUri(uri);
  if (location != null) {
    ref.read(geolocationProvider.notifier).disableTracking();
    ref.read(effectiveLocationProvider.notifier).set(location);
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
    Logger('AppLinks').warning('Failed to parse coordinates');
  }
  return null;
}
