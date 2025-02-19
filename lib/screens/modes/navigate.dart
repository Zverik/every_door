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
    return Stack(
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
    );
  }
}
