import 'floor.dart';
import 'address.dart';

class PoiFilter {
  final Floor? floor;
  final StreetAddress? address;
  final bool includeNoData; // TODO: what does this even mean

  PoiFilter({this.floor, this.address, this.includeNoData = true});

  PoiFilter copyWith(
      {Floor? floor, StreetAddress? address, bool? includeNoData}) {
    return PoiFilter(
      floor: floor ?? this.floor,
      address: address ?? this.address,
      includeNoData: includeNoData ?? this.includeNoData,
    );
  }

  bool get isEmpty => floor == null && address == null;
  bool get isNotEmpty => floor != null || address != null;

  bool matches(Map<String, String> tags) {
    bool matchesAddr = address == null || address == StreetAddress.fromTags(tags);
    bool matchesFloor = floor == null || floor == Floor.fromTags(tags);
    return matchesAddr && matchesFloor;
  }

  @override
  String toString() => 'PoiFilter(address: $address, floor: $floor)';
}
