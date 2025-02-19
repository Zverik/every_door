import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/legend.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MicromappingModeDefinition extends BaseModeDefinition {
  static const kMicroStuffInList = 24;

  MicromappingModeDefinition(super.ref);

  @override
  String get name => "micro";

  @override
  MultiIcon get icon => MultiIcon(fontIcon: Icons.park);

  @override
  MultiIcon get iconOutlined => MultiIcon(fontIcon: Icons.park_outlined);

  @override
  bool isOurKind(OsmChange element) => ElementKind.micro.matchesChange(element);

  List<OsmChange> nearestPOI = [];
  List<LatLng> otherPOI = [];

  @override
  updateNearest({LatLng? forceLocation, int? forceRadius}) async {
    List<OsmChange> data = await super.getNearestChanges(
        forceLocation: forceLocation, forceRadius: forceRadius);

    // Keep other mode objects to show.
    final otherData = data
        .where((e) => ElementKind.amenity.matchesChange(e))
        .map((e) => e.location)
        .toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => ElementKind.micro.matchesChange(e)).toList();

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
    if (data.length > kMicroStuffInList)
      data = data.sublist(0, kMicroStuffInList);

    // Update the map.
    nearestPOI = data;
    otherPOI = otherData;
    notifyListeners();
  }

  static const kDefaultMicroPresets = [
    // Should be exactly 8 lines.
    'amenity/waste_basket', 'amenity/bench',
    'highway/street_lamp', 'natural/tree',
    'power/pole', 'man_made/utility_pole',
    'amenity/recycling', 'amenity/waste_disposal',
    'emergency/fire_hydrant', 'man_made/street_cabinet',
    'leisure/playground', 'amenity/bicycle_parking',
    'amenity/post_box', 'man_made/manhole',
    'tourism/information/guidepost', 'tourism/information/board',
  ];

  void openEditor(BuildContext context, LatLng location) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TypeChooserPage(
                location: location,
                kinds: ElementKind.micro,
                defaults: kDefaultMicroPresets,
              )),
    );
  }

  void updateLegend(Locale locale) {
    ref.read(legendProvider.notifier).updateLegend(nearestPOI, locale: locale);
  }

  Color getIconColor(OsmChange amenity) {
    final legendController = ref.read(legendProvider.notifier);
    return legendController.getLegendItem(amenity)?.color ?? kLegendOtherColor;
  }

  Widget buildMarker(int index, OsmChange element, bool isZoomedIn) {
    return isZoomedIn
        ? NumberedMarker(index: index, color: getIconColor(element))
        : ColoredMarker(
            isIncomplete: ElementKind.needsInfo.matchesChange(element),
            color: getIconColor(element),
          );
  }

  @override
  void updateFromJson(Map<String, dynamic> data) {
    // TODO: implement updateFromJson
  }
}
