// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart' show LatLng;

class OsmDownloadedArea {
  final LatLngBounds bounds;
  final DateTime downloaded;
  final String source;

  const OsmDownloadedArea(
      {required this.bounds, required this.downloaded, required this.source});

  bool get isObsolete => DateTime.now().difference(downloaded) > kObsoleteData;

  static const kTableName = 'areas';
  static const kTableFields = <String>[
    'min_lat real',
    'min_lon real',
    'max_lat real',
    'max_lon real',
    'downloaded integer',
    'source text',
  ];

  factory OsmDownloadedArea.fromJson(Map<String, dynamic> data) {
    return OsmDownloadedArea(
      bounds: LatLngBounds(
        LatLng(data['min_lat'], data['min_lon']),
        LatLng(data['max_lat'], data['max_lon']),
      ),
      downloaded: DateTime.fromMillisecondsSinceEpoch(data['downloaded']),
      source: data['source'] ?? 'osm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_lat': bounds.south,
      'min_lon': bounds.west,
      'max_lat': bounds.north,
      'max_lon': bounds.east,
      'downloaded': downloaded.millisecondsSinceEpoch,
      'source': source,
    };
  }
}
