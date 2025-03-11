import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/fields/helpers/qr_code.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/plugin_manager.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/install_plugin.dart';
import 'package:every_door/screens/settings/manage_plugin.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugins'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              Uri? detected;
              if (QrCodeScanner.kEnabled) {
                // We got a QR scanner? Then scan.
                detected = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => QrCodeScanner()));
              } else {
                // If we've got no scanner, just present a text input dialog.
                final List<String>? answer = await showTextInputDialog(
                  context: context,
                  title: 'Plugin URL',
                  textFields: [
                    DialogTextField(
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                    )
                  ],
                );
                if (answer != null &&
                    answer.isNotEmpty &&
                    answer.first.isNotEmpty) {
                  detected = Uri.tryParse(answer.first);
                }
              }

              if (detected != null && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => InstallPluginPage(detected!)),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: ref
            .watch(pluginRepositoryProvider)
            .map((p) => PluginRow(p))
            .toList(),
      ),
    );
  }
}

class PluginRow extends ConsumerWidget {
  final Plugin plugin;

  const PluginRow(this.plugin, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = ref.watch(pluginManagerProvider).contains(plugin);
    return ListTile(
      title: Text(plugin.getName(context)),
      trailing: Icon(Icons.navigate_next),
      leading: Switch(
        value: isActive,
        onChanged: (newValue) {
          ref
              .read(pluginManagerProvider.notifier)
              .setStateAndSave(plugin, newValue);
        },
      ),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ManagePluginPage(plugin),
        ));
      },
    );
  }
}
