import 'package:every_door/providers/plugin_manager.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/manage_plugin.dart';
import 'package:every_door/screens/settings/plugin_repo.dart';
import 'package:every_door/widgets/plugin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PluginSettingsPage extends ConsumerStatefulWidget {
  const PluginSettingsPage({super.key});

  @override
  ConsumerState<PluginSettingsPage> createState() => _PluginSettingsPageState();
}

class _PluginSettingsPageState extends ConsumerState<PluginSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(pluginManagerProvider);
    final plugins = ref.watch(pluginRepositoryProvider);
    Iterable<Widget> cards =
        plugins.where((p) => p.active).map((p) => PluginCard(
              plugin: p,
              actionText: 'DISABLE',
              onAction: () {
                ref
                    .read(pluginManagerProvider.notifier)
                    .setStateAndSave(p, false);
              },
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
          child: Text('Disabled', style: Theme.of(context).textTheme.bodySmall),
        ),
      ]).followedBy(inactive.map((p) => PluginCard(
            plugin: p,
            actionText: 'ENABLE',
            onAction: () {
              ref.read(pluginManagerProvider.notifier).setStateAndSave(p, true);
            },
            onMore: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ManagePluginPage(p),
              ));
            },
          )));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Plugins'),
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
          children: <Widget>[
                SizedBox(height: 12.0),
              ] +
              cards.toList(),
        ),
      ),
    );
  }
}
