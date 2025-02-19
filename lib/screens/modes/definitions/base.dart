import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

abstract class BaseModeDefinition extends ChangeNotifier {
  final Ref ref;

  BaseModeDefinition(this.ref);

  String get name;
  MultiIcon get icon;
  MultiIcon get iconOutlined;

  bool isOurKind(OsmChange element) => false;

  Future<List<OsmChange>> getNearestChanges(
      {LatLng? forceLocation, int? forceRadius}) async {
    final provider = ref.read(osmDataProvider);
    final LatLng location =
        forceLocation ?? ref.read(effectiveLocationProvider);
    final radius = forceRadius ?? kFarVisibilityRadius;
    List<OsmChange> data = await provider.getElements(location, radius);
    const distance = DistanceEquirectangular();
    return data
        .where((e) => distance(location, e.location) <= radius)
        .where((e) => isOurKind(e))
        .toList();
  }

  Future<void> updateNearest();

  void updateFromJson(Map<String, dynamic> data);
}
