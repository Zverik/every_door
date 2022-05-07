import 'package:latlong2/latlong.dart' show LatLng;
import 'package:proximity_hash/geohash.dart';

class RoadNameRecord {
  final String geohash;
  final String name;
  final DateTime? downloaded;

  const RoadNameRecord(this.name, this.geohash, [this.downloaded]);

  LatLng get center {
    final coords = GeoHasher().decode(geohash);
    return LatLng(coords[1], coords[0]);
  }

  @override
  bool operator ==(Object other) =>
      other is RoadNameRecord && other.geohash == geohash && other.name == name;

  @override
  int get hashCode => name.hashCode + geohash.hashCode;

  static const kTableName = 'road_names';
  static const kTableFields = <String>[
    'name text',
    'geohash text',
    'downloaded integer',
  ];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'geohash': geohash,
      'downloaded': (downloaded ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  factory RoadNameRecord.fromJson(Map<String, dynamic> data) {
    return RoadNameRecord(
      data['name'],
      data['geohash'],
      DateTime.fromMillisecondsSinceEpoch(data['downloaded']),
    );
  }
}
