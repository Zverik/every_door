import 'package:every_door/models/amenity.dart';

class StreetAddress {
  final String? housenumber;
  final String? housename;
  final String? street;
  final String? place;

  StreetAddress({this.housenumber, this.housename, this.street, this.place});

  factory StreetAddress.fromTags(Map<String, String> tags) {
    return StreetAddress(
      housenumber: tags['addr:housenumber'],
      housename: tags['addr:housename'],
      street: tags['addr:street'],
      place: tags['addr:place'],
    );
  }

  bool get isEmpty => (housenumber == null && housename == null) || (street == null && place == null);
  bool get isNotEmpty => !isEmpty;

  setTags(OsmChange element) {
    if (isEmpty) return;
    if (housenumber != null)
      element['addr:housenumber'] = housenumber;
    else
      element['addr:housename'] = housename;
    if (street != null)
      element['addr:street'] = street;
    else
      element['addr:place'] = place;
  }

  static clearTags(OsmChange element) {
    for (final key in ['housenumber', 'housename', 'street', 'place'])
      element.removeTag('addr:$key');
  }

  @override
  bool operator ==(Object other) {
    if (other is! StreetAddress) return false;
    return housenumber == other.housenumber && housename == other.housename && street == other.street && place == other.place;
  }

  @override
  int get hashCode => (housenumber ?? housename ?? '').hashCode + (street ?? place ?? '').hashCode;

  @override
  String toString() => '${housenumber ?? housename}, ${street ?? place}';
}