import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_color_names/material_color_names.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const _kDefaultMicroPresets = [
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

abstract class MicromappingModeDefinition extends BaseModeDefinition {
  static const kMicroStuffInList = 24;

  List<OsmChange> nearestPOI = [];
  List<LatLng> otherPOI = [];
  bool enableZoomingIn = true;
  List<String> _defaultPresets = _kDefaultMicroPresets;
  List<ElementKindImpl> _kinds = [ElementKind.micro];
  List<ElementKindImpl> _otherKinds = [ElementKind.amenity];
  final LegendController legend;

  MicromappingModeDefinition(super.ref) : legend = LegendController(ref) {
    legend.addListener(notifyListeners);
  }

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon: !outlined ? Icons.park : Icons.park_outlined,
      tooltip: loc.navMicromappingMode,
    );
  }

  void updateLegend(BuildContext context) {
    final locale = Localizations.localeOf(context);
    legend.updateLegend(nearestPOI, locale: locale);
  }

  @override
  bool isOurKind(OsmChange element) =>
      _kinds.any((k) => k.matchesChange(element));

  @override
  updateNearest() async {
    List<OsmChange> data = await super.getNearestChanges();

    // Keep other mode objects to show.
    final otherData = data
        .where((e) => _otherKinds.any((k) => k.matchesChange(e)))
        .map((e) => e.location)
        .toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => isOurKind(e)).toList();

    // Sort by distance.
    const distance = DistanceEquirectangular();
    final LatLng location = ref.read(effectiveLocationProvider);
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

  Widget buildMarker(int index, OsmChange element, bool isZoomedIn);

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

    final markers = data['markers'];
    if (markers != null && markers is Map<String, dynamic>) {
      for (final entry in markers.entries) {
        final String preset = entry.key;
        final Map<String, dynamic> fix = entry.value;
        Color? color;
        if (fix.containsKey('color')) {
          final colorName = (fix['color'] as String).trim().toLowerCase();
          final foundColor = LegendController.kLegendColors
              .where((c) => c.name == 'ed$colorName')
              .firstOrNull;
          color = foundColor ?? colorFromString(colorName);
        }
        final icon =
            fix.containsKey('icon') ? plugin.loadIcon(fix['icon']) : null;
        legend.fixPreset(preset, color: color, icon: icon);
        // TODO: test and error reporting
      }
    }
  }
}

class DefaultMicromappingModeDefinition extends MicromappingModeDefinition {
  DefaultMicromappingModeDefinition(super.ref);

  @override
  String get name => "micro";

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon: !outlined ? Icons.park : Icons.park_outlined,
      tooltip: loc.navMicromappingMode,
    );
  }

  @override
  Widget buildMarker(int index, OsmChange element, bool isZoomedIn) {
    final icon = legend.getLegendItem(element);
    if (isZoomedIn) {
      return NumberedMarker(
          index: index, color: icon?.color ?? kLegendOtherColor);
    } else {
      if (icon == null || icon.icon == null) {
        return ColoredMarker(
          isIncomplete: ElementKind.needsInfo.matchesChange(element),
          color: icon?.color ?? kLegendOtherColor,
        );
      } else {
        return icon.icon?.getWidget(icon: false) ?? Container();
      }
    }
  }
}

class MicromappingModeCustom extends MicromappingModeDefinition {
  final String _name;
  MultiIcon? _icon;
  MultiIcon? _iconOutlined;

  MicromappingModeCustom({
    required ref,
    required String name,
    required Map<String, dynamic> data,
    required Plugin plugin,
  })  : _name = name,
        super(ref) {
    _kinds = (data['kinds'] as List<dynamic>?)
            ?.map((k) => ElementKind.get(k))
            .toList() ??
        [ElementKind.micro];

    final modeIconName = data['icon'];
    if (modeIconName != null) {
      _icon = plugin.loadIcon(modeIconName, data['name'] ?? _name);
      if (data.containsKey('iconOutlined')) {
        _iconOutlined =
            plugin.loadIcon(data['iconOutlined']!, data['name'] ?? _name);
      }
    }
  }

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) {
    return (!outlined ? _icon : _iconOutlined ?? _icon) ??
        super.getIcon(context, outlined);
  }

  @override
  String get name => _name;

  @override
  Widget buildMarker(int index, OsmChange element, bool isZoomedIn) {
    // TODO: implement buildMarker
    throw UnimplementedError();
  }

  @override
  Future<void> updateNearest() {
    // TODO: implement updateNearest
    throw UnimplementedError();
  }
}
