import 'package:every_door/helpers/legend.dart';
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

abstract class ClassicModeDefinition extends BaseModeDefinition {
  List<OsmChange> nearestPOI = [];

  ClassicModeDefinition(super.ref);

  ClassicModeDefinition.fromPlugin(EveryDoorApp plugin): this(plugin.ref);

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {}

  @override
  updateNearest(LatLngBounds bounds) async {
    nearestPOI = await super.getNearestChanges(bounds);
    notifyListeners();
  }

  void openEditor({
    required BuildContext context,
    OsmChange? element,
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PoiEditorPage(amenity: element),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget buildMarker(OsmChange element) {
    return ColoredMarker(
      color: kLegendOtherColor,
    );
  }
}
