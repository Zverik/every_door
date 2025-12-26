// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class LegendPane extends StatelessWidget {
  final LegendController _legend;

  LegendPane(this._legend, {super.key});

  @override
  Widget build(BuildContext context) {
    final legend = List.of(_legend.legend);
    if (legend.isEmpty) return Container();

    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10.0),
      constraints: BoxConstraints(minHeight: 150.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in legend)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.color != null)
                  Icon(Icons.circle, color: item.color, size: 20.0),
                if (item.icon != null) item.icon!.getWidget(icon: false, size: 20.0),
                SizedBox(width: 5.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(item.isOther ? loc.legendOther : item.label,
                        style: kFieldTextStyle),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
