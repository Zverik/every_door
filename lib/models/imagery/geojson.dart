// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/models/imagery.dart';
import 'package:flutter/material.dart';
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