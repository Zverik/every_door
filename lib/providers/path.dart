import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final pathProvider = NotifierProvider<PathController, List<LatLng>>(
    PathController.new);

class PathController extends Notifier<List<LatLng>> {
  static const kPathKey = 'path';
  static const kBreakInterval = Duration(minutes: 20);
  static const kBreakDistance = 200; // meters
  static const kMaxPoints = 1000;

  DateTime? _lastUpdate;
  bool loaded = false;

  @override
  List<LatLng> build() {
    ref.listen(geolocationProvider, (_, pos) {
      if (pos != null) updateLocation(pos);
    });
    return [];
  }

  Future<void> updateLocation(LatLng pos, [DateTime? dt]) async {
    dt ??= DateTime.now();
    List<LatLng> newPath = List.of(state);
    DateTime? lu = _lastUpdate;

    if (newPath.isEmpty && !loaded) (newPath, lu) = _loadPath();
    loaded = true;

    final distance = DistanceEquirectangular();
    if (lu == null || dt.difference(lu) > kBreakInterval) {
      newPath.clear();
    } else if (newPath.isNotEmpty &&
        distance(pos, newPath.last) > kBreakDistance) {
      newPath.clear();
    }
    newPath.add(pos.round());
    if (newPath.length > kMaxPoints) {
      newPath = newPath.sublist(newPath.length - kMaxPoints);
    }
    _lastUpdate = dt;
    state = newPath;
    _storePath();
  }

  (List<LatLng>, DateTime?) _loadPath() {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    if (prefs.containsKey(kPathKey)) {
      final data = prefs.getStringList(kPathKey);
      if (data != null) {
        final lu = DateTime.fromMillisecondsSinceEpoch(int.parse(data[0]));
        return (
          data
              .skip(1)
              .map((s) => s.split(',').map((ss) => double.parse(ss)).toList())
              .map((fl) => LatLng(fl[1], fl[0]))
              .toList(),
          lu
        );
      }
    }
    return (<LatLng>[], null);
  }

  Future<void> _storePath() async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    if (state.isEmpty) {
      await prefs.remove(kPathKey);
    } else {
      final lu = _lastUpdate?.millisecondsSinceEpoch.toString();
      if (lu == null) return;
      await prefs.setStringList(
        kPathKey,
        [lu] + state.map((ll) => '${ll.longitude},${ll.latitude}').toList(),
      );
    }
  }
}
