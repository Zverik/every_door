// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

@Bind(bridge: true, implicitSupers: true)
abstract class ClassicModeDefinition extends BaseModeDefinition {
  ClassicModeDefinition(super.ref);

  ClassicModeDefinition.fromPlugin(EveryDoorApp app): this(app.ref);

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {}

  @override
  Future<void> openEditor({
    required BuildContext context,
    Located? element,
    LatLng? location,
  }) async {
    if (element == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TypeChooserPage(location: location),
          fullscreenDialog: true,
        ),
      );
    } else if (element is OsmChange) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: element),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget buildMarker(Located element) {
    return ColoredMarker(
      color: kLegendOtherColor,
    );
  }
}
