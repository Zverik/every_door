// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'amenity.dart';
import 'floor.dart';
import 'address.dart';

class PoiFilter {
  static const nullFloor = Floor(floor: 'null', level: 0.123456);
  static const nullAddress = StreetAddress(housenumber: 'null', street: 'null');

  final Floor? floor;
  final StreetAddress? address;
  final bool includeNoData; // TODO: what does this even mean
  final bool notChecked;

  PoiFilter(
      {this.floor,
      this.address,
      this.includeNoData = true,
      this.notChecked = false});

  PoiFilter copyWith(
      {Floor? floor,
      StreetAddress? address,
      bool? includeNoData,
      bool? notChecked}) {
    return PoiFilter(
      floor: floor == nullFloor ? null : (floor ?? this.floor),
      address: address == nullAddress ? null : address ?? this.address,
      includeNoData: includeNoData ?? this.includeNoData,
      notChecked: notChecked ?? this.notChecked,
    );
  }

  bool get isEmpty => floor == null && address == null && !notChecked;
  bool get isNotEmpty => floor != null || address != null || notChecked;

  bool matches(OsmChange amenity) {
    if (notChecked && !amenity.isOld) return false;
    final tags = amenity.getFullTags();
    bool matchesAddr =
        address == null || address == StreetAddress.fromTags(tags);
    final floors = MultiFloor.fromTags(tags);
    bool matchesFloor = floor == null ||
        ((floor?.isEmpty ?? true)
            ? floors.isEmpty
            : floors.floors.contains(floor));
    return matchesAddr && matchesFloor;
  }

  @override
  String toString() => 'PoiFilter(address: $address, floor: $floor)';
}
