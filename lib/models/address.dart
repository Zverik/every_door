import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart';

class StreetAddress {
  /// Location is just informative, it doesn't participate in comparison.
  final LatLng? location;
  final String? housenumber;
  final String? housename;
  final String? unit;
  final String? street;
  final String? block;
  final String? blockNumber;
  final String? place;
  final String? city;
  final String base;

  const StreetAddress({
    this.housenumber,
    this.housename,
    this.unit,
    this.street,
    this.block,
    this.blockNumber,
    this.place,
    this.city,
    this.location,
    this.base = "addr",
  });

  static const empty = StreetAddress();

  StreetAddress withBase(String base) => StreetAddress(
        housenumber: housenumber,
        housename: housename,
        unit: unit,
        street: street,
        block: block,
        blockNumber: blockNumber,
        place: place,
        city: city,
        location: location,
        base: base,
      );

  factory StreetAddress.fromTags(Map<String, String> tags,
      {LatLng? location, String base = "addr"}) {
    return StreetAddress(
      housenumber: tags['$base:housenumber'],
      housename: tags['$base:housename'],
      unit: tags['$base:unit'],
      street: tags['$base:street'],
      block: tags['$base:block'],
      blockNumber: tags['$base:block_number'],
      place: tags['$base:place'],
      city: (tags['$base:street'] == null && tags['$base:place'] == null)
          ? tags['$base:city']
          : null,
      location: location,
    );
  }

  bool get isEmpty =>
      (housenumber == null && housename == null) ||
      (street == null &&
          place == null &&
          city == null &&
          block == null &&
          blockNumber == null);
  bool get isNotEmpty => !isEmpty;

  void setTags(OsmChange element) {
    if (isEmpty) return;
    if (housenumber != null)
      element['$base:housenumber'] = housenumber;
    else
      element['$base:housename'] = housename;
    if (unit != null) element['$base:unit'] = unit;
    if (block != null) element['$base:block'] = block;
    if (blockNumber != null) element['$base:block_number'] = blockNumber;
    if (street != null)
      element['$base:street'] = street;
    else if (place != null)
      element['$base:place'] = place;
    else
      element['$base:city'] = city;
  }

  void forceTags(OsmChange element) {
    element['$base:housenumber'] = housenumber;
    element['$base:housename'] = housename;
    element['$base:unit'] = unit;
    element['$base:block'] = block;
    element['$base:block_number'] = blockNumber;
    element['$base:street'] = street;
    element['$base:place'] = place;
    // TODO: decide something about the city
    if (city != null) element['$base:city'] = city;
  }

  static void clearTags(OsmChange element, {String base = "addr"}) {
    for (final key in [
      'housenumber',
      'housename',
      'unit',
      'block',
      'block_number',
      'street',
      'place',
      'city'
    ]) element.removeTag('$base:$key');
  }

  @override
  bool operator ==(Object other) {
    if (other is! StreetAddress) return false;
    if (isEmpty && other.isEmpty) return true;
    return housenumber == other.housenumber &&
        housename == other.housename &&
        unit == other.unit &&
        block == other.block &&
        blockNumber == other.blockNumber &&
        street == other.street &&
        place == other.place &&
        city == other.city;
  }

  @override
  int get hashCode =>
      (housenumber ?? housename ?? '').hashCode +
      (block ?? blockNumber ?? '').hashCode +
      (street ?? place ?? city ?? '').hashCode +
      unit.hashCode;

  @override
  String toString() {
    final unitPart = unit != null ? " u.$unit" : "";
    final firstPart = '${housenumber ?? housename}$unitPart';
    final blockPart = blockNumber ?? block;
    final lastPart = street ?? place ?? city;
    return [firstPart, blockPart, lastPart].whereType<String>().join(', ');
  }
}
