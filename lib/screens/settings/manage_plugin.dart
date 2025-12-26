// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/plugin_manager.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/install_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagePluginPage extends ConsumerStatefulWidget {
  final Plugin plugin;

  const ManagePluginPage(this.plugin, {super.key});

  @override
  ConsumerState<ManagePluginPage> createState() => _ManagePluginPageState();
}

class _ManagePluginPageState extends ConsumerState<ManagePluginPage> {
  @override
  Widget build(BuildContext context) {
    final bool isActive =
        ref.watch(pluginManagerProvider).contains(widget.plugin.id);
    final app = ref
        .read(pluginManagerProvider.notifier)
        .createContext(widget.plugin, () {
      if (context.mounted) {
        setState(() {});
      }
    });
    final customSettings =
        widget.plugin.instance?.buildSettingsPane(app, context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && customSettings != null) {
          ref.read(pluginManagerProvider.notifier).reloadPlugin(widget.plugin);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.plugin.translate(context, 'name')),
        ),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text('Enable'),
              value: isActive,
              onChanged: (newValue) {
                ref
                    .read(pluginManagerProvider.notifier)
                    .setStateAndSave(widget.plugin, newValue);
              },
            ),
            if (customSettings != null) customSettings,
            ListTile(
              title: Text('Delete'),
              textColor: Colors.red,
              onTap: () async {
                // Plugin deletion is easily reversible (by installing it anew),
                // so we don't ask the user again.
                await ref
                    .read(pluginRepositoryProvider.notifier)
                    .deletePlugin(widget.plugin.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            if (widget.plugin.url != null)
              ListTile(
                title: Text('Upgrade'),
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => InstallPluginPage(widget.plugin.url!),
                  ));
                },
              ),
            if (widget.plugin.intro != null)
              ListTile(
                title: Text('Show Intro'),
                onTap: () {
                  widget.plugin.showIntro(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
