// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:latlong2/latlong.dart';
import 'package:material_color_names/material_color_names.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

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

@Bind(bridge: true, implicitSupers: true)
abstract class MicromappingModeDefinition extends BaseModeDefinition {
  static const kMicroStuffInList = 24;

  bool enableZoomingIn = true;
  List<String> _defaultPresets = _kDefaultMicroPresets;
  late final LegendController legend;
  final PoiDescriber describer;

  MicromappingModeDefinition(super.ref) : describer = SimpleDescriber() {
    ourKinds = [ElementKind.micro];
    otherKinds = [ElementKind.amenity];
    legend = LegendController(getPreset);
    legend.addListener(notifyListeners);
  }

  MicromappingModeDefinition.fromPlugin(EveryDoorApp app) : this(app.ref);

  @override
  MultiIcon getIcon(BuildContext context, bool active) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon: active ? Icons.park : Icons.park_outlined,
      tooltip: loc.navMicromappingMode,
    );
  }

  Future<PresetLabel?> getPreset(Located change, Locale? locale) async {
    if (change is! OsmChange) return null;
    final preset = await ref
        .read(presetProvider)
        .getPresetForTags(change.getFullTags(true), locale: locale);
    // TODO: we also need a preset id to override icons and colors.
    if (preset != Preset.defaultPreset)
      return PresetLabel(preset.id, preset.name);
    final k = change.mainKey;
    return k == null
        ? null
        : PresetLabel('$k/${change[k]}', '$k = ${change[k]}');
  }

  void updateLegend(Locale locale) {
    legend.updateLegend(nearest.whereType<OsmChange>(), locale: locale);
  }

  @override
  updateNearest(LatLngBounds bounds) async {
    List<OsmChange> data = await super.getNearestChanges(bounds);

    // Keep other mode objects to show.
    final otherData =
        data.where((e) => otherKinds.any((k) => k.matchesChange(e))).toList();

    // Filter for amenities (or not amenities).
    // TODO: e.isNew and not micro/building/address/entrance
    data = data.where((e) => ourKinds.any((k) => k.matchesChange(e))).toList();

    // Sort by distance.
    const distance = DistanceEquirectangular();
    final LatLng location = ref.read(effectiveLocationProvider);
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    // Trim to 10-20 elements.
    if (data.length > kMicroStuffInList)
      data = data.sublist(0, kMicroStuffInList);

    // Update the map.
    nearest = data;
    other = otherData;
    notifyListeners();
  }

  Future<void> openEditor({
    required BuildContext context,
    Located? element,
    LatLng? location,
  }) async {
    if (element == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TypeChooserPage(
                  location: location,
                  kinds: ourKinds.first,
                  defaults: _defaultPresets,
                )),
      );
    } else if (element is OsmChange) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: element),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {
    readKindsFromJson(data);

    final presets = data['defaultPresets'];
    if (presets != null && presets is List<dynamic>) {
      _defaultPresets = presets.whereType<String>().toList();
    }

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

    final iconsInLegend = data['iconsInLegend'];
    if (iconsInLegend != null && iconsInLegend is bool) {
      legend.iconsInLegend = iconsInLegend;
    }
  }

  Widget buildMarker(int index, Located element, bool isZoomedIn) {
    final icon = legend.getLegendItem(element);
    if (isZoomedIn) {
      return NumberedMarker(
          index: index, color: icon?.color ?? kLegendOtherColor);
    } else {
      if (icon == null || icon.icon == null) {
        return ColoredMarker(
          isIncomplete: element is OsmChange &&
              ElementKind.needsInfo.matchesChange(element),
          color: icon?.color ?? kLegendOtherColor,
        );
      } else {
        return icon.icon?.getWidget(icon: false) ?? Container();
      }
    }
  }
}

class DefaultMicromappingModeDefinition extends MicromappingModeDefinition {
  DefaultMicromappingModeDefinition(super.ref);

  @override
  String get name => "micro";
}

class MicromappingModeCustom extends MicromappingModeDefinition {
  final String _name;
  MultiIcon? _iconActive;
  MultiIcon? _icon;

  MicromappingModeCustom({
    required Ref ref,
    required String name,
    required Map<String, dynamic> data,
    required Plugin plugin,
  })  : _name = name,
        super(ref) {
    // Both icons are considered optional.
    final tooltip = data['name'] ?? _name;
    if (data.containsKey('icon')) {
      _icon = plugin.loadIcon(data['icon']!, tooltip);
    }
    if (data.containsKey('iconActive')) {
      _iconActive = plugin.loadIcon(data['iconActive']!, tooltip);
    }

    updateFromJson(data, plugin);
  }

  @override
  MultiIcon getIcon(BuildContext context, bool active) {
    return (active ? _iconActive ?? _icon : _icon ?? _iconActive) ??
        super.getIcon(context, active);
  }

  @override
  String get name => _name;
}
