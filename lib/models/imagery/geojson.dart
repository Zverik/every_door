import 'package:every_door/models/imagery.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';

class GeoJsonImagery extends Imagery {
  final GeoJsonProvider source;

  GeoJsonImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required this.source,
  }) : super(overlay: true);

  @override
  Widget buildLayer({bool reset = false}) {
    return GeoJsonLayer(data: source);
  }

}