import 'dart:io';

import 'package:every_door/providers/app_links_provider.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/settings/plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:logging/logging.dart';

final sharedFileProvider = Provider((ref) => SharedFileController(ref));

class SharedFileController {
  static final _logger = Logger('SharedFileController');
  final Ref _ref;

  SharedFileController(this._ref) {
    _initFileListener();
  }

  void _initFileListener() {
    ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _mediaReceived(value);
    }, onError: (err) {
      _logger.warning('Error receiving file intent: $err');
    });
  }

  void checkInitialMedia() {
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _mediaReceived(value);
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _mediaReceived(List<SharedMediaFile> files) async {
    final SharedMediaFile? firstOurFile = files
        .where((f) => f.type == SharedMediaType.file && f.path.endsWith('.edp'))
        .firstOrNull;

    if (firstOurFile == null) {
      _logger.info('Got files, but nothing matches: $files');
      return;
    }
    ;

    final file = File(firstOurFile.path);
    if (!await file.exists()) {
      _logger.warning('Shared file is missing: ${firstOurFile.path}');
    }

    final repo = _ref.read(pluginRepositoryProvider.notifier);
    final pluginDir = await repo.unpackAndDelete(file);
    // final tmpData = await repo.readPluginData(pluginDir);
    // TODO: navigate to the install page to confirm?
    await repo.installFromTmpDir(pluginDir);

    final navigatorKey = _ref.read(geoIntentProvider).navigatorKey;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PluginSettingsPage(),
      ),
    );
  }
}
