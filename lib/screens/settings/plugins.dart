// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/providers/plugin_manager.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/manage_plugin.dart';
import 'package:every_door/screens/settings/plugin_repo.dart';
import 'package:every_door/widgets/plugin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class PluginSettingsPage extends ConsumerStatefulWidget {
  const PluginSettingsPage({super.key});

  @override
  ConsumerState<PluginSettingsPage> createState() => _PluginSettingsPageState();
}

class _PluginSettingsPageState extends ConsumerState<PluginSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final plugins = ref.watch(pluginRepositoryProvider);
    ref.watch(pluginManagerProvider); // to update the panel

    Iterable<Widget> cards =
        plugins.where((p) => p.active).map((p) => PluginCard(
              plugin: p,
              short: true,
              actionText: loc.pluginsDisable.toUpperCase(),
              onMore: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ManagePluginPage(p),
                ));
              },
            ));

    final inactive = plugins.where((p) => !p.active);
    if (inactive.isNotEmpty) {
      cards = cards.followedBy([
        Container(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 32.0),
          child: Text(loc.pluginsDisabledHeader,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ]).followedBy(inactive.map((p) => PluginCard(
            plugin: p,
            actionText: loc.pluginsEnable.toUpperCase(),
            short: true,
            onMore: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ManagePluginPage(p),
              ));
            },
          )));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsPlugins),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PluginRepositoryPage(),
          ));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            SizedBox(height: 12.0),
            ...cards,
            SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}
