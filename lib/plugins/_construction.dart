// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:convert' show json, utf8;
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/geometry/circle_bounds.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:every_door/plugins/ext_overlay.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/screens/modes/definitions/classic.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:every_door/models/amenity.dart';
import 'package:fast_geohash/fast_geohash_str.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class PluginUnderConstruction extends EveryDoorPlugin {
  static const kEnabled = false;

  static Map<String, dynamic> getMetadata() => {
        'id': 'pluginUnderConstruction',
        'name': 'Plugin Under Construction',
      };

  @override
  Future<void> install(EveryDoorApp app) async {
    app.addOverlay(ExtOverlay(
        id: 'geohashes',
        build: (context, data) {
          if (data == null || data is! List) return Container();
          app.logger.info('Polygons: $data');
          return PolygonLayer(polygons: [
            for (final p in data.cast<LatLngBounds>())
              Polygon(
                points: [p.southEast, p.northEast, p.northWest, p.southWest],
                color: Colors.yellow.withValues(alpha: 0.2),
                borderColor: Colors.yellow.shade700,
                borderStrokeWidth: 2.0,
              ),
          ]);
        },
        update: (bounds) async {
          final hashes = geohash.forBounds(
              bounds.south, bounds.west, bounds.north, bounds.east, 7);
          final polygons = <LatLngBounds>[];
          for (final hash in hashes) {
            final ll = geohash.decode(hash);
            final latErr = 180.0 / math.pow(2, hash.length * 2.5 + 0.5);
            final lonErr = 180.0 / math.pow(2, hash.length * 2.5 + 0.5);
            polygons.add(LatLngBounds(LatLng(ll.lat - latErr, ll.lon - lonErr),
                LatLng(ll.lat + latErr, ll.lon + lonErr)));
          }
          return polygons;
        }));
  }
}

class PanoramaxPhoto {
  final String id;
  final String? thumbnailUrl;
  final String? imageUrl;
  final bool ready;
  final LatLng location;

  PanoramaxPhoto(
      {required this.id,
      this.thumbnailUrl,
      this.imageUrl,
      required this.location,
      required this.ready});

  factory PanoramaxPhoto.fromJson(Map data) {
    final props = data['properties'] as Map;
    final thumbnail = props['geovisio:thumbnail'];
    final image = props['geovisio:image'];
    final coords = data['geometry']['coordinates'] as List;
    return PanoramaxPhoto(
      id: data['id'],
      ready: props['geovisio:status'] == 'ready',
      thumbnailUrl: thumbnail is String ? thumbnail : null,
      imageUrl: image is String ? image : null,
      location: LatLng(coords[1], coords[0]),
    );
  }
}

class PanoramaxToken extends AuthToken {
  final String jwt;
  final String id;

  const PanoramaxToken(this.id, this.jwt);

  factory PanoramaxToken.fromJson(Map<String, dynamic> data) =>
      PanoramaxToken(data['id'], data['jwt_token']);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'jwt_token': jwt};
}

class PanoramaxAuth extends AuthProvider {
  @override
  String get endpoint => 'panoramax.openstreetmap.fr';

  @override
  String? get title => 'Panoramax';

  @override
  MultiIcon? get icon => MultiIcon(
      imageUrl: 'https://docs.panoramax.fr/images/panoramax_favicon.svg');

  @override
  Future<UserDetails> loadUserDetails(AuthToken token) async {
    final response = await http.get(Uri.https(endpoint, '/api/users/me'),
        headers: getHeaders(token));
    if (response.statusCode != 200) {
      throw AuthException("Failed to get user data");
    }
    final data = json.decode(response.body);
    return UserDetails(displayName: data['name']);
  }

  @override
  Future<void> logout(AuthToken token) async {
    await http.get(Uri.https(endpoint, '/api/auth/logout'),
        headers: getHeaders(token));
    await super.logout(token);
  }

  @override
  Future<bool> testHeaders(Map<String, String>? headers, String? apiKey) async {
    final response =
        await http.get(Uri.https(endpoint, '/api/users/me'), headers: headers);
    return response.statusCode == 200;
  }

  @override
  Future<AuthToken?> login(BuildContext context) async {
    final tokenRequest =
        await http.post(Uri.https(endpoint, '/api/auth/tokens/generate'));
    if (tokenRequest.statusCode != 200) {
      throw AuthException('Failed to generate a blank token.');
    }
    final token = PanoramaxToken.fromJson(json.decode(tokenRequest.body));

    final claimUrl = Uri.https(endpoint, 'api/auth/tokens/${token.id}/claim');
    if (!context.mounted) return null;
    await showOkAlertDialog(
        context: context,
        message:
            'You will be shown the Panoramax website. Please login through to the confirmation message, and then close it and return to the app.');
    await launchUrl(claimUrl, mode: LaunchMode.inAppBrowserView);
    if (context.mounted) {
      await showOkAlertDialog(
          context: context, message: 'Please tap "OK" when done.');
    }
    return token;
  }

  @override
  AuthToken tokenFromJson(Map<String, dynamic> data) =>
      PanoramaxToken.fromJson(data);

  @override
  Map<String, String> getHeaders(AuthToken token) => {
        'Authorization': 'Bearer ${(token as PanoramaxToken).jwt}',
      };
}

class TestMode extends ClassicModeDefinition {
  TestMode(EveryDoorApp app) : super.fromPlugin(app);

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) =>
      MultiIcon(fontIcon: Icons.ac_unit);

  @override
  String get name => 'test';

  @override
  bool isOurKind(OsmChange element) => true;
}
