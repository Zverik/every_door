import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            Tooltip(
              message: loc.mapZoomIn,
              child: OutlinedButton(
                onPressed: () {
                  controller.move(
                    controller.camera.center,
                    controller.camera.zoom + 1,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    size: 30.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.5),
                  shape: CircleBorder(side: BorderSide()),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Tooltip(
              message: loc.mapZoomOut,
              child: OutlinedButton(
                onPressed: () {
                  controller.move(
                    controller.camera.center,
                    controller.camera.zoom - 1,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.remove,
                    size: 30.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.5),
                  shape: CircleBorder(side: BorderSide()),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
