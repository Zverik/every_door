import 'package:country_coder/country_coder.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/screens/editor/building.dart';
import 'package:every_door/screens/editor/entrance.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/entrance_markers.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntrancesModeDefinition extends BaseModeDefinition {
  static final kOurKinds = <ElementKindImpl>[
    ElementKind.entrance,
    ElementKind.building,
    ElementKind.address,
  ];

  bool buildingsNeedAddresses = false;
  List<OsmChange> nearest = [];
  LatLng? newLocation;

  EntrancesModeDefinition(super.ref);

  @override
  String get name => "entrances";

  @override
  MultiIcon get icon => MultiIcon(fontIcon: Icons.home);

  @override
  MultiIcon get iconOutlined => MultiIcon(fontIcon: Icons.home_outlined);

  ElementKindImpl _getOurKind(OsmChange element) =>
      ElementKind.matchChange(element, kOurKinds);

  @override
  bool isOurKind(OsmChange element) =>
      _getOurKind(element) != ElementKind.unknown;

  double get adjustZoomPrimary => 0.0;
  double get adjustZoomSecondary => 0.7;

  @override
  Future<void> updateNearest({LatLng? forceLocation, int? forceRadius}) async {
    final LatLng location =
        forceLocation ?? ref.read(effectiveLocationProvider);

    final nearest = await super.getNearestChanges(
        forceLocation: forceLocation, forceRadius: forceRadius);

    // Sort by buildings, addresses, entrances
    int indexKind(OsmChange change) {
      final kind = _getOurKind(change);
      if (kind == ElementKind.building) return 0;
      if (kind == ElementKind.address) return 1;
      if (kind == ElementKind.entrance) return 2;
      return 3;
    }

    nearest.sort((a, b) => indexKind(a).compareTo(indexKind(b)));

    // Wait for country coder
    if (!CountryCoder.instance.ready) {
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
          .then((_) => !CountryCoder.instance.ready));
    }

    buildingsNeedAddresses = !CountryCoder.instance.isIn(
      lat: location.latitude,
      lon: location.longitude,
      inside: 'Q55', // Netherlands
    );

    this.nearest = nearest;
    notifyListeners();
  }

  static const kBuildingNeedsAddress = {
    'yes',
    'house',
    'residential',
    'detached',
    'apartments',
    'terrace',
    'commercial',
    'school',
    'semidetached_house',
    'retail',
    'construction',
    'farm',
    'church',
    'office',
    'civic',
    'university',
    'public',
    'hospital',
    'hotel',
    'chapel',
    'kindergarten',
    'mosque',
    'dormitory',
    'train_station',
    'college',
    'semi',
    'temple',
    'government',
    'supermarket',
    'fire_station',
    'sports_centre',
    'shop',
    'stadium',
    'religious',
  };

  String makeBuildingLabel(OsmChange building) {
    const kMaxNumberLength = 6;
    final needsAddress = buildingsNeedAddresses &&
        (building['building'] == null ||
            kBuildingNeedsAddress.contains(building['building']));
    String number = building['addr:housenumber'] ??
        building['addr:housename'] ??
        (needsAddress ? '?' : '');
    if (number.length > kMaxNumberLength) {
      final spacePos = number.indexOf(' ');
      if (spacePos > 0) number = number.substring(0, spacePos);
      if (number.length > kMaxNumberLength)
        number = number.substring(0, kMaxNumberLength - 1);
      number = number + '…';
    }

    return number;
  }

  SizedMarker buildMarker(OsmChange element) {
    final kind = _getOurKind(element);
    if (kind == ElementKind.building) {
      final isComplete = element['building:levels'] != null;
      return BuildingMarker(
        label: makeBuildingLabel(element),
        isComplete: isComplete,
      );
    } else if (kind == ElementKind.address) {
      return AddressMarker(
        label: makeBuildingLabel(element),
      );
    } else {
      // entrance
      const kNeedsData = {'staircase', 'yes'};
      final isComplete = (kNeedsData.contains(element['entrance'])
              ? (element['addr:flats'] ?? element['addr:unit']) != null
              : true) &&
          element['entrance'] != 'yes';
      return EntranceMarker(
        isComplete: isComplete,
      );
    }
  }

  MultiIcon? getButton(BuildContext context, bool isPrimary) {
    final loc = AppLocalizations.of(context)!;
    if (isPrimary) {
      return MultiIcon(
        fontIcon: Icons.house,
        tooltip: loc.entrancesAddBuilding,
      );
    } else {
      return MultiIcon(
        fontIcon: Icons.house,
        tooltip: loc.entrancesAddBuilding,
      );
    }
  }

  void openEditor({
    required BuildContext context,
    OsmChange? element,
    LatLng? location,
    bool? isPrimary,
  }) async {
    final LatLng loc =
        location ?? element?.location ?? ref.read(effectiveLocationProvider);
    Widget pane;
    // TODO: how do we create one?
    if (isPrimary != null && !isPrimary ||
        (element != null && ElementKind.entrance.matchesChange(element))) {
      pane = EntranceEditorPane(entrance: element, location: loc);
    } else {
      pane = BuildingEditorPane(building: element, location: loc);
    }

    if (location != null) {
      newLocation = location;
      notifyListeners();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => pane,
    );
    newLocation = null;
    notifyListeners();
  }

  Widget disambiguationLabel(BuildContext context, OsmChange element) {
    final loc = AppLocalizations.of(context)!;
    final kind = _getOurKind(element);

    String label;
    if (kind == ElementKind.building) {
      label = loc
          .buildingX(
              element["addr:housenumber"] ?? element["addr:housename"] ?? '')
          .trim();
    } else if (kind == ElementKind.address) {
      final value = [element['ref'], element['addr:flats']]
          .whereType<String>()
          .join(': ');
      label = loc.entranceX(value).trim();
    } else if (kind == ElementKind.entrance) {
      // entrance
      final value = [element['ref'], element['addr:flats']]
          .whereType<String>()
          .join(': ');
      label = loc.entranceX(value).trim();
    } else {
      label = element.typeAndName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(label, style: TextStyle(fontSize: 20.0)),
    );
  }

  @override
  void updateFromJson(Map<String, dynamic> data) {
    // TODO: implement updateFromJson
  }
}

class EntrancesModeCustom extends EntrancesModeDefinition {
  EntrancesModeCustom(super.ref, Map<String, dynamic> data) {
    // TODO
  }
}
