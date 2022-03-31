import 'package:flutter/material.dart';

import 'amenity.dart';
import 'floor.dart';
import 'address.dart';

class PoiFilter {
  final Floor? floor;
  final StreetAddress? address;
  final bool includeNoData; // TODO: what does this even mean
  final bool notChecked;

  PoiFilter({this.floor, this.address, this.includeNoData = true, this.notChecked = false});

  PoiFilter copyWith(
      {Floor? floor, StreetAddress? address, bool? includeNoData, bool? notChecked}) {
    return PoiFilter(
      floor: floor ?? this.floor,
      address: address ?? this.address,
      includeNoData: includeNoData ?? this.includeNoData,
      notChecked: notChecked ?? this.notChecked,
    );
  }

  bool get isEmpty => floor == null && address == null && !notChecked;
  bool get isNotEmpty => floor != null || address != null || notChecked;

  bool matches(OsmChange amenity) {
    if (notChecked && !amenity.isOld) return false;
    final tags = amenity.getFullTags();
    bool matchesAddr = address == null || address == StreetAddress.fromTags(tags);
    bool matchesFloor = floor == null || floor == Floor.fromTags(tags);
    return matchesAddr && matchesFloor;
  }

  @override
  String toString() => 'PoiFilter(address: $address, floor: $floor)';
}
