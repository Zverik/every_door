import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageController, Locale?>(
    (ref) => LanguageController(ref));

class LanguageController extends StateNotifier<Locale?> {
  static const kLocaleKey = 'stored_locale';
  static const kNull = '-';

  final Ref _ref;

  LanguageController(this._ref) : super(null) {
    loadState();
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final l = prefs.getStringList(kLocaleKey);
    if (l != null) {
      state = Locale.fromSubtags(
        languageCode: l[0],
        countryCode: l[1] == kNull ? null : l[1],
        scriptCode: l[2] == kNull ? null : l[2],
      );
    }
  }

  set(Locale? newValue) async {
    if (state != newValue) {
      state = newValue;
      final prefs = await SharedPreferences.getInstance();
      if (newValue == null) {
        await prefs.remove(kLocaleKey);
      } else {
        await prefs.setStringList(kLocaleKey, [
          newValue.languageCode,
          newValue.countryCode ?? kNull,
          newValue.scriptCode ?? kNull,
        ]);
      }
      // Clear caches.
      _ref.read(presetProvider).clearFieldCache();
    }
  }
}
