import 'dart:convert' show json;

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/debouncable.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';

class NominatimNavigator extends ConsumerStatefulWidget {
  const NominatimNavigator({super.key});

  @override
  ConsumerState<NominatimNavigator> createState() => _NominatimNavigatorState();
}

class _NominatimNavigatorState extends ConsumerState<NominatimNavigator> {
  final _logger = Logger('NominatimNavigator');
  Iterable<NominatimResult> _options = [];
  String? _currentSearch;
  static const kEndpoint = 'nominatim.openstreetmap.org';
  late final Debounceable<Iterable<NominatimResult>?, String> _debSearch;

  Future<List<NominatimResult>?> _queryNominatim(String search) async {
    if (search.length < 2) return [];
    _currentSearch = search;

    // TODO: use Locale for the accept-language header, or parameter.
    final url = Uri.https(kEndpoint, '/search', {
      'q': search,
      'format': 'jsonv2',
      'email': 'everydoor@zverev.info',
    });
    final result = await http.get(url, headers: {
      'User-Agent': '$kAppTitle $kAppVersion',
    });

    if (_currentSearch != search) return null;
    _currentSearch = null;

    if (result.statusCode != 200) {
      _logger.severe(
          'Failed to query Nominatim: ${result.statusCode} ${result.body}');
      return [];
    }
    final items = json.decode(result.body);
    if (items is! List) return [];
    return items.map((i) => NominatimResult.fromJson(i)).toList();
  }

  @override
  void initState() {
    super.initState();
    _debSearch = debounce(_queryNominatim, Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<NominatimResult>(
      fieldViewBuilder: (ctx, controller, focusNode, onSubmit) => TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (value) {
          onSubmit();
        },
        decoration: InputDecoration(
          icon: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(Icons.search),
          ),
          hintText: 'Navigate to...',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: () {
              controller.clear();
            },
          ),
        ),
      ),
      optionsBuilder: (data) async {
        final options = await _debSearch(data.text.trim());
        if (options == null) return _options;
        return _options = options;
      },
      onSelected: (result) {
        ref.read(effectiveLocationProvider.notifier).set(result.location);
        ref.read(zoomProvider.notifier).update(result.zoom);
      },
      displayStringForOption: (result) => result.title,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
    );
  }
}

class NominatimResult {
  final String title;
  final LatLng location;
  final double zoom;

  const NominatimResult(this.title, this.location, this.zoom);

  factory NominatimResult.fromJson(Map<String, dynamic> data) {
    return NominatimResult(data['display_name'],
        LatLng(double.parse(data['lat']), double.parse(data['lon'])), 15);
  }
}
