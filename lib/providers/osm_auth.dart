import 'dart:io' show Platform;
import 'dart:convert' show base64, utf8;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/osm_oauth2_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authProvider = StateNotifierProvider<OsmAuthController, String?>(
    (_) => OsmAuthController());

class OsmUserDetails {
  final int id;
  final String displayName;
  final DateTime created;
  final String? avatar;
  final int changesets;
  final int unreadMessages;

  OsmUserDetails({
    required this.id,
    required this.displayName,
    required this.created,
    this.avatar,
    this.changesets = 0,
    this.unreadMessages = 0,
  });

  factory OsmUserDetails.fromXML(String xml) {
    final document = XmlDocument.parse(xml);
    final userNode = document.findAllElements('user').single;
    final img = userNode.findElements('img');
    final changesets = userNode.findElements('changesets');
    final messages = userNode.findElements('messages');
    return OsmUserDetails(
      id: int.parse(userNode.getAttribute('id')!),
      displayName: userNode.getAttribute('display_name')!,
      created: DateTime.parse(userNode.getAttribute('account_created')!),
      avatar: img.isEmpty ? null : img.single.getAttribute('href'),
      changesets: changesets.isEmpty
          ? 0
          : int.parse(changesets.single.getAttribute('count') ?? '0'),
      unreadMessages: messages.isEmpty
          ? 0
          : int.parse(messages.single
                  .findElements('received')
                  .single
                  .getAttribute('unread') ??
              '0'),
    );
  }
}

class OsmAuthException implements Exception {
  final String message;

  OsmAuthException(this.message);

  @override
  String toString() => 'OsmAuthException($message)';
}

class OsmAuthController extends StateNotifier<String?> {
  static const kLoginKey = 'osmLogin';
  static const kPasswordKey = 'osmPassword';
  static final _logger = Logger('OsmAuthController');

  final OpenStreetMapOAuthHelper _helper = OpenStreetMapOAuthHelper();
  bool isOAuth = false;
  bool? _supportsOAuth;

  bool get authorized => state != null;

  OsmAuthController() : super(null) {
    loadData();
  }

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? login = prefs.getString(kLoginKey);

    String? pwd;
    if (login != null) {
      final secure = FlutterSecureStorage();
      pwd = await secure.read(key: kPasswordKey);
    }

    if (pwd != null) {
      isOAuth = false;
    } else {
      isOAuth = await supportsOAuthLogin();
      if (!isOAuth) login = null;
    }

    state = login;
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    if (isOAuth) {
      await _helper.deleteToken();
    } else {
      await FlutterSecureStorage().delete(key: kPasswordKey);
    }
    await prefs.remove(kLoginKey);
    state = null;
  }

  Future<bool> supportsOAuthLogin() async {
    if (_supportsOAuth != null) return _supportsOAuth!;
    bool result = false;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      final sdk = info.version.sdkInt;
      result = sdk >= 18;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final match = RegExp(r'^(\d+)').matchAsPrefix(info.systemVersion ?? '');
      if (match != null) {
        result = int.parse(match.group(1)!) >= 11;
      }
    }
    _supportsOAuth = result;
    return result;
  }

  storeLoginPassword(String login, String password) async {
    final headers = _getBasicAuthHeaders(login, password);
    final response = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/user/details'),
        headers: headers);
    if (response.statusCode != 200) {
      throw OsmAuthException('Wrong login or password');
    }

    if (isOAuth) {
      await _helper.deleteToken();
      isOAuth = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLoginKey, login);
    final secure = FlutterSecureStorage();
    await secure.write(key: kPasswordKey, value: password);
    state = login;
  }

  loginWithOAuth(BuildContext context) async {
    final token = await _helper.getToken();
    if (token != null) {
      isOAuth = true;
      final authStr = await _helper.getAuthorizationValue(token);
      if (authStr == null)
        throw OsmAuthException('Failed to build auth string');
      final headers = {'Authorization': authStr};
      final details = await loadUserDetails(headers);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kLoginKey, details.displayName);
      state = details.displayName;
    }
  }

  Map<String, String> _getBasicAuthHeaders(String login, String password) {
    final authStr = base64.encode(utf8.encode('$login:$password'));
    return {'Authorization': 'Basic $authStr'};
  }

  Future<bool> _testAuthHeaders(Map<String, String> headers) async {
    final response = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/user/details'),
        headers: headers);
    if (response.statusCode != 200) return false;
    if (response.body.contains('<html')) return false;
    return true;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    if (isOAuth) {
      final authStr = await _helper.getAuthorizationValue();
      if (authStr == null) {
        state = null;
        throw OsmAuthException('User is not logged in.');
      }
      final headers = {'Authorization': authStr};
      if (!await _testAuthHeaders(headers)) {
        state = null;
        throw OsmAuthException(
            'Could not use the saved OAuth token, please re-login.');
      }
      return headers;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final login = prefs.getString(kLoginKey);
      final secure = FlutterSecureStorage();
      final password = await secure.read(key: kPasswordKey);
      if (login == null || password == null)
        throw StateError('No login and password found.');
      return _getBasicAuthHeaders(login, password);
    }
  }

  Future<OsmUserDetails> loadUserDetails([Map<String, String>? headers]) async {
    final response = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/user/details'),
        headers: headers ?? await getAuthHeaders());
    if (response.statusCode != 200) {
      throw OsmAuthException('Wrong oauth access token');
    }
    if (response.body.contains('<html')) {
      final clean = response.body.replaceAll(RegExp(r'<[^>]+>'), '');
      throw OsmAuthException('User details call returned HTML: $clean');
    }
    try {
      return OsmUserDetails.fromXML(response.body);
    } on FormatException {
      final clean = response.body.replaceAll(RegExp(r'<[^>]+>'), '');
      throw OsmAuthException('Wrong data: $clean');
    }
  }
}
