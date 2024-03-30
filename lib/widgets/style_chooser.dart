import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

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

  selectTool(String tool) {
    widget.onChange(tool);
    setState(() {
      isOpen = false;
    });
  }

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
                  padding: safePadding +
                      EdgeInsets.only(left: 10.0, bottom: 120.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 500,
                        child: ResponsiveGridList(
                          listViewBuilderOptions:
                              ListViewBuilderOptions(reverse: true),
                          maxItemsPerRow: 2,
                          minItemWidth: 100,
                          // crossAxisCount: 2,
                          children: [
                            for (final tool in kDrawingTools)
                              GestureDetector(
                                child: StylePill(style: tool),
                                onTap: () {
                                  selectTool(tool);
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 100),
                          RoundButton(
                            icon: kStyleIcons[kToolScribble] ?? kUnknownStyleIcon,
                            foreground: Colors.black,
                            background: Colors.white,
                            onPressed: () {
                              selectTool(kToolScribble);
                            },
                          ),
                          SizedBox(width: 20),
                          RoundButton(
                            icon: kStyleIcons[kToolEraser] ?? kUnknownStyleIcon,
                            foreground: Colors.red,
                            background: Colors.white,
                            onPressed: () {
                              selectTool(kToolEraser);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: RoundButton(
            icon: kStyleIcons[widget.style] ?? kUnknownStyleIcon,
            tooltip: loc.drawChangeTool,
            onPressed: () {
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
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.fromBorderSide(BorderSide(color: Colors.black)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45.0),
              border: Border.fromBorderSide(BorderSide(color: Colors.black)),
            ),
            child: Icon(kStyleIcons[style] ?? kUnknownStyleIcon),
          ),
          SizedBox(width: 5.0),
          Text(
            getLocalizedStyle(loc),
            style: TextStyle(fontSize: kFieldFontSize),
          ),
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
          onPressed: onTap,
        ),
      ),
    );
  }
}
