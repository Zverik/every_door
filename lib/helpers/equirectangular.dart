import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class Equirectangular extends Haversine {
  const Equirectangular();

  @override
  double distance(LatLng p1, LatLng p2) {
    final f1 = p1.latitudeInRad;
    final f2 = p2.latitudeInRad;
    final x = (p2.longitudeInRad - p1.longitudeInRad) * math.cos((f1 + f2) / 2);
    final y = f2 - f1;
    return math.sqrt(x*x + y*y) * earthRadius;
  }
}

class DistanceEquirectangular extends Distance {
  const DistanceEquirectangular({final bool roundResult = true})
    : super(roundResult: roundResult, calculator: const Equirectangular());
}