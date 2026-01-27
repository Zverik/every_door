// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/plugins/bindings/widgets/nominatim.dart';
import 'package:every_door/widgets/map.dart';
import 'package:every_door/widgets/status_pane.dart';
import 'package:flutter/material.dart';

class NavigationPane extends StatefulWidget {
  const NavigationPane({super.key});

  @override
  State<NavigationPane> createState() => _NavigationPaneState();
}

class _NavigationPaneState extends State<NavigationPane> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomMap(
                allowRotation: false,
                onlyOSM: true,
                track: false,
                drawPinMarker: false,
                updateState: true,
              ),
              ApiStatusPane(),
            ],
          ),
        ),
        NominatimNavigator(),
      ],
    );
  }
}
