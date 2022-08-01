import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/helpers/combo_page.dart';
import 'package:every_door/helpers/payment_tags.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/settings/about.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/screens/settings/changes.dart';
import 'package:every_door/screens/settings/imagery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osmData = ref.watch(osmDataProvider);
    final login = ref.watch(authProvider);
    final editorSettings = ref.watch(editorSettingsProvider);
    final forceLocation = ref.watch(forceLocationProvider);
    final loc = AppLocalizations.of(context)!;

    final haveChanges = ref.watch(changesProvider).length > 0;
    final haveNotes = ref.watch(notesProvider).haveChanges;

    final purgeAll = osmData.obsoleteLength == 0;
    final dataLength = NumberFormat.compact(
            locale: Localizations.localeOf(context).toLanguageTag())
        .format(osmData.length);
    final obsoleteDataLength = NumberFormat.compact(
            locale: Localizations.localeOf(context).toLanguageTag())
        .format(osmData.obsoleteLength);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: SettingsList(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        sections: [
          SettingsSection(
            title: Text(loc.settingsApiServer),
            tiles: [
              SettingsTile(
                title: Text(loc.settingsLoginDetails),
                description: Text(login ?? ''),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OsmAccountPage()));
                },
              )
            ],
          ),
          SettingsSection(
            title: Text(loc.settingsDataManagement),
            tiles: [
              SettingsTile(
                title: Text(loc.settingsUploads),
                enabled: haveChanges || haveNotes,
                trailing:
                    haveChanges || haveNotes ? Icon(Icons.navigate_next) : null,
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeListPage()),
                  );
                },
              ),
              SettingsTile(
                title: Text(purgeAll
                    ? loc.settingsPurgeAllData
                    : loc.settingsPurgeData),
                trailing: Text(purgeAll ? dataLength : obsoleteDataLength),
                enabled: osmData.length > 0,
                onPressed: (_) async {
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

                  final count =
                      await ref.read(osmDataProvider).purgeData(purgeAll);
                  if (purgeAll) {
                    AlertController.show(loc.settingsPurgedAllTitle,
                        loc.settingsPurgedMessage(count), TypeAlert.success);
                  } else {
                    AlertController.show(loc.settingsPurgedObsoleteTitle,
                        loc.settingsPurgedMessage(count), TypeAlert.success);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(loc.settingsPresentation),
            tiles: [
              SettingsTile(
                title: Text(loc.settingsBackground),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImageryPage()),
                  );
                },
              ),
              SettingsTile.switchTile(
                title: Text(loc.settingsLeftHand),
                onToggle: (value) {
                  ref.read(editorSettingsProvider.notifier).setLeftHand(value);
                },
                initialValue: editorSettings.leftHand,
              ),
            ],
          ),
          SettingsSection(
            title: Text(loc.settingsEditor),
            tiles: [
              SettingsTile.switchTile(
                title: Text(loc.settingsNumericKeyboard),
                onToggle: (value) {
                  ref
                      .read(editorSettingsProvider.notifier)
                      .setFixNumKeyboard(value);
                },
                initialValue: editorSettings.fixNumKeyboard,
              ),
              if (kShowContactSetting)
                SettingsTile.switchTile(
                  title: Text(loc.settingsPreferContact),
                  onToggle: (value) {
                    ref
                        .read(editorSettingsProvider.notifier)
                        .setPreferContact(value);
                  },
                  initialValue: editorSettings.preferContact,
                ),
              SettingsTile(
                title: Text(loc.settingsDefaultPayment),
                value: Text(editorSettings.defaultPayment.join(', ')),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) async {
                  final locale = Localizations.localeOf(context);
                  final navigator = Navigator.of(context);
                  final combo = await ref
                      .read(presetProvider)
                      .getField('payment_multi', locale);
                  if (combo is ComboPresetField) {
                    combo.options.removeWhere(
                        (element) => kNotCards.contains(element.value));
                  }
                  final List<String>? newValues = await navigator.push(
                    MaterialPageRoute(
                      builder: (context) => ComboChooserPage(
                        combo as ComboPresetField,
                        editorSettings.defaultPayment,
                      ),
                    ),
                  );
                  if (newValues != null && newValues.isNotEmpty) {
                    ref
                        .read(editorSettingsProvider.notifier)
                        .setDefaultPayment(newValues);
                  }
                },
              ),
            ],
          ),
          if (defaultTargetPlatform == TargetPlatform.android)
            SettingsSection(
              title: Text('System'),
              tiles: [
                SettingsTile.switchTile(
                  title: Text('Use Google-enhanced Positioning'),
                  initialValue: !forceLocation,
                  onToggle: (bool value) {
                    ref
                        .read(forceLocationProvider.notifier)
                        .set(!forceLocation);
                  },
                ),
              ],
            ),
          SettingsSection(
            title: Text(loc.settingsAbout),
            tiles: [
              SettingsTile(
                title: Text('${loc.settingsAbout} $kAppTitle $kAppVersion'),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
