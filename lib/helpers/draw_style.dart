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
