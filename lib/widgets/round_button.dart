import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final Function()? onTap;
  final bool small;
  final Color? background;
  final Color? foreground;

  const RoundButton({
    required this.icon,
    this.tooltip,
    this.onTap,
    this.small = false,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final widget = ElevatedButton(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0.0,
          vertical: small ? 10.0 : 15.0,
        ),
        child: Icon(icon, size: small ? 20.0 : 30.0),
      ),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: background,
        foregroundColor: foreground,
      ),
      onPressed: () {
        if (onTap != null) onTap!();
      },
    );

    return tooltip == null ? widget : Tooltip(message: tooltip, child: widget);
  }
}
