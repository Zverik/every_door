import 'dart:io';

import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstallPluginPage extends ConsumerStatefulWidget {
  /// An URI for the plugin. Can be either a direct URL for a file to download
  /// (should end with an .edp extension), or an Every Door-style link:
  /// https://plugins.every-door.app/i/id?url=<download url>&ref=<ref>&version=<version>&update=true
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
  late final PluginVersion? version;
  late final bool ask;

  PluginUriData(Uri uri) {
    final args = uri.queryParameters;
    if (uri.host == 'plugins.every-door.app') {
      String? v = args['version'];
      // Parse the entire shebang.
      if (args.containsKey('url')) {
        // Supplying a direct url to a package.
        url = Uri.parse(args['url']!);
        id = uri.path.split('/').last;
        ask = true;
      } else if (uri.path.endsWith('.edp')) {
        // Linking to a file on the server.
        url = uri;
        final idParts = uri.path.split('/').last.split('.');
        id = idParts.first;
        // Extract version from the file name like 'plugin_id.v1.2.edp'
        if (v == null && idParts.length >= 3 && idParts[1].startsWith('v')) {
          v = idParts[1].substring(1);
          if (idParts.length >= 4) v = v + '.' + idParts[2];
        }
        ask = false;
      } else {
        // Linking to a plugin id. Should not happen.
        id = uri.path.split('/').last;
        url = uri.replace(path: '/$id.edp');
        ask = true;
      }
      if (id.length < 2) {
        throw ArgumentError('Identifier "$id" is too short in the URI $uri');
      }

      version = v == null ? null : PluginVersion(v);
    } else if (uri.path.endsWith('.edp')) {
      // Direct link to a file.
      // We require the id to be equal to the file name.
      final fileName = uri.path.split('/').last;
      final lastDotPos = fileName.indexOf('.');
      id = fileName.substring(0, lastDotPos);
      url = uri;
      final String? v = args['version'];
      version = v == null ? null : PluginVersion(v);
      ask = false;
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
      if (!_data!.ask) {
        _agreed = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _wrapInstall();
        });
      }
    } on ArgumentError catch (e) {
      _error = 'Failed to parse URI: $e';
    } catch (e) {
      _error = 'Internal error while parsing: $e';
      rethrow;
    }
  }

  Future<void> _installPlugin() async {
    final data = _data;
    if (data == null) {
      throw Exception('Tried to install null data');
    }

    final repo = ref.read(pluginRepositoryProvider.notifier);

    final Plugin? installed = ref
        .read(pluginRepositoryProvider)
        .where((p) => p.id == data.id)
        .firstOrNull;

    if (installed == null ||
        ((data.version ?? PluginVersion.zero) > installed.version)) {
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
      }

      // Now unpack and install.
      final pluginDir = await repo.unpackAndDelete(tmpPath);
      final tmpData = await repo.readPluginData(pluginDir);
      if (tmpData.id != data.id) {
        throw Exception(
            'The URL implies plugin id "${data.id}", but it actually is "${tmpData.id}"');
      }
      final bundledUrl = tmpData.url;
      if (bundledUrl != null && bundledUrl != data.url) {
        throw Exception(
            'The plugin supplies URL different from ${data.url}: $bundledUrl');
      }

      // TODO: show and agree idk

      await repo.installFromTmpDir(pluginDir);
    } else {
      // TODO: update the currently installed plugin, and enable it.
      throw Exception(
          'The plugin has been already installed and of the latest version.');
    }

    if (mounted) {
      Navigator.of(context).popUntil((r) {
        return r.isFirst || r.settings.name == 'settings';
      });
    }
  }

  void _wrapInstall() async {
    try {
      await _installPlugin();
    } on Exception catch (e) {
      setState(() {
        _error = 'Installation error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    const kFontSize = 20.0;
    final loc = AppLocalizations.of(context)!;

    if (_error != null) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error ?? 'error',
            style: TextStyle(color: Colors.red, fontSize: kFontSize),
          ),
          SizedBox(height: kFontSize),
          Text(
            widget.uri.toString(),
            style: TextStyle(fontSize: kFontSize),
          ),
        ],
      );
    } else if (!_agreed) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.pluginsInstallQuestion(
                _data?.id ?? '', _data?.version ?? loc.pluginsUnknownVersion),
            style: TextStyle(fontSize: kFontSize),
          ),
          SizedBox(height: kFontSize),
          Text(
            loc.pluginsInstallSource(widget.uri.authority),
            style: TextStyle(fontSize: kFontSize),
          ),
          SizedBox(height: kFontSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text(loc.buttonYes.toUpperCase()),
                onPressed: () {
                  setState(() {
                    _agreed = true;
                  });
                  _wrapInstall();
                },
              ),
              SizedBox(width: 20.0),
              TextButton(
                child: Text(loc.buttonNo.toUpperCase()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: kFontSize),
          Text('Installing...', style: TextStyle(fontSize: kFontSize)),
          TextButton(
            child: Text('See logs'),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => LogDisplayPage(),
              ));
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.pluginsInstallation),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }
}
