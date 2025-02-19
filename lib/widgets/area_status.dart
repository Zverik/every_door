import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AreaStatusPanel extends ConsumerWidget {
  const AreaStatusPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusWatch = ref.watch(areaStatusProvider);
    if (statusWatch.hasError) return Container();

    final areaStatus = statusWatch.valueOrNull;
    final apiStatus = ref.watch(apiStatusProvider);
    if (areaStatus == null ||
        areaStatus == AreaStatus.fresh ||
        apiStatus != ApiStatus.idle) return Container();

    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        height: 50.0,
        color:
        areaStatus == AreaStatus.missing ? Colors.redAccent : Colors.yellow,
        child: Center(
          child: Text(
            areaStatus == AreaStatus.missing
                ? loc.messageNoData
                : loc.messageDataObsolete,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: areaStatus == AreaStatus.missing
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
      onTap: () {
        ref.read(uploaderProvider).download(context);
      },
    );
  }
}
