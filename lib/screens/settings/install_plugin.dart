import 'dart:io';

import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class InstallPluginPage extends ConsumerStatefulWidget {
  /// An URI for the plugin. Can be either a direct URL for a file to download
  /// (should end with an .edp extension), or an Every Door-style link:
  /// https://every-door.app/plugin/id?url=<download url>&ref=<ref>&version=<version>&update=true
  /// Note than none of the query parameters are required.
  final Uri uri;

  const InstallPluginPage(this.uri, {super.key});

  @override
  ConsumerState<InstallPluginPage> createState() => _InstallPluginPageState();
}

/// This class parses a plugin download Uri into components.
class PluginUriData {
  late final String id;
  late final Uri? url;
  late final String? version;
  late final String? ref;
  late final bool update;

  PluginUriData(Uri uri) {
    if (uri.host == 'every-door.app') {
      // Parse the entire shebang.
      id = uri.path.split('/').last;
      if (id.length < 2) {
        throw ArgumentError('Identifier "$id" is too short in the URI $uri');
      }
      final args = uri.queryParameters;
      url = args.containsKey('url') ? Uri.parse(args['url']!) : null;
      version = args['version'];
      ref = args['ref'];
      update = args['update'] == 'true';
    } else if (uri.path.endsWith('.edp')) {
      // Direct link to a file.
      // We require the id to be equal to the file name.
      final fileName = uri.path.split('/').last;
      final lastDotPos = fileName.lastIndexOf('.');
      id = fileName.substring(0, lastDotPos);
      url = uri;
      version = null;
      ref = null;
      update = true;
    } else {
      throw ArgumentError(
          'The URI points neither to Every Door website, not to an edp file');
    }
  }
}

class _InstallPluginPageState extends ConsumerState<InstallPluginPage> {
  late final PluginUriData? _data;
  bool _agreed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    try {
      _data = PluginUriData(widget.uri);
    } catch (e) {
      _error = 'Failed to parse URI: $e';
    }
  }

  Future<void> _installPlugin() async {
    final data = _data;
    if (data == null) return;

    final repo = ref.read(pluginRepositoryProvider.notifier);

    final Plugin? installed = ref
        .read(pluginRepositoryProvider)
        .where((p) => p.id == data.id)
        .firstOrNull;

    if (installed == null || data.update) {
      if (data.url == null) {
        throw Exception(
            'No URL specified for installation of plugin "${data.id}"');
      }

      // Create a temporary file.
      final tmpDir = await getTemporaryDirectory();
      final File tmpPath = File('${tmpDir.path}/downloaded_plugin.zip');
      if (await tmpPath.exists()) await tmpPath.delete();

      // Download the file in chunks.
      var client = http.Client();
      try {
        var request = http.Request('GET', data.url!);
        var response = await client.send(request);
        final fileSize = ((response.contentLength ?? 0) / 1024 / 1024).round();
        if (fileSize > 100) {
          throw Exception(
              'Would not download a file bigger than 100 MB (got $fileSize)');
        }
        await for (final chunk in response.stream) {
          await tmpPath.writeAsBytes(chunk, mode: FileMode.append);
        }
      } finally {
        client.close();
        tmpPath.delete();
      }

      // Now unpack and install.
      final pluginDir = await repo.unpackAndDelete(tmpPath);
      final tmpData = await repo.readPluginData(pluginDir);
      if (tmpData.id != data.id) {
        throw Exception(
            'The URL implies plugin id "${data.id}", but it actually is "${tmpData.id}"');
      }

      // TODO: show and agree idk

      await repo.installFromTmpDir(pluginDir);
    } else {
      // TODO: update the currently installed plugin, and enable it.
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_error != null) {
      body = Center(
        child: Text(_error ?? 'error'),
      );
    } else if (!_agreed) {
      body = Center(
        child: Column(
          children: [
            Text('Install plugin from ${widget.uri}?'),
            TextButton(
              child: Text('YES'),
              onPressed: () {
                setState(() {
                  _agreed = true;
                });
                _installPlugin();
              },
            ),
          ],
        ),
      );
    } else {
      body = Text('Installed?');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin installation'),
      ),
      body: body,
    );
  }
}
