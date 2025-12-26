// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@Bind()
class LegendItem {
  final Color? color;
  final MultiIcon? icon;
  final String label;

  LegendItem({this.color, this.icon, required this.label});
  LegendItem.other(this.label)
      : color = kLegendOtherColor,
        icon = null;

  @override
  String toString() => 'LegendItem($color, $icon, "$label")';

  bool get isOther => color == kLegendOtherColor;
}

const kLegendOtherColor = Colors.black;
const kLegendNoColor = Colors.transparent;

@Bind()
class NamedColor extends Color {
  final String name;
  const NamedColor(this.name, super.value);
}

@Bind()
class PresetLabel {
  final String id;
  final String label;

  const PresetLabel(this.id, this.label);

  @override
  bool operator ==(Object other) =>
      other is PresetLabel && other.label == label && other.id == id;

  @override
  int get hashCode => Object.hash(id, label);
}

@Bind()
class LegendController extends ChangeNotifier {
  final Ref _ref;

  List<LegendItem> _legend = [];

  /// This maps [OsmChange.databaseId] to a color and a label, for
  /// drawing on the map. Use [getLegendItem] to access, changes
  /// right before the [state] does.
  Map<String, LegendItem?> _legendMap = {};

  /// Maps preset ids to colors. It collects
  /// all the colors that have been used in the legend, since the app
  /// start. New colors overwrite old. When plugins do not override this,
  /// all colors in the list are taken from [kLegendColors].
  final Map<String, Color> _prevColors = {};

  /// This map registers the maximum number of objects of each type
  /// we have seen on a single screen. Keys are preset ids.
  final Map<String, int> _maxSeen = {};

  /// Locked colors for some presets ids. Can be populated via [fixPreset] and
  /// cleared via [resetFixes].
  final Map<String, Color> _fixedColors = {};

  /// Locked icons (!) for some preset ids. Can be populated via [fixPreset] and
  /// cleared via [resetFixes].
  final Map<String, MultiIcon> _fixedIcons = {};

  /// If false, does not add presets with icons defined to the legend. See
  /// [fixPreset] for adding icons.
  bool iconsInLegend = true;

  static const kLegendColors = [
    NamedColor('red', 0xfffd0f0b),
    NamedColor('teal', 0xff1dd798),
    NamedColor('yellow', 0xfffbc74e),
    NamedColor('magenta', 0xfff807e7),
    NamedColor('olive', 0xffc5bb0c),
    NamedColor('green', 0xffb9fb77),
    NamedColor('pink', 0xfff76492),
    NamedColor('cyan', 0xff15f5ed),
    NamedColor('purple', 0xffab3ded),
    NamedColor('orange', 0xfffd7d0b),
    NamedColor('darkblue', 0xff4e5aef), // needs to be all lowercase
    NamedColor('brown', 0xff9b7716),
  ];

  LegendController(this._ref);

  void fixPreset(String preset, {Color? color, MultiIcon? icon}) {
    if (icon != null) {
      _fixedIcons[preset] = icon;
    } else if (color != null) {
      _fixedColors[preset] = color;
    } else {
      throw ArgumentError('Either a color or an icon should be not null.');
    }
  }

  void resetFixes() {
    _fixedColors.clear();
    _fixedIcons.clear();
  }

