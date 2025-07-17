import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/generated/l10n/app_localizations.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;

class CachesPage extends ConsumerStatefulWidget {
  const CachesPage({super.key});

  @override
  ConsumerState<CachesPage> createState() => _CachesPageState();
}

class _CachesPageState extends ConsumerState<CachesPage> {
  @override
  Widget build(BuildContext context) {
    final osmData = ref.watch(osmDataProvider);
    final purgeAll = osmData.obsoleteLength == 0;
    NumberFormat numFormat;
    try {
      numFormat = NumberFormat.compact(
          locale: Localizations.localeOf(context).toLanguageTag());
    } catch (e) {
      numFormat = NumberFormat.compact(locale: 'en');
    }
    final dataLength = numFormat.format(osmData.length);
    final obsoleteDataLength = numFormat.format(osmData.obsoleteLength);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsDataManagement),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(purgeAll
                ? loc.settingsPurgeAllData
                : loc.settingsPurgeData),
            trailing: Text(purgeAll ? dataLength : obsoleteDataLength),
            enabled: osmData.length > 0,
            onTap: () async {
              if (purgeAll) {
                final answer = await showOkCancelAlertDialog(
                  context: context,
                  title: loc.settingsPurgeDataTitle,
                  message: loc.settingsPurgeDataMessage,
                  isDestructiveAction: true,
                  okLabel: loc.buttonYes,
                  cancelLabel: loc.buttonNo,
                );
                if (answer != OkCancelResult.ok) return;
              }

              int count =
              await ref.read(osmDataProvider).purgeData(purgeAll);
              if (purgeAll) {
                // Also delete unmodified notes.
                count += await ref
                    .read(notesProvider)
                    .purgeNotes(DateTime.now());
                AlertController.show(loc.settingsPurgedAllTitle,
                    loc.settingsPurgedMessage(count), TypeAlert.success);
              } else {
                AlertController.show(loc.settingsPurgedObsoleteTitle,
                    loc.settingsPurgedMessage(count), TypeAlert.success);
              }
              ref.read(needMapUpdateProvider).trigger();
            },
          ),
          ListTile(
            title: Text(loc.settingsCacheTiles),
            trailing: Icon(Icons.navigate_next),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
