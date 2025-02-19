import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AmenityModeDefinition extends BaseModeDefinition {
  static const kAmenitiesInList = 12;

  AmenityModeDefinition(super.ref);

  List<OsmChange> nearestPOI = [];
  List<LatLng> otherPOI = [];

  @override
  String get name => "amenity";

  @override
  MultiIcon get icon => MultiIcon(fontIcon: Icons.free_breakfast);

  @override
  MultiIcon get iconOutlined =>
      MultiIcon(fontIcon: Icons.free_breakfast_outlined);

  @override
  bool isOurKind(OsmChange element) =>
      ElementKind.amenity.matchesChange(element);

  @override
  updateNearest({LatLng? forceLocation, int? forceRadius}) async {
    List<OsmChange> data = await super.getNearestChanges(
        forceLocation: forceLocation, forceRadius: forceRadius);

    // Keep other mode objects to show.
    final otherData = data
        .where((e) => ElementKind.micro.matchesChange(e))
        .map((e) => e.location)
        .toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => ElementKind.amenity.matchesChange(e)).toList();

    // Apply the building filter.
    final filter = ref.read(poiFilterProvider);
    if (filter.isNotEmpty) {
      data = data.where((e) => filter.matches(e)).toList();
    }

    // Sort by distance.
    const distance = DistanceEquirectangular();
    final LatLng location =
        forceLocation ?? ref.read(effectiveLocationProvider);
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    // Trim to 10-20 elements.
    if (data.length > kAmenitiesInList)
      data = data.sublist(0, kAmenitiesInList);

    // Update the map.
    nearestPOI = data;
    otherPOI = otherData;
    notifyListeners();
  }

  static const kDefaultPresets = [
    // Should be exactly 8 lines.
    'shop/convenience', 'amenity/atm',
    'shop/hairdresser', 'shop/beauty',
    'shop/florist', 'amenity/pharmacy',
    'shop/clothes', 'shop/shoes',
    'amenity/toilets', 'shop/bakery',
    'amenity/restaurant', 'amenity/cafe',
    'amenity/fast_food', 'amenity/bar',
    'amenity/fuel', 'amenity/car_wash',
  ];

  void openEditor(BuildContext context, LatLng location) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TypeChooserPage(
                location: location,
                kinds: ElementKind.amenity,
                defaults: kDefaultPresets,
              )),
    );
  }

  Widget buildMarker(int index, OsmChange element) {
    return NumberedMarker(index: index);
  }

  @override
  void updateFromJson(Map<String, dynamic> data) {
    // TODO: implement updateFromJson
  }
}
