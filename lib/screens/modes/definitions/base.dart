import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
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

  Future<List<OsmChange>> getNearestChanges(LatLngBounds bounds,
      {int maxCount = 200, bool filter = true}) async {
    final provider = ref.read(osmDataProvider);
    List<OsmChange> data = await provider.getElementsInBox(bounds);

    final LatLng location = bounds.center;
    const distance = DistanceEquirectangular();
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    return data.where((e) => !filter || isOurKind(e)).take(maxCount).toList();
  }

  Future<void> updateNearest(LatLngBounds bounds);

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
