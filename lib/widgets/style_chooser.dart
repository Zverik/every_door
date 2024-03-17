import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';

class StyleChooserButton extends StatefulWidget {
  final EdgeInsets padding;
  final String style;
  final Alignment alignment;
  final Function(String) onChange;

  const StyleChooserButton({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.style,
    required this.onChange,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  State<StyleChooserButton> createState() => _StyleChooserButtonState();
}

class _StyleChooserButtonState extends State<StyleChooserButton> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final safePadding =
        MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0);
    const commonPadding =
        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0);

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: safePadding + commonPadding,
        child: PortalTarget(
          visible: isOpen,
          portalFollower: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: ModalBarrier(color: Colors.black38),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    isOpen = false;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    color: Colors.lightGreen,
                  ),
                ),
              ),
            ],
          ),
          child: RoundButton(
            icon: kStyleIcons[widget.style] ?? kUnknownStyleIcon,
            tooltip: loc.drawChangeTool,
            onTap: () {
              setState(() {
                isOpen = true;
              });
            },
          ),
        ),
      ),
    );
  }
}

class StylePill extends StatelessWidget {
  final String style;

  const StylePill({super.key, required this.style});

  String getLocalizedStyle(AppLocalizations loc) {
    switch (style) {
      case "scribble":
        return loc.drawScribble;
      case "eraser":
        return loc.drawEraser;
      case "road":
        return loc.drawRoad;
      case "track":
        return loc.drawTrack;
      case "footway":
        return loc.drawFootway;
      case "path":
        return loc.drawPath;
      case "cycleway":
        return loc.drawCycleway;
      case "cycleway_shared":
        return loc.drawCyclewayShared;
      case "wall":
        return loc.drawWall;
      case "fence":
        return loc.drawFence;
      case "power":
        return loc.drawPower;
      case "stream":
        return loc.drawStream;
      default:
        return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // TODO: make it round
    return Container(
      child: Column(
        children: [
          Container(
            child: Icon(kStyleIcons[style] ?? kUnknownStyleIcon),
          ),
          Text(getLocalizedStyle(loc)),
        ],
      ),
    );
  }
}

class UndoButton extends StatelessWidget {
  final Function() onTap;
  final Alignment alignment;

  const UndoButton({
    super.key,
    required this.onTap,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final safePadding =
        MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0);
    const commonPadding =
        EdgeInsets.symmetric(horizontal: 70.0, vertical: 25.0);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: safePadding + commonPadding,
        child: RoundButton(
          icon: Icons.undo,
          small: true,
          background: Theme.of(context).canvasColor,
          foreground: Theme.of(context).primaryColor,
          tooltip: loc.drawUndo,
          onTap: onTap,
        ),
      ),
    );
  }
}
