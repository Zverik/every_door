import 'package:every_door/helpers/equirectangular.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class LocationObject<T> {
  final LatLng location;
  final T value;

  const LocationObject(this.location, this.value);

  @override
  String toString() => 'LocObj($location, $value)';
}

class LocationObjectSet<T> {
  final _objects = <LocationObject<T>>[];

  LocationObjectSet([Iterable<LocationObject<T>>? initList]) {
    if (initList != null) addAll(initList);
  }

  add(LatLng location, T value) {
    _objects.add(LocationObject(location, value));
  }

  addAll(Iterable<LocationObject<T>> objects) {
    _objects.addAll(objects);
  }

  sortByDistance(LatLng location, {bool unique = false}) {
    if (_objects.length <= 1) return;

    const distance = DistanceEquirectangular();
    _objects.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    if (unique) {
      final newList = <LocationObject<T>>[];
      final seen = <T>{};
      for (final obj in _objects) {
        if (!seen.contains(obj.value)) {
          newList.add(obj);
          seen.add(obj.value);
        }
      }
      _objects.clear();
      _objects.addAll(newList);
    }
  }

  List<T> take(int count) => _objects.take(count).map((o) => o.value).toList();
}
