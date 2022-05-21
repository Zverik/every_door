import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart';

class StreetAddress {
  /// Location is just informative, it doesn't participate in comparison.
  final LatLng? location;
  final String? housenumber;
  final String? housename;
  final String? unit;
  final String? street;
  final String? place;
  final String? city;

  const StreetAddress(
      {this.housenumber,
      this.housename,
      this.unit,
      this.street,
      this.place,
      this.city,
      this.location});

  static const empty = StreetAddress();

  factory StreetAddress.fromTags(Map<String, String> tags, [LatLng? location]) {
    return StreetAddress(
      housenumber: tags['addr:housenumber'],
      housename: tags['addr:housename'],
      unit: tags['addr:unit'],
      street: tags['addr:street'],
      place: tags['addr:place'],
      city: (tags['addr:street'] == null && tags['addr:place'] == null)
          ? tags['addr:city']
          : null,
      location: location,
    );
  }

  bool get isEmpty =>
      (housenumber == null && housename == null) ||
      (street == null && place == null && city == null);
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
    else if (place != null)
      element['addr:place'] = place;
    else
      element['addr:city'] = city;
  }

  forceTags(OsmChange element) {
    element['addr:housenumber'] = housenumber;
    element['addr:housename'] = housename;
    element['addr:unit'] = unit;
    element['addr:street'] = street;
    element['addr:place'] = place;
    element['addr:city'] = city;
  }

  static clearTags(OsmChange element) {
    for (final key in [
      'housenumber',
      'housename',
      'unit',
      'street',
      'place',
      'city'
    ]) element.removeTag('addr:$key');
  }

  @override
  bool operator ==(Object other) {
    if (other is! StreetAddress) return false;
    if (isEmpty && other.isEmpty) return true;
    return housenumber == other.housenumber &&
        housename == other.housename &&
        unit == other.unit &&
        street == other.street &&
        place == other.place &&
        city == other.city;
  }

  @override
  int get hashCode =>
      (housenumber ?? housename ?? '').hashCode +
      (street ?? place ?? city ?? '').hashCode +
      unit.hashCode;

  @override
  String toString() =>
      '${housenumber ?? housename}${unit != null ? " u.$unit" : ""}, ${street ?? place ?? city}';
}
