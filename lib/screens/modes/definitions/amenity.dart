// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/amenity_age.dart';
import 'package:every_door/helpers/amenity_describer.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor.dart';
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

  List<String> _defaultPresets = _kDefaultPoiPresets;
  int _amenitiesOnScreen = 12;
  final PoiDescriber describer;
  final Map<String, int> _checkIntervals = {
    'amenity': kOldAmenityDays,
    'structure': kOldStructureDays,
  };

  AmenityModeDefinition(super.ref) : describer = AmenityDescriber(ref) {
    ourKinds = [ElementKind.amenity];
    otherKinds = [ElementKind.micro];
  }

  AmenityModeDefinition.fromPlugin(EveryDoorApp app) : this(app.ref);

  @override
  MultiIcon getIcon(BuildContext context, bool active) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon:
          active ? Icons.free_breakfast : Icons.free_breakfast_outlined,
      tooltip: loc.navPoiMode,
    );
  }

  int get maxTileCount => _kAmenitiesInList;

  @override
  updateNearest(LatLngBounds bounds) async {
    List<OsmChange> data = await super.getNearestChanges(bounds);

    // Keep other mode objects to show.
    final otherData =
        data.where((e) => otherKinds.any((k) => k.matchesChange(e))).toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => ourKinds.any((k) => k.matchesChange(e))).toList();

    // Apply the building filter.
    final filter = ref.read(poiFilterProvider);
    if (filter.isNotEmpty) {
      data = data.where((e) => filter.matches(e)).toList();
    }

    // Trim to 10-20 elements.
    if (data.length > _amenitiesOnScreen)
      data = data.sublist(0, _amenitiesOnScreen);

    // Update the map.
    nearest = data;
    other = otherData;
    notifyListeners();
  }

  @override
  Future<void> openEditor(
      {required BuildContext context,
      Located? element,
      LatLng? location}) async {
    if (element == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TypeChooserPage(
                  location: location,
                  kinds: ourKinds.first,
                  defaults: _defaultPresets,
                )),
      );
    } else if (element is OsmChange) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: element),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget buildMarker(int index, Located element) {
    final age = getAmenityData(element);
    return NumberedMarker(
      index: index,
      color: (age?.isOld ?? true) ? Colors.white : Colors.lightGreenAccent,
    );
  }

  AmenityAgeData? getAmenityData(Located element) {
    if (element is! OsmChange) return null;
    return AmenityAgeData.from(element, _checkIntervals);
  }

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {
    readKindsFromJson(data);

    final presets = data['defaultPresets'];
    if (presets != null && presets is List<dynamic>) {
      _defaultPresets = presets.whereType<String>().toList();
    }

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
