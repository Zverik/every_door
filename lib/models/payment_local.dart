// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:fast_geohash/fast_geohash_str.dart';
import 'package:latlong2/latlong.dart';

class LocalPayment {
  static const kGeohashPrecision = 5; // 2.4 km

  final int id;
  final LatLng center;
  final Set<String> options;

  LocalPayment({
    required this.id,
    required this.center,
    required this.options,
  }) {
    if (options.isEmpty)
      throw Exception('Cannot instantiate LocalPayment with empty options.');
  }

  LocalPayment update(Set<String> newOptions) =>
      LocalPayment(id: id, center: center, options: newOptions);

  @override
  bool operator ==(Object other) => other is LocalPayment && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LocalPayment($center, "${options.join(",")}")';

  static const kTableName = 'payment';
  static const kTableFields = [
    'id integer',
    'lat integer',
    'lon integer',
    'geohash text',
    'options text',
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': (center.latitude * kCoordinatePrecision).round(),
      'lon': (center.longitude * kCoordinatePrecision).round(),
      'geohash':
          geohash.encode(center.latitude, center.longitude, kGeohashPrecision),
      'options': options.join(';'),
    };
  }

  factory LocalPayment.fromJson(Map<String, dynamic> data) {
    return LocalPayment(
      id: data['id'],
      center: LatLng(
        data['lat'] / kCoordinatePrecision,
        data['lon'] / kCoordinatePrecision,
      ),
      options: data['options'].split(';').toSet(),
    );
  }
}
