import 'package:every_door/providers/presets.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final languageProvider =
    NotifierProvider<LanguageController, Locale?>(LanguageController.new);

class LanguageController extends Notifier<Locale?> {
  static const kLocaleKey = 'stored_locale';
  static const kNull = '-';

  @override
  Locale? build() {
    ref.read(sharedPrefsProvider).whenData((prefs) {
      final l = prefs.getStringList(kLocaleKey);
      if (l != null) {
        state = Locale.fromSubtags(
          languageCode: l[0],
          countryCode: l[1] == kNull ? null : l[1],
          scriptCode: l[2] == kNull ? null : l[2],
        );
      }
    });
    return null;
  }

  Future<void> set(Locale? newValue) async {
    if (state != newValue) {
      state = newValue;
      final prefs = ref.read(sharedPrefsProvider).requireValue;
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
      ref.read(presetProvider).clearFieldCache();
    }
  }
}
