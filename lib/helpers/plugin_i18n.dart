import 'dart:io';

import 'package:every_door/helpers/yaml_map.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

/// Localizations wrapper for passing to various parts of code that need
/// only small parts of the metadata tree. For example, a tree preset
/// would need "preset.tree" branch for translations. This class allows
/// to hide the context.
class PluginLocalizationsBranch {
  final PluginLocalizations _localizations;
  final String _prefix;

  const PluginLocalizationsBranch(this._localizations, this._prefix);

  String translateCtx(BuildContext context, String key,
      {Map<String, dynamic>? args}) {
    final locale = Localizations.localeOf(context);
    return _localizations.translate(locale, '$_prefix.$key', args: args);
  }

  String translate(Locale locale, String key, {Map<String, dynamic>? args}) {
    return _localizations.translate(locale, '$_prefix.$key', args: args);
  }

  List<String> translateList(Locale locale, String key) {
    return _localizations.translateList(locale, '$_prefix.$key');
  }
}

class PluginLocalizations {
  static final _logger = Logger('PluginLocalizations');

  final Map<Locale, Map<String, dynamic>> _translations = {};
  final Map<String, dynamic> _base = {};

  PluginLocalizations(Directory directory, Map<String, dynamic> data) {
    _loadTranslations(directory);
    _loadBase(data);
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

  void _loadBase(Map<String, dynamic> data) {
    if (_base.isEmpty) _base.addAll(_copyStringKeys(data));
  }

  static const kCopyStringKeys = {
    'name',
    'label',
    'tooltip',
    'description',
    'placeholder',
  };
  static const kCopyStringLists = {'labels', 'terms'};

  Map<String, dynamic> _copyStringKeys(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    for (final e in data.entries) {
      if (e.value is String && kCopyStringKeys.contains(e.key)) {
        result[e.key] = e.value;
      } else if (e.value is List && kCopyStringLists.contains(e.key)) {
        final r2 = (e.value as List).whereType<String>();
        if (r2.isNotEmpty) result[e.key] = r2.toList();
      } else if (e.value is Map) {
        final r2 = _copyStringKeys(e.value);
        if (r2.isNotEmpty) result[e.key] = r2;
      }
    }
    return result;
  }

  Map<String, dynamic> _getTranslations(Locale locale) {
    // TODO: resolve locales
    return _translations[locale] ??
        _translations[Locale(locale.languageCode)] ??
        {};
  }

  String? _resolveKey(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) return data[key];
    final parts = key.split('.');
    dynamic k = data;
    for (final p in parts) {
      if (k is! Map<String, dynamic>) return null;
      k = k[p];
      if (k == null) return null;
    }
    return k.toString();
  }

  List<String>? _resolveKeyList(Map<String, dynamic> data, String key) {
    if (data.containsKey(key) && data[key] is List) {
      print('found list for $key: ${data[key]}');
      return (data[key] as List).whereType<String>().toList();
    }

    final parts = key.split('.');
    dynamic k = data;
    for (final p in parts) {
      if (k is! Map<String, dynamic>) return null;
      k = k[p];
      if (k == null) return null;
    }
    print('found $key: $k');
    if (k is List) return k.whereType<String>().toList();
    return null;
  }

  String translate(Locale locale, String key,
      {Map<String, dynamic>? args, Map<String, dynamic>? data}) {
    final trans = _getTranslations(locale);
    String result =
        _resolveKey(trans, key) ?? _resolveKey(data ?? _base, key) ?? key;
    if (args != null) {
      for (final e in args.entries) {
        result = result.replaceAll('{${e.key}}', e.value);
      }
    }
    return result;
  }

  List<String> translateList(Locale locale, String key,
      {Map<String, dynamic>? data}) {
    final trans = _getTranslations(locale);
    return _resolveKeyList(trans, key) ??
        _resolveKeyList(data ?? _base, key) ??
        [];
  }

  String translateN(Locale locale, String key, int count,
      {Map<String, dynamic>? args, Map<String, dynamic>? data}) {
    String result = translate(locale, key, args: args, data: data);
    // TODO: resolve 1, 2, many
    result = result.replaceAll('{count}', count.toString());
    return result;
  }
}
