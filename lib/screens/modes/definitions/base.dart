import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

abstract class BaseModeDefinition extends ChangeNotifier {
  final Ref ref;
  final _buttons = <MapButton>[];
  final _overlays = <Imagery>[];

  BaseModeDefinition(this.ref);

  String get name;

  MultiIcon getIcon(BuildContext context, bool outlined);

  bool isOurKind(OsmChange element) => false;

  Iterable<Imagery> get overlays => _overlays;
  Iterable<MapButton> get buttons => _buttons;

  void addMapButton(MapButton button) {
    _buttons.add(button);
  }

  void removeMapButton(String id) {
    _buttons.removeWhere((b) => b.id == id);
  }
  
  void addOverlay(Imagery imagery) {
    _overlays.add(imagery);
  }

  Future<List<OsmChange>> getNearestChanges(
      {LatLng? forceLocation, int? forceRadius, int maxCount = 200}) async {
    final provider = ref.read(osmDataProvider);
    final LatLng location =
        forceLocation ?? ref.read(effectiveLocationProvider);
    final radius = forceRadius ?? kFarVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    const distance = DistanceEquirectangular();

    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    return data
        .where((e) => distance(location, e.location) <= radius)
        .where((e) => isOurKind(e))
        .take(maxCount)
        .toList();
  }

  Future<void> updateNearest();

  void updateFromJson(Map<String, dynamic> data, Plugin plugin);

  List<ElementKindImpl>? parseKinds(dynamic data) {
    List<ElementKindImpl> result = [];
    if (data is String) {
      result = [ElementKind.get(data)];
    } else if (data is List<dynamic>) {
      result = data.whereType<String>().map((s) => ElementKind.get(s)).toList();
    }
    result.removeWhere((k) => k == ElementKind.unknown);
    return result.isEmpty ? null : result;
  }

  List<Widget> mapLayers() => [];
}
