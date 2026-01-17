// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:country_coder/country_coder.dart';
import 'package:every_door/helpers/languages.dart';
import 'package:every_door/helpers/weekdays.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

/// Provides a locale, weekend information, and other information
/// about the country the mapper is editing in. It is not updated
/// automatically: call [CountryLocaleController.update] when you need it.
final countryLocaleProvider =
    NotifierProvider<CountryLocaleController, CountryLocaleData>(
        CountryLocaleController.new);
const _kDefaultWeekends = [5, 6];

class CountryLocaleData {
  final LatLng? location;
  final Locale? locale;
  final AppLocalizations? loc;
  final bool multiple;
  final int firstDayOfWeek;
  final List<int> weekends;

  CountryLocaleData({
    this.location,
    this.locale,
    this.loc,
    this.multiple = false,
    this.firstDayOfWeek = 0,
    this.weekends = _kDefaultWeekends,
  });

  CountryLocaleData update({
    LatLng? location,
    Locale? locale,
    AppLocalizations? loc,
    bool? multiple,
    int? firstDayOfWeek,
    List<int>? weekends,
  }) =>
      CountryLocaleData(
        location: location,
        locale: locale ?? this.locale,
        loc: loc ?? this.loc,
        multiple: multiple ?? this.multiple,
        firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
        weekends: weekends ?? this.weekends,
      );
}

class CountryLocaleController extends Notifier<CountryLocaleData> {
  static final _langData = LanguageData();

  @override
  CountryLocaleData build() => CountryLocaleData();

  Future<void> update(LatLng? location) async {
    location ??= ref.read(effectiveLocationProvider);

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

    if (newLocale != state.locale) {
      state = CountryLocaleData(
        location: location,
        locale: newLocale,
        multiple: newMultiple,
        firstDayOfWeek: newWeekDay,
        weekends: newWeekends,
        loc: newLocale == null
            ? null
            : await AppLocalizations.delegate.load(newLocale),
      );
    } else if (state.firstDayOfWeek != newWeekDay ||
        state.weekends != newWeekends) {
      state = state.update(
        location: location,
        firstDayOfWeek: newWeekDay,
        weekends: newWeekends,
      );
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
