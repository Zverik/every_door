import 'package:latlong2/latlong.dart' show LatLng;
import 'equirectangular.dart';
import 'dart:math' show Random;

List<LatLng> closestPair(Iterable<LatLng> locations) {
  if (locations.length < 2) return const [];
  if (locations.length == 2) return locations.toList();
  return _closestN2(locations);
  // return _closestLinear(locations);
}

double closestPairDistance(Iterable<LatLng> locations) {
  final distance = DistanceEquirectangular();
  final points = closestPair(locations);
  return points.length < 2 ? 0.0 : distance(points.first, points.last);
}

/// Simple O(n²) algorithm.
List<LatLng> _closestN2(Iterable<LatLng> locations) {
  final distance = DistanceEquirectangular();
  final points = locations.toList();
  double minDist = double.infinity;
  List<LatLng> result = [];
  for (int i = 0; i < points.length - 1; i++) {
    for (int j = i + 1; j < points.length; j++) {
      final d = distance(points[i], points[j]);
      if (d < minDist) {
        minDist = d;
        result = [points[i], points[j]];
      }
    }
  }
  return result;
}

class _GridCell {
  final int x;
  final int y;

  _GridCell.xy(this.x, this.y);
  _GridCell(double lat, double lon, double gridSize)
      : x = (lon / gridSize).round(),
        y = (lat / gridSize).round();

  @override
  int get hashCode => x.hashCode + y.hashCode;

  @override
  bool operator ==(Object other) =>
      other is _GridCell && other.x == x && other.y == y;

  List<_GridCell> neighbours() {
    return <_GridCell>[
      _GridCell.xy(x - 1, y - 1),
      _GridCell.xy(x, y - 1),
      _GridCell.xy(x + 1, y - 1),
      _GridCell.xy(x - 1, y),
      _GridCell.xy(x + 1, y),
      _GridCell.xy(x - 1, y + 1),
      _GridCell.xy(x, y + 1),
      _GridCell.xy(x + 1, y + 1),
    ];
  }
}

/// Linear algorithm as described in
/// https://en.wikipedia.org/wiki/Closest_pair_of_points_problem#Linear-time_randomized_algorithms
List<LatLng> _closestLinear(Iterable<LatLng> locations) {
  final distance = DistanceEquirectangular();
  final points = locations.toList();

  // 1. Select n random pairs and calc min distance. We will cheat a little.
  final rnd = Random();
  double gridSize = double.infinity;
  for (int i = 0; i < points.length; i++) {
    int j = rnd.nextInt(points.length - 1);
    if (j == i) j = points.length - 1;
    final d = distance(points[i], points[j]);
    if (d < gridSize) gridSize = d;
  }

  // 2. Build a hash table with locations rounded to gridSize.
  final Map<_GridCell, List<LatLng>> hashed = {};
  for (final p in locations) {
    final hash = _GridCell(p.latitude, p.longitude, gridSize);
    if (!hashed.containsKey(hash))
      hashed[hash] = [p];
    else
      hashed[hash]!.add(p);
  }

  // 3. For cells with many points in or around, find the minimum distance.
  double minDist = gridSize + 1e-6; // adding epsilon just in case
  List<LatLng> result = [];
  for (final entry in hashed.entries) {
    List<LatLng> around = List.of(entry.value);
    for (final h in entry.key.neighbours()) {
      if (hashed.containsKey(h))
        around.addAll(hashed[h]!);
      if (around.length >= 2) {
        for (int i = 0; i < around.length - 1; i++) {
          for (int j = i + 1; j < around.length; j++) {
            final d = distance(around[i], around[j]);
            if (d <= minDist) {
              minDist = d;
              result = [around[i], around[j]];
            }
          }
        }
      }
    }
  }

  // 4. Return the result.
  assert(result.isNotEmpty);
  return result;
}
