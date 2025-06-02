import 'package:country_coder/country_coder.dart';
import 'package:every_door/helpers/languages.dart';
import 'package:every_door/helpers/weekdays.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final countryLocaleProvider =
    ChangeNotifierProvider((ref) => CountryLocaleController(ref));
const _kDefaultWeekends = [5, 6];

class CountryLocaleController extends ChangeNotifier {
  static final _langData = LanguageData();
  final Ref _ref;

  Locale? locale;
  AppLocalizations? loc;
  bool multiple = false;
  int firstDayOfWeek = 0;
  List<int> weekends = _kDefaultWeekends;

  CountryLocaleController(this._ref);

  update(LatLng? location) async {
    location ??= _ref.read(effectiveLocationProvider);

    Locale? newLocale;
    bool newMultiple = false;
    int newWeekDay = 0;
    List<int> newWeekends = _kDefaultWeekends;
    if (location != null) {
      newWeekDay = _getFirstWeekday(location);
      newWeekends = getWeekends(location);
      final localesToTest = _getLanguageKeysForLocation(location);
      // We get two for each language.
      newMultiple = localesToTest.length > 2;
      for (final l in localesToTest) {
        if (AppLocalizations.delegate.isSupported(l)) {
          newLocale = l;
          break;
        }
      }
    }

    if (newLocale != locale) {
      locale = newLocale;
      multiple = newMultiple;
      firstDayOfWeek = newWeekDay;
      weekends = newWeekends;
      loc = newLocale == null
          ? null
          : await AppLocalizations.delegate.load(newLocale);
      notifyListeners();
    } else if (firstDayOfWeek != newWeekDay || weekends != newWeekends) {
      firstDayOfWeek = newWeekDay;
      weekends = newWeekends;
      notifyListeners();
    }
  }

  Iterable<Locale> _getLanguageKeysForLocation(LatLng location) {
    final countries = CountryCoder.instance.load();
    final countryId = countries.regionsContaining(
        lat: location.latitude, lon: location.longitude);
    final langLists = countryId
        .map((c) => MapEntry(
              c.iso1A2?.toUpperCase() ?? c.id,
              _langData.dataForCountry(c.iso1A2?.toUpperCase() ?? c.id),
            ))
        .where((list) => list.value.isNotEmpty)
        .toList();
    if (langLists.isEmpty) return const [];
    langLists.sort((a, b) => b.value.length.compareTo(a.value.length));
    final first = langLists.first;
    return first.value
        .expand((l) => [Locale(l.isoCode, first.key), Locale(l.isoCode)]);
  }

  int _getFirstWeekday(LatLng location) {
    final countries = CountryCoder.instance.load();
    final countryId = countries.regionsContaining(
        lat: location.latitude, lon: location.longitude);
    final days = countryId
        .map((c) => kCountryWeekdays[c.iso1A2?.toUpperCase() ?? c.id])
        .whereType<int>();
    return days.firstOrNull ?? 0;
  }
}

List<int> getWeekends(LatLng? location) {
  if (location == null) return _kDefaultWeekends;
  final countries = CountryCoder.instance.load();
  final countryId = countries.regionsContaining(
      lat: location.latitude, lon: location.longitude);
  final days = countryId
      .map((c) => kCountryWeekends[c.iso1A2?.toUpperCase() ?? c.id])
      .whereType<List<int>>();
  return days.firstOrNull ?? _kDefaultWeekends;
}
