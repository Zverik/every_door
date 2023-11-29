import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PinMarker extends Marker {
  PinMarker(LatLng location, {Color color = Colors.black})
      : super(
          point: location,
          rotate: true,
          alignment: Alignment(0.0, -0.7),
          child: Icon(Icons.location_pin, color: color),
        );
}
