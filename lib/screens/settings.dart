import 'package:every_door/constants.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/auth.dart';
import 'package:every_door/screens/settings/about.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/screens/settings/account_list.dart';
import 'package:every_door/screens/settings/caches.dart';
import 'package:every_door/screens/settings/changes.dart';
import 'package:every_door/screens/settings/changeset_pane.dart';
import 'package:every_door/screens/settings/imagery.dart';
import 'package:every_door/screens/settings/language.dart';
import 'package:every_door/screens/settings/plugins.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class SettingsPage extends ConsumerWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(authProvider)['osm']!.value?.displayName;
    final editorSettings = ref.watch(editorSettingsProvider);
    final forceLocation = ref.watch(forceLocationProvider);
    final hashtags = ref.watch(changesetTagsProvider).getHashtags();
    final loc = AppLocalizations.of(context)!;

    final haveChanges = ref.watch(changesProvider).length > 0;
    final haveNotes = ref.watch(notesProvider).haveChanges;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: SafeArea(
        top: false,
        child: SettingsList(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          sections: [
            SettingsSection(
              title: Text(loc.settingsApiServer),
              tiles: [
                SettingsTile(
                  title: Text(loc.settingsLoginDetails),
                  description: login != null ? Text(login) : null,
                  trailing: Icon(Icons.navigate_next),
                  onPressed: (context) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ref.watch(authProvider).length > 1
                                    ? AccountListPage()
                                    : AccountPage('osm')));
                  },
                ),
                SettingsTile(
                  title: Text(loc.settingsHashtags),
                  trailing: Icon(Icons.navigate_next),
                  description: hashtags.isEmpty ? null : Text(hashtags),
                  onPressed: (context) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangesetSettingsPage()));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text(loc.settingsDataManagement),
              tiles: [
                SettingsTile(
                  title: Text(loc.settingsUploads),
                  enabled: haveChanges || haveNotes,
                  trailing: haveChanges || haveNotes
                      ? Icon(Icons.navigate_next)
                      : null,
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeListPage()),
                    );
                  },
                ),
                SettingsTile(
                  title: Text(loc.settingsDataManagement),
                  trailing: Icon(Icons.navigate_next),
                  onPressed: (context) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CachesPage()),
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
                    ref
                        .read(editorSettingsProvider.notifier)
                        .setLeftHand(value);
                  },
                  initialValue: editorSettings.leftHand,
                ),
                SettingsTile(
                  title: Text(loc.settingsLanguage),
                  trailing: Row(children: const [
                    Icon(Icons.translate),
                    Icon(Icons.navigate_next),
                  ]),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LanguagePage()),
                    );
                  },
                ),
                SettingsTile(
                  title: Text(loc.settingsPlugins),
                  trailing: Icon(Icons.navigate_next),
                  onPressed: (context) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PluginSettingsPage(),
                          settings: RouteSettings(name: 'settings'),
                        ));
                  },
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
              ],
            ),
            if (defaultTargetPlatform == TargetPlatform.android)
              SettingsSection(
                title: Text(loc.settingsSystem),
                tiles: [
                  SettingsTile.switchTile(
                    title: Text(loc.settingsGoogle),
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
      ),
    );
  }
}
