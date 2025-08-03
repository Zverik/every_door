import 'package:flutter/material.dart';

class OverlayButtonWidget extends StatelessWidget {
  /// Padding for the button.
  final EdgeInsets? padding;

  /// To which corner of the map should the button be aligned.
  final Alignment alignment;

  /// Function to call when the button is pressed.
  final VoidCallback onPressed;

  /// Function to call on long tap.
  final VoidCallback? onLongPressed;

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
        padding: (padding ?? EdgeInsets.zero) +
            safePadding +
            EdgeInsets.symmetric(horizontal: 10.0),
        child: MapButton(
          icon: icon,
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
            EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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

class MapButton extends StatelessWidget {
  /// Function to call when the button is pressed.
  final VoidCallback onPressed;

  /// Function to call on long tap.
  final VoidCallback? onLongPressed;

  /// Icon to display.
  final IconData? icon;

  /// Widget to display when there's no icon.
  final Widget? child;

  /// Set to false to hide the button.
  final bool enabled;

  /// Tooltip and semantics message.
  final String? tooltip;

  const MapButton({
    super.key,
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

    final button = GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child ?? Icon(
            icon,
            size: 30.0,
            color: Colors.black54,
          ),
        ),
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
