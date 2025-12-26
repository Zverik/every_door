// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:proximity_hash/geohash.dart';

class ImageryOffset {
  static const kGeohashPrecision = 6;

  final int id;
  final LatLng originPos;
  final LatLng imageryPos;
  final String url;
  final DateTime date;

  const ImageryOffset(
      {required this.id,
      required this.originPos,
      required this.imageryPos,
      required this.url,
      required this.date});

  @override
  bool operator ==(Object other) => other is ImageryOffset && other.id == id;

  @override
  int get hashCode => id.hashCode;

  static const kTableName = 'offsets';
  static const kTableFields = <String>[
    'id integer primary key',
    'lat integer',
    'lon integer',
    'imlat integer',
    'imlon integer',
    'url text',
    'geohash text',
    'date integer',
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': (originPos.latitude * kCoordinatePrecision).round(),
      'lon': (originPos.longitude * kCoordinatePrecision).round(),
      'imlat': (imageryPos.latitude * kCoordinatePrecision).round(),
      'imlon': (imageryPos.longitude * kCoordinatePrecision).round(),
      'url': url,
      'geohash': GeoHasher().encode(originPos.longitude, originPos.latitude,
          precision: kGeohashPrecision),
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ImageryOffset.fromJson(Map<String, dynamic> data) {
    return ImageryOffset(
      id: data['id'],
      originPos: LatLng(
        data['lat'] / kCoordinatePrecision,
        data['lon'] / kCoordinatePrecision,
      ),
      imageryPos: LatLng(
        data['imlat'] / kCoordinatePrecision,
        data['imlon'] / kCoordinatePrecision,
      ),
      url: data['url'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
    );
  }

  factory ImageryOffset.fromWebJson(Map<String, dynamic> data) {
    return ImageryOffset(
      id: data['id'],
      originPos: LatLng(data['lat'], data['lon']),
      imageryPos: LatLng(data['imlat'], data['imlon']),
      url: data['imagery'],
      date: DateTime.parse(data['date']),
    );
  }
}
