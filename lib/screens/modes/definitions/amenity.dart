import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

const _kDefaultPoiPresets = [
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

@Bind(bridge: true, implicitSupers: true)
abstract class AmenityModeDefinition extends BaseModeDefinition {
  static const _kAmenitiesInList = 12;

  List<OsmChange> nearestPOI = [];
  List<LatLng> otherPOI = [];
  List<String> _defaultPresets = _kDefaultPoiPresets;
  List<ElementKindImpl> _kinds = [ElementKind.amenity];
  List<ElementKindImpl> _otherKinds = [ElementKind.micro];
  int _amenitiesOnScreen = 12;
  final Map<String, int> _checkIntervals = {
    'amenity': kOldAmenityDays,
    'structure': kOldStructureDays,
  };

  AmenityModeDefinition(super.ref);

  AmenityModeDefinition.fromPlugin(EveryDoorApp app): this(app.ref);

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon:
          !outlined ? Icons.free_breakfast : Icons.free_breakfast_outlined,
      tooltip: loc.navPoiMode,
    );
  }

  @override
  bool isOurKind(OsmChange element) =>
      _kinds.any((k) => k.matchesChange(element));

  int get maxTileCount => _kAmenitiesInList;

  @override
  updateNearest(LatLngBounds bounds) async {
    List<OsmChange> data =
        await super.getNearestChanges(bounds, filter: false);

    // Keep other mode objects to show.
    final otherData = data
        .where((e) => _otherKinds.any((k) => k.matchesChange(e)))
        .map((e) => e.location)
        .toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => isOurKind(e)).toList();

    // Apply the building filter.
    final filter = ref.read(poiFilterProvider);
    if (filter.isNotEmpty) {
      data = data.where((e) => filter.matches(e)).toList();
    }

    // Trim to 10-20 elements.
    if (data.length > _amenitiesOnScreen)
      data = data.sublist(0, _amenitiesOnScreen);

    // Update the map.
    nearestPOI = data;
    otherPOI = otherData;
    notifyListeners();
  }

  void openEditor(BuildContext context, LatLng location) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TypeChooserPage(
                location: location,
                kinds: _kinds.first,
                defaults: _defaultPresets,
              )),
    );
  }

  Widget buildMarker(int index, OsmChange element) {
    return NumberedMarker(
      index: index,
      color: isCountedOld(element, element.age)
          ? Colors.white
          : Colors.lightGreenAccent,
    );
  }

  bool isCountedOld(OsmChange element, int age) {
    for (final entry in _checkIntervals.entries) {
      if (entry.key != 'amenity' &&
          ElementKind.get(entry.key).matchesChange(element))
        return age >= entry.value;
    }
    return age >= _checkIntervals['amenity']!;
  }

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {
    final presets = data['defaultPresets'];
    if (presets != null && presets is List<dynamic>) {
      _defaultPresets = presets.whereType<String>().toList();
    }

    _kinds = parseKinds(data['kinds']) ?? parseKinds(data['kind']) ?? _kinds;
    _otherKinds = parseKinds(data['otherKinds']) ??
        parseKinds(data['otherKind']) ??
        _otherKinds;

    final intervals = data['checkIntervals'];
    if (intervals != null && intervals is Map<String, dynamic>) {
      intervals.forEach((kind, interval) {
        if (interval is int) _checkIntervals[kind] = interval;
      });
    }

    final amenitiesCount = data['amenitiesOnScreen'];
    if (amenitiesCount != null && amenitiesCount is int) {
      _amenitiesOnScreen = amenitiesCount;
    }
  }
}

class DefaultAmenityModeDefinition extends AmenityModeDefinition {
  DefaultAmenityModeDefinition(super.ref);

  @override
  String get name => "amenity";
}
