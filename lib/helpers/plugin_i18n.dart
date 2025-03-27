import 'dart:io';

import 'package:every_door/helpers/yaml_map.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

class PluginLocalizations {
  static final _logger = Logger('PluginLocalizations');

  final Map<Locale, Map<String, dynamic>> _translations = {};

  PluginLocalizations(Directory directory) {
    _loadTranslations(directory);
  }

  Future<void> _loadTranslations(Directory directory) async {
    final transDir = Directory('${directory.path}/langs');
    if (!await transDir.exists()) return;
    final kReLocale = RegExp(r'^(?:.*/)?([a-z]{2,3})(?:[_-](\w{2,5}))?\.yaml$');
    await for (final entry in transDir.list()) {
      if (entry is! File) continue;
      final m = kReLocale.matchAsPrefix(entry.path);
      if (m == null) continue;
      final String lang = m.group(1)!;
      final String? mod = m.group(2);
      final locale = mod != null && mod == mod.toUpperCase()
          ? Locale(lang, mod)
          : Locale.fromSubtags(languageCode: lang, scriptCode: mod);

      final metadataContents = await entry.readAsString();
      final yamlData = loadYamlNode(metadataContents);
      if (yamlData is! YamlMap) {
        _logger.warning('File ${entry.absolute} does not contain a map.');
        continue;
      }
      _translations[locale] = yamlData.toMap();
    }
  }

  Map<String, dynamic> _getTranslations(Locale locale) {
    // TODO: resolve locales
    return _translations[locale] ??
        _translations[Locale(locale.languageCode)] ??
        {};
  }

  String? _resolveKey(Map<String, dynamic> data, String key) {
    final parts = key.split('.');
    dynamic k = data;
    for (final p in parts) {
      if (k is! Map<String, dynamic>) return null;
      k = k[p];
      if (k == null) return null;
    }
    return k.toString();
  }

  String translate(BuildContext context, String key,
      {Map<String, dynamic>? args, Map<String, dynamic>? data}) {
    final locale = Localizations.localeOf(context);
    final trans = _getTranslations(locale);
    return trans[key] ??
        (data == null ? key : _resolveKey(data, key)) ??
        key; // TODO: args for resolved?
  }

  String translateN(BuildContext context, String key, int count,
      {Map<String, dynamic>? args, Map<String, dynamic>? data}) {
    return translate(context, key, args: args, data: data); // TODO
  }
}
