import 'dart:io' show Platform;
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/helpers/osm_oauth2_client.dart';
import 'package:every_door/private.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/micromapping.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/screens/settings/changes.dart';
import 'package:every_door/screens/settings/imagery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SettingsPage extends ConsumerWidget {
  final LatLng location;

  const SettingsPage(this.location);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = ref.watch(changesProvider);
    final osmData = ref.watch(osmDataProvider);
    final micromapping = ref.watch(micromappingProvider);
    final login = ref.watch(authProvider);
    final loc = AppLocalizations.of(context)!;
    final titlePadding = EdgeInsets.only(
      left: 15.0,
      right: 15.0,
      top: 6.0,
      bottom: 0.0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: SettingsList(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        sections: [
          SettingsSection(
            title: loc.settingsApiServer,
            titlePadding: titlePadding,
            tiles: [
              SettingsTile(
                title: loc.settingsLoginDetails,
                subtitle: login,
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
            title: loc.settingsDataManagement,
            titlePadding: titlePadding,
            tiles: [
              SettingsTile(
                title: loc.settingsPurgeData,
                trailing: osmData.length == 0
                    ? null
                    : Text(osmData.length.toString()),
                enabled: osmData.length > 0,
                onPressed: (_) {
                  ref.read(osmDataProvider).purgeData();
                },
              ),
              SettingsTile(
                title: loc.settingsUploads,
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
            title: loc.settingsPresentation,
            titlePadding: titlePadding,
            tiles: [
              SettingsTile.switchTile(
                title: loc.settingsMicromapping,
                subtitle: 'Instead of shops, you add benches and trees',
                enabled: false,
                onToggle: (value) {
                  ref.read(micromappingProvider.notifier).set(value);
                },
                switchValue: micromapping,
              ),
              SettingsTile(
                title: loc.settingsBackground,
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageryPage(location)),
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
