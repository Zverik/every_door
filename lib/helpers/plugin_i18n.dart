import 'dart:io';

import 'package:flutter/material.dart';

class PluginLocalizations {
  final Map<Locale, Map<String, dynamic>> _translations = {};

  PluginLocalizations(Directory directory) {
    _loadTranslations(directory);
  }

  Future<void> _loadTranslations(Directory directory) async {
    final transDir = Directory('${directory.path}/lang');
    if (!await transDir.exists()) return;
    await for (final entry in transDir.list()) {
      // TODO
    }
  }

  Map<String, dynamic> _getTranslations(Locale locale) {
    return {}; // TODO
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
        (data == null ? key : _resolveKey(data, key)) ?? key; // TODO: args for resolved?
  }

  String translateN(BuildContext context, String key, int count,
      {Map<String, dynamic>? args, Map<String, dynamic>? data}) {
    return translate(context, key, args: args, data: data); // TODO
  }

}