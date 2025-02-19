import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final legendProvider =
    StateNotifierProvider<LegendController, List<LegendItem>>(
        (ref) => LegendController(ref));

class LegendItem {
  final Color color;
  final String label;

  LegendItem({required this.color, required this.label});
  LegendItem.other(this.label) : color = kLegendOtherColor;

  @override
  String toString() => 'LegendItem($color, "$label")';

  bool get isOther => color == kLegendOtherColor;
}

const kLegendOtherColor = Colors.black;
const kMaxLegendItems = 6;

class LegendController extends StateNotifier<List<LegendItem>> {
  final Ref _ref;
  Map<String, LegendItem?> _legendMap = {};
  final Map<String, int> _prevColors = {};
  final Map<String, int> _maxSeen = {};

  static const kLegendColors = [
    Color(0xfffd0f0b),
    Color(0xff1dd798),
    Color(0xfffbc74e),
    Color(0xfff807e7),
    Color(0xffc5bb0c),
    Color(0xffb9fb77),
    Color(0xfff76492),
    Color(0xff15f5ed),
    Color(0xffab3ded),
    Color(0xfffd7d0b),
    Color(0xff3eef24),
    Color(0xff4e5aef),
    Color(0xff9b7716),
  ];

  LegendController(this._ref) : super([]);

  Future updateLegend(List<OsmChange> amenities, {Locale? locale}) async {
    // Considering amenities are listed closest to farthest
    // TODO: run simultaneously to speed this up
    final typesMap = {for (final a in amenities) a: await _getLabel(a, locale)};

    // Make a map for types, limited to the number of colours.
    bool haveExtra = false;
    final typesCount = <String, int>{};
    for (final a in amenities) {
      final l = typesMap[a];
      if (l != null) {
        if (typesCount.length >= kMaxLegendItems &&
            !typesCount.containsKey(l)) {
          haveExtra = true;
          continue;
        }
        typesCount[l] = (typesCount[l] ?? 0) + 1;
      }
    }

    // Update number in maxSeen.
    typesCount.forEach((key, count) {
      if (count > (_maxSeen[key] ?? 0)) _maxSeen[key] = count;
    });

    // Sort by number of occurrences.
    final typesCountList = typesCount.entries.toList();
    typesCountList.sort((a, b) => b.value.compareTo(a.value));

    // First pass: set colors from previous used colors.
    final usedColors = <int>{};
    final typeToColor = <String, int>{};
    for (final t in typesCountList) {
      if (_prevColors.containsKey(t.key)) {
        final color = _prevColors[t.key]!;
        // It can happen that there are two legend items with the same color.
        if (!usedColors.contains(color)) {
          typeToColor[t.key] = _prevColors[t.key]!;
          usedColors.add(color);
        }
      }
    }

    // Second pass: set missing colors and build legend.
    final colorsPool = _makeColorsPool();
    colorsPool.removeWhere((color) => usedColors.contains(color));
    final newLegend = <LegendItem>[];
    for (final t in typesCountList) {
      int color;
      if (typeToColor.containsKey(t.key)) {
        color = typeToColor[t.key]!;
      } else {
        // Choose a color that's not been used or used by a type
        // not in current list and with minimum uses.
        color = colorsPool.isEmpty ? 0 : colorsPool.removeLast();
      }
      newLegend.add(LegendItem(color: kLegendColors[color], label: t.key));
      _prevColors[t.key] = color;
    }
    if (haveExtra) newLegend.add(LegendItem.other('Other'));

    final labelToLegend = {for (final l in newLegend) l.label: l};
    _legendMap = typesMap.map(
        (amenity, label) => MapEntry(amenity.databaseId, labelToLegend[label]));
    state = newLegend;
  }

  /// Prepares a list of colors. Reversed, so that one could use `removeLast()`.
  List<int> _makeColorsPool() {
    // Find number of usages for every color.
    final usedColorsCount = <int, int>{};
    _prevColors.forEach((key, color) {
      usedColorsCount[color] =
          (usedColorsCount[color] ?? 0) + (_maxSeen[key] ?? 1);
    });
    // Prepare list of colors never used.
    final neverUsedColors =
        List.generate(kLegendColors.length, (i) => kLegendColors.length - i - 1)
            .where((color) => !usedColorsCount.containsKey(color));
    // Return colors sorted in reversed order by number of usages.
    final usedList = usedColorsCount.entries.toList();
    usedList.sort((a, b) => b.value.compareTo(a.value));
    return usedList.map((e) => e.key).followedBy(neverUsedColors).toList();
  }

  Future<String?> _getLabel(OsmChange change, Locale? locale) async {
    final preset = await _ref
        .read(presetProvider)
        .getPresetForTags(change.getFullTags(true), locale: locale);
    if (preset != Preset.defaultPreset) return preset.name;
    final k = change.mainKey;
    return k == null ? null : '$k = ${change[k]}';
  }

  LegendItem? getLegendItem(OsmChange amenity) =>
      _legendMap[amenity.databaseId];
}
