import 'package:flutter/material.dart';

class DrawingStyle {
  final Color color;
  final bool thin;
  final bool dashed;

  static const kDefaultStroke = 8.0;

  const DrawingStyle({
    required this.color,
    this.thin = false,
    this.dashed = false,
  });

  double get stroke => thin ? kDefaultStroke / 2.0 : kDefaultStroke;

  Color get casing {
    // simplified luminance
    final lum = 0.2126 * (color.red / 255) + 0.7152 * (color.green / 255) + 0.0722 * (color.blue / 255);
    return lum > 0.4 ? Colors.black : Colors.white;
  }

  @override
  bool operator ==(Object other) {
    if (other is! DrawingStyle) return false;
    return color == other.color &&
        stroke < kDefaultStroke == other.stroke < kDefaultStroke &&
        dashed == other.dashed;
  }

  @override
  int get hashCode => Object.hash(color, stroke, dashed);
}

const kTypeStyles = <String, DrawingStyle>{
  "scribble": DrawingStyle(color: Colors.white, thin: true),
  "eraser": DrawingStyle(color: Colors.black54),
  "road": DrawingStyle(color: Colors.white70),
  "track": DrawingStyle(color: Colors.white70, dashed: true),
  "footway": DrawingStyle(color: Colors.red),
  "path": DrawingStyle(color: Colors.red, dashed: true),
  "cycleway": DrawingStyle(color: Colors.purpleAccent),
  "cycleway_shared": DrawingStyle(color: Colors.purpleAccent, dashed: true),
  "wall": DrawingStyle(color: Colors.yellow),
  "fence": DrawingStyle(color: Colors.yellow, dashed: true),
  "power": DrawingStyle(color: Colors.orangeAccent),
  "stream": DrawingStyle(color: Colors.lightBlue),
  "drain": DrawingStyle(color: Colors.lightBlue, dashed: true),
};

final kTypeStylesReversed =
    kTypeStyles.map((key, value) => MapEntry(value, key));

const kUnknownStyle = DrawingStyle(color: Colors.grey);
const kToolEraser = "eraser";
const kToolScribble = "scribble";

const kStyleIcons = <String, IconData>{
  "eraser": Icons.cleaning_services,
  "scribble": Icons.draw,
  "road": Icons.edit_road,
  "track": Icons.edit_road,
  "footway": Icons.directions_walk,
  "path": Icons.directions_walk,
  "cycleway": Icons.directions_bike,
  "cycleway_shared": Icons.directions_bike,
  "wall": Icons.fence,
  "fence": Icons.fence,
  "power": Icons.power_input,
  "stream": Icons.water,
  "drain": Icons.water,
};

const kUnknownStyleIcon = Icons.line_axis;