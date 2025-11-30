import 'dart:io';

import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/plugin_i18n.dart';
import 'package:every_door/models/version.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

final kApiVersion = PluginVersion('1.1');

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
  final bool installed;
  final PluginVersion version;

  PluginData(this.id, this.data, {this.installed = true})
      : version = PluginVersion(data['version']);

  String get name => data['name'] ?? id;
  String get description => data['description'] ?? '';
  String? get author => data['author'];
  PluginVersionRange? get apiVersion =>
      data.containsKey('api') ? PluginVersionRange(data['api']) : null;

  Uri? get url =>
      data.containsKey('source') ? Uri.tryParse(data['source']) : null;
  Uri? get homepage =>
      data.containsKey('homepage') ? Uri.tryParse(data['homepage']) : null;

  MultiIcon? get icon => null;

  @override
  bool operator ==(Object other) => other is PluginData && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

typedef InstanceBuilder = Future<EveryDoorPlugin?> Function(Plugin);

/// Plugin metadata. Same as [PluginData], but with added service methods
/// for retrieving localizations and assets. Data read from the plugin
/// metadata is final, but the [active] flag can be changed in runtime.
/// Same with [instance]: it is initialized when the plugin is made active,
/// and reset when it is disabled.
class Plugin extends PluginData {
  static final _logger = Logger('Plugin');

  bool active;
  EveryDoorPlugin? instance;
  final Directory directory;
  final PluginLocalizations _localizations;
  final Map<String, MultiIcon> _iconCache = {};
  final InstanceBuilder? _instanceBuilder;

  Plugin({
    required String id,
    required Map<String, dynamic> data,
    required this.directory,
    InstanceBuilder? instanceBuilder,
  })  : _localizations = PluginLocalizations(directory, data),
        _instanceBuilder = instanceBuilder,
        active = false,
        super(id, data);

  factory Plugin.fromData(PluginData pd, Directory directory,
          {InstanceBuilder? instanceBuilder}) =>
      Plugin(
          id: pd.id,
          data: pd.data,
          directory: directory,
          instanceBuilder: instanceBuilder);

  String? get intro => data['intro'];

  @override
  MultiIcon? get icon =>
      data.containsKey('icon') ? loadIcon(data['icon']) : null;

  Future<EveryDoorPlugin?> instantiate() async => _instanceBuilder?.call(this);

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

  Future<void> showIntro(BuildContext context) async {
    final intro = this.intro;
    if (intro == null) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate(context, 'name')),
        content: SingleChildScrollView(
          child: MarkdownBlock(
            config: MarkdownConfig(
              configs: [
                LinkConfig(
                  onTap: (href) => launchUrl(Uri.parse(href),
                      mode: LaunchMode.externalApplication),
                ),
              ],
            ),
            data: translate(context, 'intro'),
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
