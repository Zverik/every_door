import 'package:every_door/constants.dart';
import 'package:every_door/providers/legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegendPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legend = List.of(ref.watch(legendProvider));
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
                Icon(Icons.circle, color: item.color, size: 20.0),
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
