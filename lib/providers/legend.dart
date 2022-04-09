import 'package:every_door/models/amenity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final legendProvider =
    StateNotifierProvider<LegendController, List<LegendItem>>(
        (ref) => LegendController(ref));

class LegendItem {
  final Color color;
  final String tag;
  final String description;

  LegendItem({
    required this.color,
    required this.tag,
    required this.description,
  });
}

class LegendController extends StateNotifier<List<LegendItem>> {
  final Ref _ref;

  LegendController(this._ref) : super([]);

  updateLegend(List<OsmChange> amenities) {
    // TODO
  }
}
