import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart';

/// A model for block-based addressing.
/// Fields are fixed and must use underscores exactly as specified:
/// province, county, city, suburb, neighbourhood, block_number, housenumber
class BlockBasedAddress {
  /// Location is informative; it does not participate in comparison.
  final LatLng? location;

  final String? postcode;
  final String? province;
  final String? county;
  final String? city;
  final String? suburb;
  final String? quarter;
  final String? neighbourhood;
  /// Note: key name must be `block_number` in tags
  final String? blockNumber;
  final String? housenumber;

  /// The key part before the semicolon, "addr" by default.
  final String base;

  const BlockBasedAddress({
    this.postcode,
    this.province,
    this.county,
    this.city,
    this.suburb,
    this.quarter,
    this.neighbourhood,
    this.blockNumber,
    this.housenumber,
    this.location,
    this.base = 'addr',
  });

  static const empty = BlockBasedAddress();

  BlockBasedAddress withBase(String base) => BlockBasedAddress(
        postcode: postcode,    
        province: province,
        county: county,
        city: city,
        suburb: suburb,
        quarter: quarter,
        neighbourhood: neighbourhood,
        blockNumber: blockNumber,
        housenumber: housenumber,
        location: location,
        base: base,
      );

  factory BlockBasedAddress.fromTags(Map<String, String> tags,
      {LatLng? location, String base = 'addr'}) {
    return BlockBasedAddress(
      province: tags['$base:province'],
      county: tags['$base:county'],
      city: tags['$base:city'],
      suburb: tags['$base:suburb'],
      neighbourhood: tags['$base:neighbourhood'],
      quarter: tags['$base:quarter'],
      postcode: tags['$base:postcode'],
      blockNumber: tags['$base:block_number'],
      housenumber: tags['$base:housenumber'],
      location: location,
      base: base,
    );
  }

  bool get isEmpty => (housenumber == null || housenumber!.isEmpty) &&
      (blockNumber == null || blockNumber!.isEmpty) &&
      (city == null || city!.isEmpty) &&
      (suburb == null || suburb!.isEmpty) &&
      (neighbourhood == null || neighbourhood!.isEmpty) &&
      (quarter == null || quarter!.isEmpty) &&
      (postcode == null || postcode!.isEmpty) &&
      (county == null || county!.isEmpty) &&
      (province == null || province!.isEmpty);
  bool get isNotEmpty => !isEmpty;

  /// Applies address tags onto the [element]. Does not erase tags that this
  /// address does not define.
  void setTags(OsmChange element) {
    if (isEmpty) return;
    if (housenumber != null) {
      element['$base:housenumber'] = housenumber;
    }
    if (blockNumber != null) {
      element['$base:block_number'] = blockNumber;
    }
    if (neighbourhood != null) {
      element['$base:neighbourhood'] = neighbourhood;
    }
    if (quarter != null) {
      element['$base:quarter'] = quarter;
    }
    if (postcode != null) {
      element['$base:postcode'] = postcode;
    }
    if (suburb != null) {
      element['$base:suburb'] = suburb;
    }
    if (city != null) {
      element['$base:city'] = city;
    }
    if (county != null) {
      element['$base:county'] = county;
    }
    if (province != null) {
      element['$base:province'] = province;
    }
    element.removeTag('$base:street');
  }

  /// Applies address tags onto the [element], removing any tags
  /// that this address does not have.
  void forceTags(OsmChange element) {
    element['$base:housenumber'] = housenumber;
    element['$base:block_number'] = blockNumber;
    element['$base:neighbourhood'] = neighbourhood;
    element['$base:quarter'] = quarter;
    element['$base:postcode'] = postcode;
    element['$base:suburb'] = suburb;
    element['$base:city'] = city;
    element['$base:county'] = county;
    element['$base:province'] = province;
    element.removeTag('$base:street');
  }

  static void clearTags(OsmChange element, {String base = 'addr'}) {
    for (final key in const [
      'housenumber',
      'block_number',
      'neighbourhood',
      'quarter',
      'postcode',
      'suburb',
      'city',
      'county',
      'province',
      'street',
    ]) {
      element.removeTag('$base:$key');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! BlockBasedAddress) return false;
    if (isEmpty && other.isEmpty) return true;
    return housenumber == other.housenumber &&
        blockNumber == other.blockNumber &&
        neighbourhood == other.neighbourhood &&
        quarter == other.quarter &&
        suburb == other.suburb &&
        city == other.city &&
        county == other.county &&
        province == other.province &&
        postcode == other.postcode;
  }

  @override
  int get hashCode =>
      (housenumber ?? '').hashCode +
      (blockNumber ?? '').hashCode +
      (neighbourhood ?? '').hashCode +
      (quarter ?? '').hashCode +
      (suburb ?? '').hashCode +
      (city ?? '').hashCode +
      (county ?? '').hashCode +
      (province ?? '').hashCode +
      (postcode ?? '').hashCode;

  @override
  String toString() {
    // For BlockBased display, prefer order: postcode -> province -> county -> city -> neighbourhood -> block_number -> housenumber
    return [
      postcode,
      province,
      county,
      city,
      neighbourhood,
      blockNumber,
      housenumber
    ].where((s) => s != null && s.isNotEmpty).join(' ');
  }

  String toShortString() {
    // Show only the most specific parts for selection
    final main = [neighbourhood, blockNumber].where((s) => s != null && s.isNotEmpty).join();
    if (main.isEmpty && (housenumber == null || housenumber!.isEmpty)) return toString();
    if (housenumber == null || housenumber!.isEmpty) return main;
    if (main.isEmpty) return housenumber!;
    return '$main-$housenumber';
  }
}
