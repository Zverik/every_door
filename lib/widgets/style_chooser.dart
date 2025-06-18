import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class StyleChooserButton extends ConsumerStatefulWidget {
  final EdgeInsets padding;
  final String style;
  final Alignment alignment;
  final Function(String) onChange;
  final Function()? onLock;

  const StyleChooserButton({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.style,
    required this.onChange,
    this.onLock,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  ConsumerState<StyleChooserButton> createState() => _StyleChooserButtonState();
}

class _StyleChooserButtonState extends ConsumerState<StyleChooserButton> {
  bool isOpen = false;
  bool isDragging = false;

  static const kDrawingTools = [
    // bottom to top, left to right, 2 columns
    'road', 'track',
    'footway', 'path',
    'cycleway', 'power',
    'wall', 'fence',
    'stream', 'culvert',
  ];

  selectTool(String tool) {
    widget.onChange(tool);
    setState(() {
      isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final loc = AppLocalizations.of(context)!;
    final safePadding =
        MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0);
    const commonPadding =
        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0);

    // For the panel determine the global bottom padding.
    final gpb = context.globalPaintBounds ?? Rect.zero;
    final paddingBottom =
        gpb.isEmpty ? 50.0 : MediaQuery.of(context).size.height - gpb.bottom;

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
                  padding: EdgeInsets.only(
                      left: 10.0,
                      bottom: paddingBottom + commonPadding.bottom,
                      right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ResponsiveGridList(
                        listViewBuilderOptions: ListViewBuilderOptions(
                            reverse: true, shrinkWrap: true),
                        maxItemsPerRow: 4,
                        minItemWidth: 150,
                        children: [
                          for (final tool in kDrawingTools)
                            DragTarget(
                              builder: (BuildContext context,
                                  List<Object?> candidateData,
                                  List<dynamic> rejectedData) {
                                return GestureDetector(
                                  child: StylePill(
                                    style: tool,
                                    focused: candidateData.isNotEmpty,
                                  ),
                                  onTap: () {
                                    selectTool(tool);
                                  },
                                );
                              },
                              onAcceptWithDetails: (details) {
                                selectTool(tool);
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        textDirection:
                            leftHand ? TextDirection.rtl : TextDirection.ltr,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onLock != null && !isDragging)
                            RoundButton(
                              icon: MultiIcon(fontIcon: Icons.lock),
                              foreground: Colors.grey,
                              background: Colors.white,
                              onPressed: () {
                                if (widget.onLock != null) widget.onLock!();
                              },
                            ),
                          SizedBox(
                              width: widget.onLock == null || isDragging
                                  ? 100
                                  : 20),
                          DragTarget(
                            builder: (BuildContext context,
                                List<Object?> candidateData,
                                List<dynamic> rejectedData) {
                              return RoundButton(
                                icon: MultiIcon(
                                    fontIcon: kStyleIcons[kToolScribble] ??
                                        kUnknownStyleIcon),
                                foreground: Colors.black,
                                background: candidateData.isEmpty
                                    ? Colors.white
                                    : Colors.yellowAccent,
                                onPressed: () {
                                  selectTool(kToolScribble);
                                },
                              );
                            },
                            onAcceptWithDetails: (details) {
                              selectTool(kToolScribble);
                            },
                          ),
                          SizedBox(width: 20),
                          DragTarget(
                            builder: (BuildContext context,
                                List<Object?> candidateData,
                                List<dynamic> rejectedData) {
                              return RoundButton(
                                icon: MultiIcon(
                                    fontIcon: kStyleIcons[kToolEraser] ??
                                        kUnknownStyleIcon),
                                foreground: Colors.red,
                                background: candidateData.isEmpty
                                    ? Colors.white
                                    : Colors.yellowAccent,
                                onPressed: () {
                                  selectTool(kToolEraser);
                                },
                              );
                            },
                            onAcceptWithDetails: (details) {
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
          child: isOpen
              ? Container()
              : Draggable(
                  feedback: Container(),
                  data: 1,
                  onDraggableCanceled: (v, o) {
                    setState(() {
                      isOpen = false;
                    });
                  },
                  onDragStarted: () {
                    setState(() {
                      isOpen = true;
                      isDragging = true;
                    });
                  },
                  child: RoundButton(
                    icon: MultiIcon(
                        fontIcon:
                            kStyleIcons[widget.style] ?? kUnknownStyleIcon),
                    tooltip: loc.drawChangeTool,
                    onPressed: () {
                      setState(() {
                        isOpen = true;
                        isDragging = false;
                      });
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class StylePill extends StatelessWidget {
  final String style;
  final bool focused;

  const StylePill({super.key, required this.style, this.focused = false});

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
      case "culvert":
        return loc.drawCulvert;
      default:
        return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final drStyle = kTypeStyles[style] ?? kUnknownStyle;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: focused ? Colors.yellowAccent : Colors.white70,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: drStyle.color,
              borderRadius: BorderRadius.circular(45.0),
            ),
            child: Icon(
              kStyleIcons[style] ?? kUnknownStyleIcon,
              color: drStyle.casing,
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            getLocalizedStyle(loc),
            style: TextStyle(fontSize: kFieldFontSize),
            overflow: TextOverflow.clip, // does not work :(
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
          icon: MultiIcon(fontIcon: Icons.undo),
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

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
