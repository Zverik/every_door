import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/fields/helpers/qr_code.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/edpr.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/install_plugin.dart';
import 'package:every_door/widgets/plugin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PluginRepositoryPage extends ConsumerStatefulWidget {
  const PluginRepositoryPage({super.key});

  @override
  ConsumerState<PluginRepositoryPage> createState() =>
      _PluginRepositoryPageState();
}

class _PluginRepositoryPageState extends ConsumerState<PluginRepositoryPage> {
  late final TextEditingController _controller;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _installFromQrCode() async {
    final nav = Navigator.of(context);

    Uri? detected;
    if (QrCodeScanner.kEnabled) {
      // We got a QR scanner? Then scan.
      detected = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrCodeScanner(resolveRedirects: false),
          ));
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
      if (answer != null && answer.isNotEmpty && answer.first.isNotEmpty) {
        detected = Uri.tryParse(answer.first);
      }
    }

    if (detected != null && nav.mounted) {
      nav.push(
        MaterialPageRoute(builder: (_) => InstallPluginPage(detected!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<RemotePlugin>> plugins = ref.watch(edprProvider);

    final Map<String, PluginVersion> installed = Map.fromEntries(ref
        .read(pluginRepositoryProvider)
        .map((p) => MapEntry(p.id, p.version)));

    List<Widget> items;
    if (plugins.isLoading) {
      items = [
        CircularProgressIndicator(),
        Text('Loading plugin list...'),
      ];
    } else if (plugins.hasError) {
      items = [
        Text('Error loading plugins: ${plugins.error}'),
      ];
    } else {
      final list = List<RemotePlugin>.of(plugins.value ?? []);
      if (_filter.isNotEmpty) {
        final f = _filter.toLowerCase();
        print('Filtering by $f');
        list.removeWhere((p) =>
            !p.name.toLowerCase().contains(f) &&
            !p.id.toLowerCase().contains(f));
      }
      list.sort((a, b) => b.downloads.compareTo(a.downloads));
      items = list
              .map((p) => PluginCard(
                    plugin: p,
                    onMore: () {},
                    actionText: installed.containsKey(p.id)
                        ? p.version.fresherThan(installed[p.id])
                            ? 'UPDATE'
                            : null
                        : 'INSTALL',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => InstallPluginPage(p.url!)),
                      );
                    },
                  ))
              .toList() ??
          [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin Repository'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: _installFromQrCode,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(edprProvider);
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _filter = '';
                            });
                          },
                        ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filter = value.trim();
                  });
                },
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}
