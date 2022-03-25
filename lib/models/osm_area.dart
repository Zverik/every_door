import 'package:every_door/constants.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OsmDownloadedArea {
  final LatLngBounds bounds;
  final DateTime downloaded;

  const OsmDownloadedArea(this.bounds, this.downloaded);

  bool get isObsolete => DateTime.now().difference(downloaded) > kObsoleteData;

  static const kTableName = 'areas';
  static const kTableFields = <String>[
    'min_lat real',
    'min_lon real',
    'max_lat real',
    'max_lon real',
    'downloaded integer',
  ];

  factory OsmDownloadedArea.fromJson(Map<String, dynamic> data) {
    return OsmDownloadedArea(
      LatLngBounds(
        LatLng(data['min_lat'], data['min_lon']),
        LatLng(data['max_lat'], data['max_lon']),
      ),
      DateTime.fromMillisecondsSinceEpoch(data['downloaded']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_lat': bounds.south,
      'min_lon': bounds.west,
      'max_lat': bounds.north,
      'max_lon': bounds.east,
      'downloaded': downloaded.millisecondsSinceEpoch,
    };
  }
}
