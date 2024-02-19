// Port of simplify-js by Vladimir Agafonkin.
// https://github.com/mourner/simplify-js

import 'dart:ui' show Offset;

double _getSqDist(Offset p1, Offset p2) {
  final dx = p1.dx - p2.dx;
  final dy = p1.dy - p2.dy;
  return dx * dx + dy * dy;
}

double _getSqSeqDist(Offset p, Offset p1, Offset p2) {
  double x = p1.dx;
  double y = p1.dy;
  double dx = p2.dx - x;
  double dy = p2.dy - y;

  if (dx != 0 || dy != 0) {
    final t = ((p.dx - x) * dx + (p.dy - y) * dy) / (dx * dx + dy * dy);
    if (t > 1) {
      x = p2.dx;
      y = p2.dy;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.dx - x;
  dy = p.dy - y;

  return dx * dx + dy * dy;
}

List<Offset> _simplifyRadialDist(Iterable<Offset> points, double sqTolerance) {
  Offset prevPoint = points.first;
  final newPoints = <Offset>[];

  for (final point in points) {
    if (_getSqDist(point, prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }

  return newPoints;
}

void _simplifyDPStep(List<Offset> points, int first, int last,
    double sqTolerance, List<Offset> simplified) {
  double maxSqDist = sqTolerance;
  int index = 0;

  for (int i = first + 1; i < last; i++) {
    final sqDist = _getSqSeqDist(points[i], points[first], points[last]);
    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    // This happens only if the previous loop was successful in finding a point.
    if (index - first > 1)
      _simplifyDPStep(points, first, index, sqTolerance, simplified);
    simplified.add(points[index]);
    if (last - index > 1)
      _simplifyDPStep(points, index, last, sqTolerance, simplified);
  }
}

List<Offset> _simplifyDouglasPeucker(List<Offset> points, double sqTolerance) {
  int last = points.length - 1;
  final simplified = [points.first];
  _simplifyDPStep(points, 0, last, sqTolerance, simplified);
  simplified.add(points.last);
  return simplified;
}

List<Offset> simplifyOffsets(List<Offset> points, double tolerance, bool highestQuality) {
  if (points.length <= 2) return points;

  final sqTolerance = tolerance * tolerance;

  points = highestQuality ? points : _simplifyRadialDist(points, sqTolerance);
  points = _simplifyDouglasPeucker(points, sqTolerance);

  return points;
}