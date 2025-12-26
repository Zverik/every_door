// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:math' show Point;

class BaseTile extends Point<int> {
  final int? depth;

  const BaseTile(super.x, super.y, [this.depth]);

  BaseTile withDepth(int depth) => BaseTile(x, y, depth);
}

