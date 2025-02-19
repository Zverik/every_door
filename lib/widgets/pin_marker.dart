import 'package:every_door/helpers/blend_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// This is the black pin in the current effective location.
/// Also used for the editor object location and for the map
/// chooser. Basically the marker in the center of a map.
class PinMarker extends Marker {
  PinMarker(LatLng location, {Color color = Colors.white, bool blend = true})
      : super(
          point: location,
          rotate: true,
          alignment: Alignment(0.0, -0.7),
          child: blend
              ? BlendMask(
                  blendMode: BlendMode.difference,
                  child: Icon(Icons.location_pin, color: color),
                )
              : Icon(Icons.location_pin, color: color),
        );
}