  /// Updates legend colors for [amenities]. The list should be ordered
  /// closest to farthest. The function tries to reuse colors.
  /// The [locale] is needed to translate labels.
  Future updateLegend(List<OsmChange> amenities,
      {Locale? locale, int maxItems = 6}) async {
    // First get labels for each of the amenities.
    // TODO: run simultaneously to speed this up
    final typesMap = <OsmChange, PresetLabel?>{
      for (final a in amenities) a: await _getPreset(a, locale)
    };

    // Count number of occurrences for labels. If we have [kMaxLegendItems]
    // different labels, mark that we [haveExtra].
    bool haveExtra = false;
    final typesCount = <PresetLabel, int>{};
    for (final a in amenities) {
      final PresetLabel? l = typesMap[a];
      if (l != null) {
        if (typesCount.length >= maxItems && !typesCount.containsKey(l)) {
          haveExtra = true;
        } else {
          typesCount[l] = (typesCount[l] ?? 0) + 1;
        }
      }
    }

    // Update the number in maxSeen.
    typesCount.forEach((key, count) {
      if (count > (_maxSeen[key.id] ?? 0)) _maxSeen[key.id] = count;
    });

    // Sort by number of occurrences, descending.
    final typesCountList = typesCount.entries.toList();
    typesCountList.sort((a, b) => b.value.compareTo(a.value));

    // First pass: set colors from overrides.
    final usedColors = <Color>{}; // tracking our color pool
    final typeToColor = <String, Color>{}; // pre-calculated colors
    for (final t in typesCountList) {
      if (_fixedIcons.containsKey(t.key.id)) {
        typeToColor[t.key.id] = kLegendNoColor;
      } else if (_fixedColors.containsKey(t.key.id)) {
        final color = _fixedColors[t.key.id]!;
        // We do not check for collisions here, that's on the plugin author.
        typeToColor[t.key.id] = color;
        usedColors.add(color);
      }
    }

    // Second pass: set colors from previous used colors.
    for (final t in typesCountList) {
      if (_prevColors.containsKey(t.key.id)) {
        final color = _prevColors[t.key.id]!;
        // It can happen that there are two legend items with the same color.
        if (!usedColors.contains(color)) {
          typeToColor[t.key.id] = color;
          usedColors.add(color);
        }
      }
    }

    // Third pass: set missing colors and build the legend.
    final List<Color> colorsPool = _makeColorsPool();
    colorsPool.removeWhere((color) => usedColors.contains(color));
    final newLegend = <LegendItem>[];
    for (final t in typesCountList) {
      // Iterating by decreasing number of visible objects.
      Color? color;
      MultiIcon? icon;
      if (_fixedIcons.containsKey(t.key.id)) {
        // The icon is fixed, skip coloring.
        icon = _fixedIcons[t.key.id];
      } else if (typeToColor.containsKey(t.key.id)) {
        // We have a color from a previous showing.
        color = typeToColor[t.key.id]!;
      } else {
        // Choose a color that's not been used or used by a type
        // not in current list and with minimum uses.
        color =
            colorsPool.isEmpty ? kLegendOtherColor : colorsPool.removeLast();
      }
      newLegend.add(LegendItem(color: color, icon: icon, label: t.key.label));
      if (color != null) _prevColors[t.key.id] = color;
    }
    if (haveExtra) newLegend.add(LegendItem.other('Other'));

    final labelToLegend = {for (final l in newLegend) l.label: l};
    _legendMap = typesMap.map((amenity, label) =>
        MapEntry(amenity.databaseId, labelToLegend[label?.label]));
    _legend = iconsInLegend
        ? newLegend
        : newLegend.where((l) => l.color != null).toList();

    notifyListeners();
  }

  /// Prepares a list of colors in order of decreasing usage in previous
  /// legends. This order enables us to use `removeLast()`.
  List<Color> _makeColorsPool() {
    // Find number of usages for every color.
    final usedColorsCount = <Color, int>{};
    _prevColors.forEach((key, color) {
      usedColorsCount[color] =
          (usedColorsCount[color] ?? 0) + (_maxSeen[key] ?? 1);
    });
    // Prepare list of colors never used.
    final Iterable<Color> neverUsedColors = kLegendColors.reversed
        .where((color) => !usedColorsCount.containsKey(color));
    // Return colors sorted in reversed order by number of usages.
    final usedList = usedColorsCount.entries.toList();
    usedList.sort((a, b) => b.value.compareTo(a.value));
    return usedList.map((e) => e.key).followedBy(neverUsedColors).toList();
  }

  /// Queries the preset database for the preset name, translated
  /// into [locale].
  Future<PresetLabel?> _getPreset(OsmChange change, Locale? locale) async {
    final preset = await _ref
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

  List<LegendItem> get legend => _legend;

  LegendItem? getLegendItem(OsmChange amenity) =>
      _legendMap[amenity.databaseId];
}
