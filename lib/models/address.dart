import 'package:every_door/models/amenity.dart';

class StreetAddress {
  final String? housenumber;
  final String? housename;
  final String? unit;
  final String? street;
  final String? place;

  StreetAddress(
      {this.housenumber, this.housename, this.unit, this.street, this.place});

  StreetAddress.empty()
      : housename = null,
        housenumber = null,
        unit = null,
        street = null,
        place = null;

  factory StreetAddress.fromTags(Map<String, String> tags) {
    return StreetAddress(
      housenumber: tags['addr:housenumber'],
      housename: tags['addr:housename'],
      unit: tags['addr:unit'],
      street: tags['addr:street'],
      place: tags['addr:place'],
    );
  }

  bool get isEmpty =>
      (housenumber == null && housename == null) ||
      (street == null && place == null);
  bool get isNotEmpty => !isEmpty;

  setTags(OsmChange element) {
    if (isEmpty) return;
    if (housenumber != null)
      element['addr:housenumber'] = housenumber;
    else
      element['addr:housename'] = housename;
    if (unit != null) element['addr:unit'] = unit;
    if (street != null)
      element['addr:street'] = street;
    else
      element['addr:place'] = place;
  }

  static clearTags(OsmChange element) {
    for (final key in ['housenumber', 'housename', 'unit', 'street', 'place'])
      element.removeTag('addr:$key');
  }

  @override
  bool operator ==(Object other) {
    if (other is! StreetAddress) return false;
    if (isEmpty && other.isEmpty) return true;
    return housenumber == other.housenumber &&
        housename == other.housename &&
        unit == other.unit &&
        street == other.street &&
        place == other.place;
  }

  @override
  int get hashCode =>
      (housenumber ?? housename ?? '').hashCode +
      (street ?? place ?? '').hashCode +
      unit.hashCode;

  @override
  String toString() =>
      '${housenumber ?? housename}${unit != null ? " u.$unit" : ""}, ${street ?? place}';
}
