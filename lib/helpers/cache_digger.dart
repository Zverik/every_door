import 'dart:math' show Point;

class BaseTile extends Point<int> {
  final int? depth;

  const BaseTile(super.x, super.y, [this.depth]);

  BaseTile withDepth(int depth) => BaseTile(x, y, depth);
}

