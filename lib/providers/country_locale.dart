import 'package:country_coder/country_coder.dart';
import 'package:every_door/helpers/languages.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final countryLocaleProvider =
    ChangeNotifierProvider((ref) => CountryLocaleController(ref));

class CountryLocaleController extends ChangeNotifier {
  static final _langData = LanguageData();
  final Ref _ref;

  Locale? locale;
  AppLocalizations? loc;

  CountryLocaleController(this._ref);

  update(LatLng? location) async {
    location ??= _ref.read(effectiveLocationProvider);

    Locale? newLocale;
    if (location != null) {
      for (final l in _getLanguageKeysForLocation(location)) {
        if (AppLocalizations.delegate.isSupported(l)) {
          newLocale = l;
          break;
        }
      }
    }

    if (newLocale != locale) {
      locale = newLocale;
      loc = newLocale == null
          ? null
          : await AppLocalizations.delegate.load(newLocale);
      notifyListeners();
    }
  }

  Iterable<Locale> _getLanguageKeysForLocation(LatLng location) {
    final countries = CountryCoder.instance.load();
    final countryId = countries.regionsContaining(
        lat: location.latitude, lon: location.longitude);
    final langLists = countryId
        .map((c) => MapEntry(c.id, _langData.dataForCountry(c.id)))
        .where((list) => list.value.isNotEmpty)
        .toList();
    if (langLists.isEmpty) return const [];
    langLists.sort((a, b) => b.value.length.compareTo(a.value.length));
    final first = langLists.first;
    return first.value
        .expand((l) => [Locale(l.isoCode, first.key), Locale(l.isoCode)]);
  }
}
