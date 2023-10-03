import 'dart:io';

import 'package:every_door/providers/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static final kLanguageNames = {
    Locale('ar'): 'اَلْعَرَبِيَّةُ',
    Locale('be'): 'Беларуская мова',
    Locale('ca'): 'Català',
    Locale('cs'): 'Čeština',
    Locale('da'): 'Dansk',
    Locale('de'): 'Deutsch',
    Locale('en'): 'English',
    Locale('en', 'GB'): 'English (Great Britain)',
    Locale('eo'): 'Esperanto',
    Locale('es'): 'Español',
    Locale('eu'): 'Euskara',
    Locale('fa'): 'فارسی',
    Locale('fi'): 'Suomi',
    Locale('fr'): 'Français',
    Locale('hr'): 'Hrvatski',
    Locale('hu'): 'Magyar nyelv',
    Locale('it'): 'Italiano',
    Locale('ja'): '日本語',
    Locale('ko'): '한국어',
    Locale('mr'): 'मराठी',
    Locale('nb'): 'Bokmål',
    Locale('nl'): 'Nederlands',
    Locale('pa'): 'ਪੰਜਾਬੀ',
    Locale('pa', 'PK'): 'پنجابی',
    Locale('pl'): 'Polski',
    Locale('pt'): 'Português',
    Locale('pt', 'BR'): 'Português do Brasil',
    Locale('ru'): 'Русский',
    Locale('sl'): 'Slovenščina',
    Locale('sv'): 'Svenska',
    Locale('th'): 'ภาษาไทย',
    Locale('tr'): 'Türkçe',
    Locale('uk'): 'Українська мова',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'): '汉语（简体）',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): '漢語（繁體）',
  };

  static const kSkipLocales = [
    Locale('zh'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final appLocale =
        ref.watch(languageProvider) ?? Localizations.localeOf(context);
    var supportedLocales = _getSupportedLocales(appLocale);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsLanguage)),
      body: ListView.separated(
        itemCount: supportedLocales.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(kLanguageNames[supportedLocales[index]] ??
              supportedLocales[index].toLanguageTag()),
          trailing:
              supportedLocales[index] == appLocale ? Icon(Icons.check) : null,
          onTap: () {
            ref.read(languageProvider.notifier).set(supportedLocales[index]);
          },
        ),
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }

  List<Locale> _getSupportedLocales(Locale appLocale) {
    final supportedLocales = List.of(AppLocalizations.supportedLocales
        .where((l) => !kSkipLocales.contains(l)));

    // Move EN locales on top of the list
    supportedLocales.sort((a, b) => (a.languageCode == 'en' ? 0 : 1)
        .compareTo(b.languageCode == 'en' ? 0 : 1));

    final deviceLocaleParts = Platform.localeName.split('.')[0].split('_');
    var deviceLocales = <Locale>[];
    switch (deviceLocaleParts.length) {
      case 1:
        deviceLocales.add(Locale(deviceLocaleParts[0]));
        break;
      case 2:
        // We can have en_GB and en for example
        deviceLocales.add(Locale(deviceLocaleParts[0], deviceLocaleParts[1]));
        deviceLocales.add(Locale(deviceLocaleParts[0]));
        break;
      case 3:
        // Locales with scriptCode has localeCode_scriptCode_countryCode
        // structure. e.g. "zh_Hans_CN"
        var languageCode = deviceLocaleParts[0];
        var scriptCode = deviceLocaleParts[1];
        deviceLocales.add(Locale.fromSubtags(
            languageCode: languageCode, scriptCode: scriptCode));
        break;
    }

    Locale? hintedLocale;
    for (var deviceLocale in deviceLocales) {
      if (!supportedLocales.contains(deviceLocale)) {
        continue;
      }

      if (deviceLocale != appLocale) {
        hintedLocale = deviceLocale;
      }

      // If device locale is supported but not the same as app locale we
      // shouldn't check more general locale (only languageCode)
      break;
    }

    if (hintedLocale != null && hintedLocale.languageCode != 'en')
      supportedLocales.insert(0, hintedLocale);

    return supportedLocales;
  }
}
