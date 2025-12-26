// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:flutter/material.dart';

@Bind()
class NumberedMarker extends StatelessWidget {
  final int? index;
  final Color color;

  const NumberedMarker({super.key, this.index, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final iconSize = 18.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(iconSize / 2),
          ),
          width: iconSize,
          height: iconSize,
        ),
        if ((index ?? 10) < 9)
          Container(
            padding: EdgeInsets.only(left: 1.0),
            child: Text(
              ((index ?? -1) + 1).toString(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: iconSize - 3.0,
              ),
            ),
          ),
      ],
    );
  }
}

@Bind()
class ColoredMarker extends StatelessWidget {
  final Color color;
  final bool isIncomplete;

  const ColoredMarker(
      {super.key, this.color = Colors.black, this.isIncomplete = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = 14.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(iconSize / 2),
          ),
          width: iconSize,
          height: iconSize,
        ),
        if (isIncomplete)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(iconSize / 6),
            ),
            width: iconSize / 3,
            height: iconSize / 3,
          ),
      ],
    );
  }
}
