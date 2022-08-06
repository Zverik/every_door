import 'package:every_door/providers/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static final kLanguageNames = {
    Locale('ar'): 'اَلْعَرَبِيَّةُ',
    Locale('be'): 'Беларуская мова',
    Locale('da'): 'Dansk',
    Locale('de'): 'Deutsch',
    Locale('en'): 'English',
    Locale('es'): 'Español',
    Locale('eu'): 'Euskara',
    Locale('fa'): 'فارسی',
    Locale('fr'): 'Français',
    Locale('it'): 'Italiano',
    Locale('ja'): '日本語',
    Locale('ko'): '한국어',
    Locale('nb'): 'Bokmål',
    Locale('nl'): 'Nederlands',
    Locale('pl'): 'Polski',
    Locale('pt', 'BR'): 'Português do Brasil',
    Locale('ru'): 'Русский',
    Locale('sl'): 'Slovenščina',
    Locale('sv'): 'Svenska',
    Locale('tr'): 'Türkçe',
    Locale('uk'): 'Українська мова',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'): '汉语',
  };

  static const kSkipLocales = [
    Locale('pt'),
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
