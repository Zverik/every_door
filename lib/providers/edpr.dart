import 'dart:convert' show json, utf8;

import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final edprProvider = FutureProvider<List<RemotePlugin>>((ref) async {
  // For now without customization.
  final location = ref.read(effectiveLocationProvider);
  final countries = CountryCoder.instance.load();
  final countryResults = countries.regionsContaining(
      lat: location.latitude, lon: location.longitude);
  final countryIds =
      countryResults.map((c) => (c.iso1A2 ?? c.id).toUpperCase()).join(',');

  final url = Uri.https(kEdprEndpoint, '/api/list', {
    'countries': countryIds,
    'exp': 1,
  });
  var response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('Failed to query plugins list: ${response.statusCode}');
  }

  final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
  final result = data.map((item) => RemotePlugin(item));
  return result.toList();
});
