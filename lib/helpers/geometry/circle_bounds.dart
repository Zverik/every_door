// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;
import 'dart:math' as math;

LatLngBounds boundsFromRadius(LatLng center, num radiusMeters) {
  const double equatorRadius = 6378137.0;
  const double degreeLength = equatorRadius * 2 * math.pi / 360.0;
  final dy = radiusMeters.toDouble() / degreeLength;
  final dx = dy / math.cos(center.latitudeInRad);
  // For testing: (59.9598294, 30.3194758) + 100 m
  // should result in (59.9607281, 30.3212749)
  return LatLngBounds(
    LatLng(center.latitude - dy, center.longitude - dx),
    LatLng(center.latitude + dy, center.longitude + dx),
  );
}
