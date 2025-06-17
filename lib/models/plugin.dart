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

class PluginVersion {
  late final int? _major;
  late final int _minor;

  static final zero = PluginVersion('0');

  PluginVersion(dynamic version) {
    if (version is int) {
      _major = null;
      _minor = version;
    } else {
      final vs = version.toString();
      final p = vs.indexOf('.');
      if (p < 0) {
        _major = null;
        _minor = int.parse(vs);
      } else {
        _major = int.parse(vs.substring(0, p));
        _minor = int.parse(vs.substring(p + 1));
      }
    }
  }

  @override
  String toString() => _major == null ? _minor.toString() : '$_major.$_minor';

  @override
  bool operator ==(Object other) =>
      other is PluginVersion &&
      other._major == _major &&
      other._minor == _minor;

  bool operator <(PluginVersion other) {
    if (_major == null) return other._major != null || other._minor > _minor;
    if (other._major == null || other._major < _major) return false;
    return other._major > _major || other._minor > _minor;
  }

  bool operator >(PluginVersion other) {
    if (_major != null)
      return other._major == null ||
          other._major < _major ||
          (other._major == _major && other._minor < _minor);
    return other._major == null && other._minor < _minor;
  }

  bool fresherThan(PluginVersion? version) => version == null || this > version;

  @override
  int get hashCode => Object.hash(_major, _minor);
}

/// Plugin metadata. Basically an identifier and a dictionary
/// from the bundled yaml file.
class PluginData {
  final String id;
  final Map<String, dynamic> data;
  final bool installed;
  final PluginVersion version;

  PluginData(this.id, this.data, {this.installed = true})
      : version = PluginVersion(data['version']);

  String get name => data['name'] ?? id;
  String get description => data['description'] ?? '';
  String? get author => data['author'];

  Uri? get url =>
      data.containsKey('source') ? Uri.tryParse(data['source']) : null;
  Uri? get homepage =>
      data.containsKey('homepage') ? Uri.tryParse(data['homepage']) : null;

  MultiIcon? get icon => null;
}

/// Plugin metadata for a record from an external plugin repository.
class RemotePlugin extends PluginData {
  RemotePlugin(Map<String, dynamic> data, {super.installed = false})
      : super(data['id'], data);

  int get downloads => data['downloads'] ?? 0;
  DateTime get updated => DateTime.parse(data['updated']);
  bool get experimental => data['experimental'] ?? false;
  bool get hidden => data['hidden'] ?? false;
  bool get local => data['country'] != null;

  @override
  Uri? get url => Uri.tryParse(data['download']);

  @override
  MultiIcon? get icon =>
      data.containsKey('icon') ? MultiIcon(imageUrl: data['icon']) : null;
}

/// Plugin metadata. Same as [PluginData], but with added service methods
/// for retrieving localizations and assets.
class Plugin extends PluginData {
  static final _logger = Logger('Plugin');

  bool active;
  final Directory directory;
  final PluginLocalizations _localizations;
  final Map<String, MultiIcon> _iconCache = {};

  Plugin(
      {required String id,
      required Map<String, dynamic> data,
      required this.directory})
      : _localizations = PluginLocalizations(directory, data),
        active = false,
        super(id, data);

  factory Plugin.fromData(PluginData pd, Directory directory) =>
      Plugin(id: pd.id, data: pd.data, directory: directory);

  @override
  MultiIcon? get icon =>
      data.containsKey('icon') ? loadIcon(data['icon']) : null;

  PluginLocalizationsBranch getLocalizationsBranch(String prefix) =>
      PluginLocalizationsBranch(_localizations, prefix);

  String translate(BuildContext context, String key,
      {Map<String, dynamic>? args}) {
    final locale = Localizations.localeOf(context);
    return _localizations.translate(locale, key, args: args, data: data);
  }

  File resolvePath(String name) {
    final file = File('${directory.path}/$name');
    if (!file.absolute.path.startsWith(directory.absolute.path)) {
      throw ArgumentError('File "$name" is not inside the plugin directory');
    }
    return file;
  }

  MultiIcon loadIcon(String name, [String? tooltip]) {
    final cached = _iconCache[name];
    if (cached != null)
      return cached.tooltip == tooltip ? cached : cached.withTooltip(tooltip);

    MultiIcon icon;

    if (name.startsWith('U+')) {
      final code = int.tryParse(name.substring(2), radix: 16);
      if (code != null) {
        icon = MultiIcon(emoji: String.fromCharCode(code));
      } else {
        _logger.severe('Wrong code point: $name');
        icon = MultiIcon(fontIcon: Icons.question_mark);
      }
    } else {
      final file = resolvePath('icons/$name');

      if (file.existsSync()) {
        final data = file.readAsBytesSync();
        if (name.endsWith('.svg')) {
          icon = MultiIcon(svgData: data);
        } else if (name.endsWith('.si')) {
          icon = MultiIcon(siData: data);
        } else {
          icon = MultiIcon(imageData: data);
        }
      } else {
        _logger.severe('No icon in ${file.path}');
        icon = MultiIcon(fontIcon: Icons.question_mark);
      }
    }

    if (tooltip != null) icon = icon.withTooltip(tooltip);
    _iconCache[name] = icon;
    return icon;
  }
}
