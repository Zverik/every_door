// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';

class ZoomButtonsWidget extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsets padding;

  const ZoomButtonsWidget({
    this.alignment = Alignment.bottomRight,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = MapController.of(context);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MapButton(
              icon: MultiIcon(fontIcon: Icons.add),
              tooltip: loc.mapZoomIn,
              onPressed: (_) {
                controller.move(
                  controller.camera.center,
                  controller.camera.zoom + 1,
                );
              },
            ),
            MapButton(
              icon: MultiIcon(fontIcon: Icons.remove),
              tooltip: loc.mapZoomOut,
              onPressed: (_) {
                controller.move(
                  controller.camera.center,
                  controller.camera.zoom - 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
