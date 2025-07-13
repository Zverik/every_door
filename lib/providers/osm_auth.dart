import 'package:every_door/constants.dart';
import 'package:every_door/helpers/osm_oauth2_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

final authProvider = StateNotifierProvider<OsmAuthController, OsmUserDetails?>(
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

class OsmAuthController extends StateNotifier<OsmUserDetails?> {
  static final _logger = Logger('OsmAuthController'); // ignore: unused_field

  final OpenStreetMapOAuthHelper _helper = OpenStreetMapOAuthHelper();

  bool get authorized => state != null;

  OsmAuthController() : super(null) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      state = await loadUserDetails();
    } on OsmAuthException {
      state = null;
    }
  }

  Future<void> logout() async {
    await _helper.deleteToken();
    state = null;
  }

  Future<void> loginWithOAuth(BuildContext context) async {
    final token = await _helper.getToken();
    if (token != null) {
      final authStr = await _helper.getAuthorizationValue(token);
      if (authStr == null)
        throw OsmAuthException('Failed to build auth string');
      final headers = {'Authorization': authStr};
      final details = await loadUserDetails(headers);
      state = details;
    }
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
