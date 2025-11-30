import 'dart:convert' show json, utf8;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/geometry/circle_bounds.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:every_door/plugins/ext_overlay.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class PluginUnderConstruction extends EveryDoorPlugin {
  static const kEnabled = false;
  static const kEndpoint = 'panoramax.openstreetmap.fr';
  bool apiFound = false;

  static Map<String, dynamic> getMetadata() => {
        'id': 'pluginUnderConstruction',
        'name': 'Plugin Under Construction',
      };

  @override
  Future<void> install(EveryDoorApp app) async {
    app.logger.info("Installing plugin!");
    final apiResponse =
        await http.get(Uri.https(kEndpoint, '/api/configuration'));
    if (apiResponse.statusCode == 200) {
      final response = json.decode(utf8.decode(apiResponse.bodyBytes));
      app.logger.info('API response ok, name: ${response["name"]["label"]}');
      apiFound = true;
    }

    app.addAuthProvider('panoramax', PanoramaxAuth());

    app.events.onDownload((location) async {
      // TODO: download and put into the database.
      final bounds = boundsFromRadius(location, 1000);
    });

    app.events.onModeCreated((mode) async {
      app.logger.info("Mode created: ${mode.name}");

      if (mode.name == 'micro') {
        mode.addMapButton(MapButton(
          icon: MultiIcon(emoji: 'P'),
          onPressed: (context) {
            app.providers.location = LatLng(59.409680, 24.631112);
          },
        ));
      }
    });

    if (apiFound) {
      app.addOverlay(ExtOverlay(
        id: 'panoramax',
        build: (context, data) {
          final photos = data as List<PanoramaxPhoto>?;
          if (photos == null) return Container();
          return MarkerLayer(
            markers: [
              for (final photo in photos)
                Marker(
                  point: photo.location,
                  rotate: true,
                  child: GestureDetector(
                    child: Container(
                      color: Colors.yellow.withValues(alpha: 0.1),
                      child: Text('📷', style: TextStyle(fontSize: 30.0)),
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final url = photo
                          .thumbnailUrl; // photo.imageUrl ?? photo.thumbnailUrl;
                      app.logger
                          .info('tapped on a photo ${photo.id} with url $url');
                      if (url == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Photo ${photo.id} has no image url'),
                        ));
                      } else {
                        await showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(child: Image.network(url)),
                        );
                      }
                    },
                  ),
                  height: 30,
                  width: 30,
                )
            ],
          );
        },
        update: (bounds) async {
          return await queryPhotos(app.logger, bounds);
        },
      ));
    }
  }

  Future<List<PanoramaxPhoto>> queryPhotos(
      Logger log, LatLngBounds bounds) async {
    final response = await http.get(Uri.https(kEndpoint, '/api/search', {
      'bbox': [bounds.west, bounds.south, bounds.east, bounds.north].join(','),
      'limit': '40',
    }));
    if (response.statusCode != 200) {
      log.warning('Got response ${response.statusCode} ${response.body}');
      return [];
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (data is! Map || !data.containsKey('features')) return [];
    final result = <PanoramaxPhoto>[];
    for (final feature in data['features'] as List) {
      if (feature is Map) {
        try {
          result.add(PanoramaxPhoto.fromJson(feature));
        } on Exception {
          log.warning('Failed to decode json: $feature');
        }
      }
    }
    log.info('Downloaded ${result.length} photos');
    return result;
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
