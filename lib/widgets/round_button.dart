// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/multi_icon.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final MultiIcon icon;
  final String? tooltip;
  final Function()? onPressed;
  final bool small;
  final Color? background;
  final Color? foreground;

  const RoundButton({
    required this.icon,
    this.tooltip,
    this.onPressed,
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
        child: icon.getWidget(
          size: small ? 20.0 : 30.0,
          color: foreground ?? Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: background,
        foregroundColor: foreground,
      ),
      onPressed: () {
        if (onPressed != null) onPressed!();
      },
    );

    return tooltip == null && icon.tooltip == null
        ? widget
        : Tooltip(message: tooltip ?? icon.tooltip, child: widget);
  }
}
