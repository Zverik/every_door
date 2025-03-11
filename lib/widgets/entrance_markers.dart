import 'package:every_door/constants.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SizedMarker {
  final Widget child;

  final double width;

  final double height;

  final bool rotate;

  final Alignment alignment;

  const SizedMarker({
    required this.child,
    required this.width,
    required this.height,
    this.rotate = false,
    this.alignment = Alignment.center,
  });

  Marker buildMarker({Key? key, required LatLng point}) {
    return Marker(
      key: key,
      point: point,
      width: width,
      height: height,
      rotate: rotate,
      child: child,
      alignment: alignment,
    );
  }
}

class BuildingMarker extends SizedMarker {
  BuildingMarker({
    bool isComplete = false,
    required String label,
  }) : super(
          width: 120.0,
          height: 60.0,
          rotate: true,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isComplete
                      ? Colors.black
                      : Colors.black.withValues(alpha: 0.3),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(13.0),
                color: isComplete
                    ? Colors.yellow.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              constraints: BoxConstraints(minWidth: 35.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: kFieldFontSize),
              ),
            ),
          ),
        );
}

class AddressMarker extends SizedMarker {
  AddressMarker({required String label})
      : super(
          rotate: true,
          width: 90.0,
          height: 50.0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 3.0,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        );
}

class EntranceMarker extends SizedMarker {
  EntranceMarker({bool isComplete = false})
      : super(
          width: 50.0,
          height: 50.0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isComplete
                        ? Colors.black
                        : Colors.black.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(13.0),
                  color: isComplete
                      ? Colors.yellow.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.8),
                ),
                child: SizedBox(width: 20.0, height: 20.0),
              ),
            ),
          ),
        );
}

class IconMarker extends SizedMarker {
  IconMarker(MultiIcon icon)
      : super(
          width: 50.0,
          height: 50.0,
          child: Center(child: icon.getWidget(size: 30.0, icon: false)),
        );
}
