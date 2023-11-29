import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayButtonWidget extends ConsumerWidget {
  /// Padding for the button.
  final EdgeInsets padding;

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
    Stream<void>? rebuild,
    this.alignment = Alignment.topRight,
    required this.padding,
    required this.onPressed,
    this.onLongPressed,
    required this.icon,
    this.enabled = true,
    this.tooltip,
    this.safeBottom = false,
    this.safeRight = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return Container();

    final button = GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30.0,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );

    EdgeInsets safePadding = MediaQuery.of(context).padding;
    safePadding = safePadding.copyWith(
      bottom: safeBottom ? null : 0.0,
      right: safeRight ? null : 0.0,
    );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding + safePadding + EdgeInsets.symmetric(horizontal: 10.0),
        child: tooltip == null
            ? button
            : Tooltip(
                message: tooltip,
                child: button,
              ),
      ),
    );
  }
}
