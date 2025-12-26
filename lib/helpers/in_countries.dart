// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:country_coder/country_coder.dart';
import 'package:latlong2/latlong.dart' show LatLng;

Future<bool> isInsideRegions(LatLng location, List<String> regions) async {
  if (!CountryCoder.instance.ready) {
    await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
        .then((_) => !CountryCoder.instance.ready));
  }

  final queried = CountryCoder.instance.smallestOrMatchingRegion(lon: location.longitude, lat: location.latitude);
  if (queried == null) return false; // Outside any of the regions.

  for (final region in regions) {
    final boundsRegion = CountryCoder.instance.region(query: region);

    if (boundsRegion != null) {
      if (queried.id == boundsRegion.id) return true;
      if (queried.groups.contains(boundsRegion.id)) return true;
    }
  }

  return false;
}

Future<bool> buildingsHaveAddresses(LatLng location) async {
  return !(await isInsideRegions(location, [
    'Q55', // Netherlands
    'Q38', // Italy
    'Q142', // France
  ]));
}
