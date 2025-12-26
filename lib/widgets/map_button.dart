// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:flutter/material.dart';

class OverlayButtonWidget extends StatelessWidget {
  /// Padding for the button.
  final EdgeInsets? padding;

  /// To which corner of the map should the button be aligned.
  final Alignment alignment;

  /// Function to call when the button is pressed.
  final void Function(BuildContext) onPressed;

  /// Function to call on long tap.
  final void Function(BuildContext)? onLongPressed;

  /// Icon to display.
  final IconData icon;

  /// Set to false to hide the button.
  final bool enabled;

  /// Tooltip and semantics message.
  final String? tooltip;

  /// Add safe area to the bottom padding. Enable when the map is full-screen.
  final bool safeBottom;

  /// Add safe area to the right side padding.
  final bool safeRight;

  const OverlayButtonWidget({
    super.key,
    required this.alignment,
    this.padding,
    required this.onPressed,
    this.onLongPressed,
    required this.icon,
    this.enabled = true,
    this.tooltip,
    this.safeBottom = false,
    this.safeRight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return Container();

    EdgeInsets safePadding = MediaQuery.of(context).padding;
    safePadding = safePadding.copyWith(
      bottom: safeBottom ? null : 0.0,
      right: safeRight ? null : 0.0,
    );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: (padding ?? EdgeInsets.zero) + safePadding,
        child: MapButton(
          icon: MultiIcon(fontIcon: icon),
          enabled: enabled,
          tooltip: tooltip,
          onPressed: onPressed,
          onLongPressed: onLongPressed,
        ),
      ),
    );
  }
}

class MapButtonColumn extends StatelessWidget {
  /// Padding for the button.
  final EdgeInsets? padding;

  /// To which corner of the map should the button be aligned.
  final Alignment alignment;

  /// Add safe area to the bottom padding. Enable when the map is full-screen.
  final bool safeBottom;

  /// Add safe area to the right side padding.
  final bool safeRight;

  /// Enclosed button.
  final List<MapButton> buttons;

  const MapButtonColumn({
    super.key,
    required this.buttons,
    required this.alignment,
    this.padding,
    this.safeBottom = false,
    this.safeRight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty || buttons.every((b) => !b.enabled)) return Container();

    EdgeInsets safePadding = MediaQuery.of(context).padding;
    safePadding = safePadding.copyWith(
      bottom: safeBottom ? null : 0.0,
      right: safeRight ? null : 0.0,
      left: safeRight ? null : 0.0,
    );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: (padding ?? EdgeInsets.zero) +
            safePadding +
            EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons.where((b) => b.enabled).toList(),
          spacing: 10.0,
        ),
      ),
    );
  }
}

@Bind()
class MapButton extends StatelessWidget {
  /// An optional identifier to refer this button later.
  final String? id;

  /// Function to call when the button is pressed.
  final void Function(BuildContext) onPressed;

  /// Function to call on long tap.
  final void Function(BuildContext)? onLongPressed;

  /// Icon to display.
  final MultiIcon? icon;

  /// Widget to display when there's no icon.
  final Widget? child;

  /// Set to false to hide the button.
  final bool enabled;

  /// Tooltip and semantics message.
  final String? tooltip;

  const MapButton({
    super.key,
    this.id,
    required this.onPressed,
    this.onLongPressed,
    this.icon,
    this.child,
    this.enabled = true,
    this.tooltip,
  }) : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) {
    if (!enabled || (child == null && icon == null)) return Container();

    final button = OutlinedButton(
      onPressed: () => onPressed(context),
      onLongPress:
          onLongPressed == null ? null : () => onLongPressed?.call(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child ??
            icon!
                .getWidget(context: context, size: 30.0, color: Colors.black54),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        shape: CircleBorder(side: BorderSide()),
        padding: EdgeInsets.zero,
      ),
    );

    return tooltip == null
        ? button
        : Tooltip(
            message: tooltip,
            child: button,
          );
  }
}
