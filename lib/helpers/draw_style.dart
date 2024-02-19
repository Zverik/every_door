import 'package:flutter/material.dart';

class DrawingStyle {
  final Color color;
  final Color casing;
  final double stroke;
  final bool dashed;

  static const kDefaultStroke = 8.0;

  const DrawingStyle({
    required this.color,
    this.casing = Colors.black,
    this.stroke = kDefaultStroke,
    this.dashed = false,
  });

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
  "scribble": DrawingStyle(color: Colors.white, stroke: 4.0),
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
