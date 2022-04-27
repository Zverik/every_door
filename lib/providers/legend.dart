import 'package:every_door/helpers/good_tags.dart';
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

  static const kLegendColors = [
    Color(0xff1b9e77),
    Color(0xffd95f02),
    Color(0xff7570b3),
    Color(0xffe7298a),
    Color(0xff66a61e),
    Color(0xffe6ab02),
  ];

  LegendController(this._ref) : super([]);

  Future updateLegend(List<OsmChange> amenities, {Locale? locale}) async {
    // TODO: run simultaneously
    // Considering amenities are listed closest to farthest
    final typesMap = {
      for (final a in amenities) a: await _getLabel(a.getFullTags(), locale)
    };

    // Make a map for types, limited to the number of colours.
    bool haveExtra = false;
    final typesCount = <String, int>{};
    for (final a in amenities) {
      final l = typesMap[a];
      if (l != null) {
        if (typesCount.length >= kLegendColors.length &&
            !typesCount.containsKey(l)) {
          haveExtra = true;
          continue;
        }
        typesCount[l] = (typesCount[l] ?? 0) + 1;
      }
    }

    // Sort by number of occurrences.
    final typesCountList = typesCount.entries.toList();
    typesCountList.sort((a, b) => b.value.compareTo(a.value));
    if (typesCountList.length > kLegendColors.length)
      typesCountList.removeRange(kLegendColors.length, typesCountList.length);

    final currentColors = {
      for (final l in state) l.label: kLegendColors.indexOf(l.color)
    };
    final typesToShow = typesCountList.map((e) => e.key).toSet();
    final missingColors = List.generate(kLegendColors.length, (i) => i)
        .where((i) => typesToShow.every((label) => currentColors[label] != i))
        .toList();
    // TODO: keep old colors which were used at some time

    final newLegend = <LegendItem>[];
    final usedColors = <int>{};
    for (final t in typesCountList) {
      int color;
      if (currentColors.containsKey(t.key)) {
        color = currentColors[t.key]!;
      } else if (missingColors.isNotEmpty) {
        color = missingColors.first;
        missingColors.removeAt(0);
      } else {
        color = 0; // In theory should not happen
      }
      newLegend.add(LegendItem(color: kLegendColors[color], label: t.key));
      usedColors.add(color);
    }
    if (haveExtra) newLegend.add(LegendItem.other('Other'));

    final labelToLegend = {for (final l in newLegend) l.label: l};
    _legendMap = typesMap.map(
        (amenity, label) => MapEntry(amenity.databaseId, labelToLegend[label]));
    state = newLegend;
  }

  Future<String?> _getLabel(Map<String, String> tags, Locale? locale) async {
    final preset =
        await _ref.read(presetProvider).getPresetForTags(tags, locale: locale);
    if (preset != Preset.defaultPreset) return preset.name;
    final k = getMainKey(tags);
    return k == null ? null : '$k = ${tags[k]}';
  }

  LegendItem? getLegendItem(OsmChange amenity) =>
      _legendMap[amenity.databaseId];
}
