import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/filter.dart';

final poiFilterProvider = StateProvider<PoiFilter>((ref) => PoiFilter());
