import 'dart:io';

import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/plugin_i18n.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Thrown only when loading a plugin. Prints the enclosed exception as well.
class PluginLoadException implements Exception {
  final String message;
  final Exception? parent;

  PluginLoadException(this.message, [this.parent]);

  @override
  String toString() {
    return parent == null ? message : "$message: $parent";
  }
}

/// Plugin metadata. Basically an identifier and a dictionary
/// from the bundled yaml file.
class PluginData {
  final String id;
  final Map<String, dynamic> data;

  const PluginData(this.id, this.data);

  String? get version => data['version'];

  Uri? get url => data.containsKey('url') ? Uri.tryParse(data['url']) : null;
}

/// Plugin metadata. Same as [PluginData], but with added service methods
/// for retrieving localizations and assets.
class Plugin extends PluginData {
  static final _logger = Logger('Plugin');

  final Directory directory;
  final PluginLocalizations _localizations;
  final Map<String, MultiIcon> _iconCache = {};

  Plugin(
      {required String id,
      required Map<String, dynamic> data,
      required this.directory})
      : _localizations = PluginLocalizations(directory),
        super(id, data);

  factory Plugin.fromData(PluginData pd, Directory directory) =>
      Plugin(id: pd.id, data: pd.data, directory: directory);

  // TODO

  String getName(BuildContext context) {
    final translated = translate(context, 'name');
    return translated == 'name' ? id : translated;
  }

  String translate(BuildContext context, String key,
      {Map<String, dynamic>? args}) {
    return _localizations.translate(context, key, args: args, data: data);
  }

  String translateN(BuildContext context, String key, int count,
      {Map<String, dynamic>? args}) {
    return _localizations.translateN(context, key, count,
        args: args, data: data);
  }

  File resolvePath(String name) {
    final file =  File('${directory.path}/$name');
    if (!file.absolute.path.startsWith(directory.absolute.path)) {
      throw ArgumentError('File "$name" is not inside the plugin directory');
    }
    return file;
  }

  MultiIcon loadIcon(String name, [String? tooltip]) {
    final cached = _iconCache[name];
    if (cached != null)
      return cached.tooltip == tooltip ? cached : cached.withTooltip(tooltip);

    final file = resolvePath('icons/$name');

    MultiIcon icon;
    if (file.existsSync()) {
      final data = file.readAsBytesSync();
      if (name.endsWith('.svg')) {
        icon = MultiIcon(svgData: data, tooltip: tooltip);
      } else if (name.endsWith('.si')) {
        icon = MultiIcon(siData: data, tooltip: tooltip);
      } else {
        icon = MultiIcon(imageData: data, tooltip: tooltip);
      }
    } else {
      _logger.warning('No icon in ${file.path}');
      icon = MultiIcon(fontIcon: Icons.question_mark, tooltip: tooltip);
    }

    _iconCache[name] = icon;
    return icon;
  }
}
