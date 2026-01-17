// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:convert' show json;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/editor_fields.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/screens/modes/definitions/classic.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PluginUnderConstruction extends EveryDoorPlugin {
  static const kEnabled = false;

  static Map<String, dynamic> getMetadata() => {
        'id': 'pluginUnderConstruction',
        'name': 'Plugin Under Construction',
      };

  @override
  Future<void> install(EveryDoorApp app) async {
    app.events.onEditorFields((fields, amenity, preset, locale) async {
      if (fields.isEmpty) return fields;
      final wikiFields = EditorFields(fields: [
        WikidataField(key: 'wikidata'),
        TextPresetField(
            key: 'wikipedia',
            label: 'Wikipedia',
            placeholder: 'Wikipedia',
            showClearButton: true),
      ]);
      fields.insert(1, wikiFields);
      return fields;
    });
  }
}

class WikidataField extends PresetField {
  final Locale? locale;

  WikidataField({required super.key, this.locale}) : super(label: 'Wikidata');

  @override
  Widget buildWidget(OsmChange element) => WikidataPresetField(this, element);
}

class WikidataPresetField extends StatefulWidget {
  final WikidataField field;
  final OsmChange element;

  const WikidataPresetField(this.field, this.element);

  @override
  State<WikidataPresetField> createState() => _WikidataPresetFieldState();
}

class _WikidataPresetFieldState extends State<WikidataPresetField> {
  WikidataOption? current;
  Iterable<WikidataOption> _lastOptions = [];
  String? _searchingNow;
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  late final Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.field.locale ?? Locale('en', 'US');
    _controller =
        TextEditingController(text: widget.element[widget.field.key] ?? '');
    _focusNode = FocusNode();
    queryWikidata();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&formatversion=2&search=Mac+Modanero&type=item&language=en&uselang=en&limit=10&origin=*
  // https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&formatversion=2&search=modane&type=item&language=en&uselang=en&limit=10&origin=*
  // https://en.wikipedia.org/w/api.php?action=query&list=search&srlimit=10&srinfo=suggestion&format=json&origin=*&srsearch=Mac+Modanero
  // https://en.wikipedia.org/w/api.php?action=opensearch&namespace=0&suggest=&format=json&origin=*&search=mode

  /// Find the value that's in the tags.
  Future<void> queryWikidata() async {
    final id = widget.element[widget.field.key] ?? '';
    if (id.length < 2 || id[0] != 'Q') return;
    // TODO: locale
    final url = Uri.https('www.wikidata.org', '/w/api.php', {
      'action': 'wbgetentities',
      'format': 'json',
      'formatversion': '2',
      'props': 'labels|descriptions|sitelinks',
      'sitefilter': 'enwiki|ruwiki',
      'languages': 'en|ru',
      'languagefallback': '1',
      'origin': '*',
      'ids': id,
    });
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final info = (data as Map)['entities']?[id];
      if (info != null) {
        setState(() {
          current = WikidataOption.fromGetJson(info, _locale);
          _controller.text = current!.label;
        });
        return;
      }
    }

    setState(() {
      current = null;
    });
  }

  Future<Iterable<WikidataOption>> wikidataAutocomplete(String value) async {
    // TODO: locale
    final url = Uri.https('www.wikidata.org', '/w/api.php', {
      'action': 'wbsearchentities',
      'format': 'json',
      'formatversion': '2',
      'type': 'item',
      'language': 'en',
      'uselang': 'en',
      'limit': '10',
      'origin': '*',
      'search': value,
    });
    final response = await http.get(url);

    Iterable<WikidataOption> options;
    if (response.statusCode != 200) {
      options = Iterable.empty();
    } else {
      final data = json.decode(response.body);
      options =
          (data['search'] as List).map((e) => WikidataOption.fromSearchJson(e));
    }
    return options;
  }

  void findWikipediaLink() async {
    await queryWikidata();
    print('wikipedia for $current');
    if (current != null && !widget.field.key.contains(':')) {
      widget.element['wikipedia'] = current!.wikipedia;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<WikidataOption>(
          textEditingController: _controller,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            String value = textEditingValue.text;
            _searchingNow = value;
            if (value.isEmpty) value = widget.element.name ?? '';
            if (value.isEmpty) return _lastOptions;

            final options = await wikidataAutocomplete(value);
            if (_searchingNow != textEditingValue.text) {
              return _lastOptions;
            }

            _lastOptions = options;
            return options;
          },
          onSelected: (value) {
            setState(() {
              widget.element[widget.field.key] = value.q;
              findWikipediaLink();
            });
          },
          displayStringForOption: (option) => option.label,
        ),
        if (current != null)
          Text(
            current?.q ?? 'Q???',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}

class WikidataOption {
  final String q;
  final String label;
  final String? description;
  final String? wikipedia;

  WikidataOption(
      {required this.q, required this.label, this.description, this.wikipedia});

  factory WikidataOption.fromSearchJson(Map<String, dynamic> data) =>
      WikidataOption(
        q: data['id'],
        label: data['label'],
        description: data['description'],
      );

  factory WikidataOption.fromGetJson(Map<String, dynamic> data, Locale locale) {
    final id = data['id'];

    String label = id;
    final labels = data['labels'];
    if (labels is Map) {
      final section =
          labels[locale.languageCode] ?? labels['en'] ?? labels.values.firstOrNull;
      if (section is Map) {
        label = section['value'] ?? id;
      }
    }

    String? description;
    final descs = data['descriptions'];
    if (descs is Map) {
      final section =
          descs[locale.languageCode] ?? descs['en'] ?? descs.values.firstOrNull;
      if (section is Map) {
        description = section['value'];
      }
    }

    String? wiki;
    final sitelinks = data['sitelinks'];
    if (sitelinks is Map) {
      final section = sitelinks['${locale.languageCode}wiki'] ??
          sitelinks['enwiki'] ??
          sitelinks.values.firstOrNull;
      if (section is Map) {
        final lang = (section['site'] as String?)?.replaceFirst('wiki', '');
        final name = section['title'];
        if (lang != null && name is String) {
          wiki = '$lang:$name';
        }
      }
    }
    return WikidataOption(
      q: id,
      label: label,
      description: description,
      wikipedia: wiki,
    );
  }

  @override
  bool operator ==(Object other) => other is WikidataOption && other.q == q;

  @override
  int get hashCode => q.hashCode;

  @override
  String toString() => 'WikidataOption($q, "$label", desc="$description", wiki="$wikipedia")';
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
