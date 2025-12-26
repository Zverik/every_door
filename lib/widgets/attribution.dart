// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/models/imagery.dart';
import 'package:flutter/material.dart';

class AttributionWidget extends StatelessWidget {
  final Imagery? imagery;

  const AttributionWidget(this.imagery, {super.key});

  @override
  Widget build(BuildContext context) {
    final src = imagery?.attribution;
    if (src == null) return Container();
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(src),
      ),
    );
  }
}
