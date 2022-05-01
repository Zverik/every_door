#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:country_coder/country_coder.dart';

Future<List<double>?> getRegionCenter(
    String omapsDataPath, String region) async {
  final file = File('$omapsDataPath/borders/$region.poly');
  if (!await file.exists()) return null;

  final pointsSum = <double>[0.0, 0.0];
  int pointsCount = 0;
  bool parsing = true;
  final reNumber = RegExp(r'^\d+(?:\.\d+)?(?:E[+-]\d+)?$');
  file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((String line) {
    if (line.trim() == 'END') parsing = false;
    if (!parsing) return;
    final parts = line
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => reNumber.hasMatch(e))
        .toList();
    if (parts.length == 2) {
      for (int i = 0; i < parts.length; i++) {
        pointsSum[i] += double.parse(parts[i]);
      }
      pointsCount++;
    }
  });

  return pointsSum.map((x) => x / pointsCount).toList();
}

main(List<String> args) async {
  if (args.length < 2) {
    print(
        'Adds country language information from Organic Maps to languages.dart.');
    print(
        'Usage: dart extract_country_languages.dart <path_to_organic_maps> <languages.dart>');
    exit(1);
  }

  final countries = CountryCoder.instance;
  countries.load();

  final omapsDataPath = args[0].replaceFirst(RegExp(r'/+$'), '') + '/data';
  final metaString =
      await File('$omapsDataPath/countries_meta.txt').readAsString();
  final Map<String, dynamic> meta = jsonDecode(metaString);

  final result = <String, List<String>>{};
  for (final entry in meta.entries) {
    final country = entry.key;
    final List<dynamic>? languages = entry.value['languages'];
    if (languages == null || languages.isEmpty) continue;
    var region = countries.smallestOrMatchingRegion(query: country);
    if (region == null) {
      final center = await getRegionCenter(omapsDataPath, country);
      if (center != null) {
        region =
            countries.smallestOrMatchingRegion(lat: center[0], lon: center[1]);
      }
    }
    if (region != null) {
      if ((result[region.id]?.length ?? 100) > languages.length) {
        result[region.id] = List<String>.from(languages);
      }
    } else {
      print('Could not find data for region $country');
    }
  }

  final dart = await File(args[1]).readAsString();
  final langs = jsonEncode(result);
  final dartOut = dart.replaceFirstMapped(
      RegExp(r"(_kCountryData =\s+)\{[^;]*(;)"),
      (match) => match.group(1)! + langs + match.group(2)!);
  await File(args[1]).writeAsString(dartOut);
}
