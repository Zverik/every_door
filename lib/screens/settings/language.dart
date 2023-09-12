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
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(languageProvider);
    final supported = List.of(AppLocalizations.supportedLocales
        .where((l) => !kSkipLocales.contains(l)));
    supported.sort((a, b) => (a.languageCode == 'en' ? 0 : 1)
        .compareTo(b.languageCode == 'en' ? 0 : 1));

    final deviceLocale = Platform.localeName;
    final deviceLanguageCode = deviceLocale.split('_').first;
    final isSameLanguage = locale!.languageCode == deviceLanguageCode;

    if (!isSameLanguage && supported.contains(Locale(deviceLanguageCode)))
      supported.insert(0, Locale(deviceLanguageCode));

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsLanguage)),
      body: ListView.separated(
        itemCount: supported.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(kLanguageNames[supported[index]] ??
              supported[index].toLanguageTag()),
          trailing: supported[index] == locale ? Icon(Icons.check) : null,
          onTap: () {
            ref.read(languageProvider.notifier).set(supported[index]);
          },
        ),
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
