import 'package:every_door/models/osm_element.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/screens/settings/install_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

final geoIntentProvider = Provider((ref) => GeoIntentController(ref));

class GeoIntentController {
  static final _logger = Logger('GeoIntentController');
  final Ref _ref;
  final navigatorKey = GlobalKey<NavigatorState>();

  GeoIntentController(this._ref) {
    initStreamListener();
  }

  initStreamListener() {
    AppLinks().uriLinkStream.listen((uri) {
      _handleGeoIntent(uri);
    });
  }

  checkLatestIntent() async {
    final latest = await AppLinks().getLatestLink();
    if (latest != null) _handleGeoIntent(latest);
  }

  _handleGeoIntent(Uri uri) {
    if (uri.scheme == 'geo' && uri.path.isNotEmpty) {
      _logger.info('Got geo uri $uri');
      final location = _parseLatLngFromGeoUri(uri.path);
      _navigateToLocation(location);
    } else if (uri.scheme == 'everydoor' && uri.path.startsWith('/nav')) {
      _logger.info('Got nav uri $uri');
      _handleNavLink(uri.path);
    } else if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host == 'plugins.every-door.app') {
      _logger.info('Got plugins.every-door.app deep link: ${uri.path}');
      if (uri.path.startsWith('/i/')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => InstallPluginPage(uri),
            fullscreenDialog: true,
          ),
        );
      } else if (uri.path.startsWith('/nav/')) {
        _handleNavLink(uri.path);
      }
    }
  }

  LatLng? _parseLatLngFromGeoUri(String path) {
    try {
      final coords = path.split(',');
      if (coords.length == 2) {
        final lat = double.parse(coords[0]);
        final lng = double.parse(coords[1]);
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
        return LatLng(lat, lng);
      }
    } catch (e) {
      _logger.warning('Failed to parse coordinates: $e');
    }
    return null;
  }

  void _navigateToLocation(LatLng? location) {
    if (location != null) {
      _ref.read(geolocationProvider.notifier).disableTracking();
      _ref.read(effectiveLocationProvider.notifier).set(location);
    }
  }

  _handleNavLink(String path) {
    final reLatLng = RegExp(r'/nav/(-?[0-9.]+,-?[0-9.]+)');
    final m1 = reLatLng.matchAsPrefix(path);
    if (m1 != null) {
      final location = _parseLatLngFromGeoUri(m1[1]!);
      _navigateToLocation(location);
    } else {
      final reOsm = RegExp(r'/nav/(n[a-z]*|w[a-z]*|r[a-z]*)/([0-9]+)',
          caseSensitive: false);
      final m2 = reOsm.matchAsPrefix(path);
      if (m2 != null) {
        const kOsmTypes = {
          'n': OsmElementType.node,
          'w': OsmElementType.way,
          'r': OsmElementType.relation,
        };
        final osmType = kOsmTypes[m2[1]![0]]!;
        final osmId = int.parse(m2[2]!);
        _openObjectEditor(OsmId(osmType, osmId));
      }
    }
  }

  Future<void> _openObjectEditor(OsmId id) async {
    // Download the object to determine its location.
    final downloaded = await _ref.read(osmDataProvider).getElement(id);
    if (downloaded != null) {
      _navigateToLocation(downloaded.location);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: downloaded),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    final el = await _ref.read(osmApiProvider).singleElement(id);
    if (el == null || el.geometry == null) return;
    // Navigate to the area.
    _navigateToLocation(el.geometry!.center);
    // Download objects in the area.
    // TODO
    // Open the object editor.
    // TODO
    // (maybe make it a separate page because of the wait, and also because we need BuildContext)
  }
}
