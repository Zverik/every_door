import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/helpers/combo_page.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/screens/settings/changes.dart';
import 'package:every_door/screens/settings/imagery.dart';
import 'package:every_door/widgets/mode_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerWidget {
  final LatLng location;

  const SettingsPage(this.location);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = ref.watch(changesProvider);
    final osmData = ref.watch(osmDataProvider);
    final login = ref.watch(authProvider);
    final editorSettings = ref.watch(editorSettingsProvider);
    final loc = AppLocalizations.of(context)!;
    final dataLength = NumberFormat.compact(
            locale: Localizations.localeOf(context).toLanguageTag())
        .format(osmData.length);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: SettingsList(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        sections: [
          ModeSection(),
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
                title: Text(loc.settingsPurgeData),
                trailing: osmData.length == 0 ? null : Text(dataLength),
                enabled: osmData.length > 0,
                onPressed: (_) async {
                  final count = await ref.read(osmDataProvider).purgeData();
                  AlertController.show('Obsolete Data',
                      'Purged $count obsolete elements.', TypeAlert.success);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsUploads),
                enabled: changes.length > 0,
                trailing: changes.length == 0
                    ? null
                    : Text(changes.length.toString()),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeListPage()),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(loc.settingsPresentation),
            tiles: [
              SettingsTile(
                title: Text(loc.settingsBackground),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageryPage(location)),
                  );
                },
              ),
              SettingsTile.switchTile(
                title: Text('Prefer "contact:" prefix'),
                onToggle: (value) {
                  ref
                      .read(editorSettingsProvider.notifier)
                      .setPreferContact(value);
                },
                initialValue: editorSettings.preferContact,
              ),
              SettingsTile.switchTile(
                title: Text('Fix Numeric Keyboard'),
                onToggle: (value) {
                  ref
                      .read(editorSettingsProvider.notifier)
                      .setFixNumKeyboard(value);
                },
                initialValue: editorSettings.fixNumKeyboard,
              ),
              SettingsTile(
                title: Text('Default Payment Cards'),
                value: Text(editorSettings.defaultPayment.join(', ')),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) async {
                  final locale = Localizations.localeOf(context);
                  final combo = await ref.read(presetProvider).getField('payment_multi', locale);
                  final List<String>? newValues = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComboChooserPage(
                        combo as ComboPresetField,
                        editorSettings.defaultPayment,
                      ),
                    ),
                  );
                  if (newValues != null && newValues.isNotEmpty) {
                    ref.read(editorSettingsProvider.notifier).setDefaultPayment(newValues);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
