// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/auth/oauth2.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' show XmlDocument, XmlFindExtension;

const kOsmEndpoint = 'api.openstreetmap.org';
const kOsmAuth2Endpoint = 'www.openstreetmap.org';
// const kOsmEndpoint = 'master.apis.dev.openstreetmap.org';
// const kOsmAuth2Endpoint = 'master.apis.dev.openstreetmap.org';

class OsmUserDetails extends UserDetails {
  final int id;
  final DateTime created;
  final String? avatar;
  final int changesets;
  final int unreadMessages;

  OsmUserDetails({
    required this.id,
    required super.displayName,
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

class OsmAuthProvider extends OAuth2AuthProvider {
  @override
  final String endpoint;

  @override
  String? get title => 'OpenStreetMap';

  @override
  MultiIcon? get icon => MultiIcon(
      imageUrl:
          'https://www.openstreetmap.org/assets/osm_logo-4b074077c29e100f40ee64f5177886e36b570d4cc3ab10c7b263003d09642e3f.svg');

  OsmAuthProvider({
    required super.clientId,
    required super.clientSecret,
    required this.endpoint,
    String? authEndpoint,
  }) : super(
          authorizeUrl: 'https://${authEndpoint ?? endpoint}/oauth2/authorize',
          tokenUrl: 'https://${authEndpoint ?? endpoint}/oauth2/token',
          scopes: ['read_prefs', 'write_api', 'write_notes'],
        );

  @override
  Future<bool> testHeaders(Map<String, String>? headers, String? apiKey) async {
    final response = await http
        .get(Uri.https(endpoint, '/api/0.6/user/details'), headers: headers);
    if (response.statusCode != 200) return false;
    if (response.body.contains('<html')) return false;
    return true;
  }

  @override
  Future<OsmUserDetails> loadUserDetails(AuthToken token) async {
    final response = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/user/details'),
        headers: getHeaders(token));
    if (response.statusCode != 200) {
      throw AuthException('Wrong oauth access token');
    }
    if (response.body.contains('<html')) {
      final clean = response.body.replaceAll(RegExp(r'<[^>]+>'), '');
      throw AuthException('User details call returned HTML: $clean');
    }
    try {
      return OsmUserDetails.fromXML(response.body);
    } on FormatException {
      final clean = response.body.replaceAll(RegExp(r'<[^>]+>'), '');
      throw AuthException('Wrong data: $clean');
    }
  }
}
