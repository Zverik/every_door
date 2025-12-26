// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:flutter/foundation.dart';

class HoursParsingException implements Exception {
  final String message;

  const HoursParsingException(this.message);
}

const kDaysRangeClasses = <Type>[
  Weekdays,
  NumberedWeekday,
  SpecificDays,
  PublicHolidays,
];

const kDaysRangeParsers = <DaysRange? Function(String)>[
  Weekdays.parse,
  NumberedWeekday.parse,
  SpecificDays.parse,
  PublicHolidays.parse,
];

abstract class DaysRange implements Comparable {
  bool get isEmpty;
  bool get isFull;
  bool get shownByDefault;
  bool get canBeJoinedToWeekdays;

  bool get isNotEmpty => !isEmpty;

  String makeString();

  static List<DaysRange> parse(String? days) {
    if (days == null) return [];
    final result = <DaysRange>[];
    String? kept;
    for (final part in days.split(',').map((p) => p.trim())) {
      if (part.isNotEmpty) {
        // This wizardry is needed for parts like "We[2,3,4]".
        final fullPart = kept == null ? part : '$kept,$part';
        if (fullPart.contains('[') && !fullPart.contains(']')) {
          kept = fullPart;
          continue;
        }
        kept = null;
        bool foundOne = false;
        for (final p in kDaysRangeParsers) {
          try {
            final parsed = p(fullPart);
            if (parsed != null) {
              result.add(parsed);
              foundOne = true;
              continue;
            }
          } on Exception {
            // nothing
          }
        }
        if (!foundOne)
          throw HoursParsingException(
              'Could not parse day range part "$fullPart"');
      }
    }
    return result;
  }

  DaysRange? getMissing() => null;

  bool get haveMissingDays => getMissing()?.isNotEmpty ?? false;
  DaysRange? merge(DaysRange other) => null;

  @override
  int compareTo(other) {
    if (other is! DaysRange)
      throw ArgumentError('Can compare only with DaysRange.');
    final imp = kDaysRangeClasses
        .indexOf(runtimeType)
        .compareTo(kDaysRangeClasses.indexOf(other.runtimeType));
    if (imp != 0) return imp;

    final thisEmpty = isEmpty;
    final otherEmpty = other.isEmpty;
    if (thisEmpty) {
      return otherEmpty ? 0 : -1;
    } else if (otherEmpty) return 1;
    return compareImpl(other);
  }

  int compareImpl(DaysRange other);
  DaysRange removeIntersections(DaysRange other);

  @override
  String toString() => makeString();
}

class Weekdays extends DaysRange {
  final List<bool> days;

  static const kDayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const kDayIndices = <String, int>{
    'mo': 0,
    'tu': 1,
    'we': 2,
    'th': 3,
    'fr': 4,
    'sa': 5,
    'su': 6,
  };

  Weekdays(this.days) {
    if (days.length != 7) throw ArgumentError('Specify 7 weekdays for Mo-Su.');
  }

  Weekdays.empty() : days = List.filled(7, false);
  Weekdays.fullWeek() : days = List.filled(7, true);

  @override
  bool get isEmpty => days.every((open) => !open);

  @override
  bool get shownByDefault => true;

  @override
  bool get canBeJoinedToWeekdays => true;

  @override
  bool get isFull => days.every((open) => open);

  void setFrom(Weekdays other) {
    for (int i = 0; i < days.length; i++) days[i] = other.days[i];
  }

  Weekdays copyWith(int index, bool isSet) {
    return Weekdays(days)..days[index] = isSet;
  }

  static Weekdays? parse(String days) {
    final result = List.filled(7, false);
    for (final part in days.toLowerCase().split(',')) {
      final interval =
          part.split('-').map((d) => kDayIndices[d.trim()]).toList();
      if (interval.isEmpty) continue;
      if (interval.contains(null)) return null;
      if (interval.length == 1) {
        result[interval.first!] = true;
      } else {
        // assuming it's 2
        int start = interval[0]!;
        int end = interval[1]!;
        for (int i = start; i != end; i = (i + 1) % 7) result[i] = true;
        result[end] = true;
      }
    }
    return Weekdays(result);
  }

  @override
  int compareImpl(DaysRange other) {
    if (other is! Weekdays) throw ArgumentError();
    for (int i = 0; i < days.length; i++) {
      if (days[i] != other.days[i]) return days[i] ? -1 : 1;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Weekdays) return false;
    for (int i = 0; i < days.length; i++)
      if (days[i] != other.days[i]) return false;
    return true;
  }

  @override
  String makeString() {
    int day = 0;
    final List<String> intervals = [];
    while (day < 7 && !days[day]) day++;
    while (day < 7) {
      final start = day;
      while (day < 7 && days[day]) day++;
      if (day - start > 1) {
        intervals.add('${kDayNames[start]}-${kDayNames[day - 1]}');
      } else {
        intervals.add(kDayNames[start]);
        if (day - start == 2) intervals.add(kDayNames[start + 1]);
      }
      while (day < 7 && !days[day]) day++;
    }
    return intervals.join(',');
  }

  @override
  int get hashCode => days.hashCode;

  @override
  Weekdays? getMissing() {
    return Weekdays(days.map((d) => !d).toList());
  }

  @override
  Weekdays merge(DaysRange other) {
    List<bool> daysSet = List.of(days);
    for (int i = 0; i < daysSet.length; i++)
      daysSet[i] = daysSet[i] || (other as Weekdays).days[i];
    return Weekdays(daysSet);
  }

  @override
  Weekdays removeIntersections(DaysRange other) {
    if (isEmpty || other.isEmpty || other is! Weekdays) return this;
    final newDays = List.of(days);
    for (int i = 0; i < newDays.length; i++)
      if (other.days[i]) newDays[i] = false;
    return Weekdays(newDays);
  }
}

class PublicHolidays extends DaysRange {
  @override
  bool get isEmpty => false;

  @override
  bool get isFull => true;

  @override
  bool get shownByDefault => true;

  @override
  bool get canBeJoinedToWeekdays => true;

  @override
  String makeString() => 'PH';

  static PublicHolidays? parse(String days) {
    if (days.trim().toLowerCase() == 'ph') return PublicHolidays();
    return null;
  }

  @override
  // Merging with another PublicHolidays is just removing a duplicate.
  PublicHolidays merge(DaysRange other) => this;

  @override
  // ignore: hash_and_equals
  bool operator ==(other) => other is PublicHolidays;

  @override
  int compareImpl(DaysRange other) => 0;

  @override
  PublicHolidays removeIntersections(DaysRange other) => this;
}

class NumberedWeekday extends DaysRange {
  final Set<int> days;
  final int weekday;

  NumberedWeekday(this.weekday, this.days);

  NumberedWeekday toggleDay(int day, bool? set) {
    final newDays = Set.of(days);
    set ??= !newDays.contains(day);
    if (set)
      newDays.add(day);
    else
      newDays.remove(day);
    return NumberedWeekday(weekday, newDays);
  }

  @override
  bool get isEmpty => days.isEmpty;

  @override
  bool get shownByDefault => false;

  @override
  bool get canBeJoinedToWeekdays => true;

  @override
  bool get isFull => days.containsAll([-1, 1, 2, 3, 4]);

  List<int> get sorted {
    final result = List.of(days);
    result.sort();
    return result;
  }

  @override
  String makeString() => '${Weekdays.kDayNames[weekday]}[${sorted.join(",")}]';

  static final _kWeekdayRegexp =
      RegExp(r'(Mo|Tu|We|Th|Fr|Sa|Su)\s*\[([\d, -]+)\]', caseSensitive: false);

  static NumberedWeekday? parse(String days) {
    final match = _kWeekdayRegexp.matchAsPrefix(days);
    if (match == null) return null;
    final idxs = match.group(2)!.split(',').map((e) => int.tryParse(e.trim()));
    if (idxs.isEmpty || idxs.contains(null)) return null;
    return NumberedWeekday(
      Weekdays.kDayIndices[match.group(1)!.toLowerCase()]!,
      idxs.whereType<int>().toSet(),
    );
  }

  @override
  NumberedWeekday? merge(DaysRange other) {
    if (weekday != (other as NumberedWeekday).weekday) return null;
    return NumberedWeekday(weekday, days.union(other.days));
  }

  @override
  int compareImpl(DaysRange other) {
    if (other is! NumberedWeekday) throw ArgumentError();
    final wd = weekday.compareTo(other.weekday);
    if (wd != 0) return wd;
    // This should be handled upstream, so just in case.
    if (isEmpty || other.isEmpty) return 0;
    return sorted.first.compareTo(other.sorted.first);
  }

  @override
  bool operator ==(Object other) {
    if (other is! NumberedWeekday) return false;
    if (weekday != other.weekday) return false;
    return setEquals(days, other.days);
  }

  @override
  int get hashCode => weekday.hashCode + days.hashCode;

  @override
  NumberedWeekday removeIntersections(DaysRange other) {
    if (isEmpty ||
        other.isEmpty ||
        other is! NumberedWeekday ||
        weekday != other.weekday) return this;
    return NumberedWeekday(weekday, days.difference(other.days));
  }
}

class Date implements Comparable {
  final int month;
  final int day;

  const Date(this.month, this.day);
  Date.fromDateTime(DateTime dt)
      : month = dt.month,
        day = dt.day;

  static const kYear = 2000;
  DateTime toDateTime() => DateTime(kYear, month, day);

  static const _kMonthDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  int difference(Date other) {
    if (other.month == month) return day - other.day;
    if (other.month < month) {
      return Iterable.generate(month - other.month)
          .map((i) =>
              _kMonthDays[i + other.month - 1] + 1 - (i == 0 ? other.day : 1))
          .fold(day - 1, (prev, cnt) => prev + cnt);
    } else {
      return -1 *
          Iterable.generate(other.month - month)
              .map((i) => _kMonthDays[i + month - 1] + 1 - (i == 0 ? day : 1))
              .fold(other.day - 1, (prev, cnt) => prev + cnt);
    }
  }

  Date next() {
    int newDay = day + 1;
    int newMonth = month;
    while (newDay > _kMonthDays[newMonth - 1]) {
      newDay -= _kMonthDays[newMonth - 1];
      newMonth = newMonth == 12 ? 1 : newMonth + 1;
    }
    return Date(newMonth, newDay);
  }

  @override
  bool operator ==(Object other) =>
      other is Date && month == other.month && day == other.day;

  bool operator <(Object other) => compareTo(other) < 0;
  bool operator >(Object other) => compareTo(other) > 0;
  bool operator <=(Object other) => compareTo(other) <= 0;
  bool operator >=(Object other) => compareTo(other) >= 0;

  @override
  int get hashCode => month.hashCode + day.hashCode;

  @override
  int compareTo(other) {
    if (other is! Date) throw ArgumentError('Can compare only with days');
    final mc = month.compareTo(other.month);
    if (mc != 0) return mc;
    return day.compareTo(other.day);
  }

  @override
  String toString() => 'Date($month, $day)';
}

class SpecificDays extends DaysRange {
  final Set<Date> days;

  SpecificDays(this.days);

  SpecificDays withInterval(List<Date> interval) {
    final newDays = Set.of(days);
    newDays.addAll(_expandInterval(interval));
    return SpecificDays(newDays);
  }

  SpecificDays withoutInterval(List<Date> interval) {
    final newDays = Set.of(days);
    newDays.removeAll(_expandInterval(interval));
    return SpecificDays(newDays);
  }

  @override
  bool get isEmpty => days.isEmpty;

  @override
  bool get shownByDefault => false;

  @override
  bool get canBeJoinedToWeekdays => false;

  @override
  bool get isFull => false;

  List<Date> sorted() {
    final result = List.of(days);
    result.sort();
    return result;
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  String makeDatePart(List<Date> interval) {
    const kMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final firstStr =
        '${kMonths[interval.first.month - 1]} ${_pad2(interval.first.day)}';
    if (interval.last == interval.first) {
      return firstStr;
    } else {
      if (interval.last.month == interval.first.month) {
        return '$firstStr-${_pad2(interval.last.day)}';
      } else {
        final lastStr =
            '${kMonths[interval.last.month - 1]} ${_pad2(interval.last.day)}';
        return '$firstStr-$lastStr';
      }
    }
  }

  List<List<Date>> getIntervals() {
    final parts = <List<Date>>[];
    Date? first;
    Date? last;
    for (final d in sorted()) {
      if (last == null) {
        first = d;
      } else if (d.difference(last) != 1) {
        parts.add([first!, last]);
        first = d;
      }
      last = d;
    }
    if (last != null) parts.add([first!, last]);
    return parts;
  }

  @override
  String makeString() {
    return getIntervals().map((i) => makeDatePart(i)).join(',');
  }

  static final _kDayRegexp = RegExp(
      r'([a-z]+)\s+(\d+)(?:\s*-\s*([a-z]+\s+)?(\d+))?:?',
      caseSensitive: false);
  static const _kMonthsIdx = <String, int>{
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };
  static const _kMonthDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  static List<Date> _expandInterval(List<Date> interval) {
    final result = <Date>[];
    for (var date = interval.first; date != interval.last; date = date.next())
      result.add(date);
    result.add(interval.last);
    return result;
  }

  static SpecificDays? parse(String days) {
    final match = _kDayRegexp.matchAsPrefix(days);
    if (match == null) return null;

    final monthStr1 = match.group(1)!.toLowerCase();
    final int? month1 = _kMonthsIdx[
        monthStr1.length > 3 ? monthStr1.substring(0, 3) : monthStr1];
    final int day1 = int.parse(match.group(2)!);
    if (month1 == null || day1 < 1 || day1 > _kMonthDays[month1 - 1])
      return null;

    if (match.group(4) == null) return SpecificDays({Date(month1, day1)});

    int? month2;
    if (match.group(3) == null)
      month2 = month1;
    else {
      final monthStr2 = match.group(3)!.toLowerCase();
      month2 = _kMonthsIdx[
          monthStr2.length > 3 ? monthStr2.substring(0, 3) : monthStr2];
    }
    final int day2 = int.parse(match.group(4)!);
    if (month2 == null || day2 < 1 || day2 > _kMonthDays[month2 - 1])
      return null;

    return SpecificDays(
        Set.of(_expandInterval([Date(month1, day1), Date(month2, day2)])));
  }

  @override
  SpecificDays merge(DaysRange other) {
    return SpecificDays(days.followedBy((other as SpecificDays).days).toSet());
  }

  @override
  int compareImpl(DaysRange other) {
    if (other is! SpecificDays) throw ArgumentError();
    // This should be handled upstream, so just in case.
    if (isEmpty || other.isEmpty) return 0;
    return sorted().first.compareTo(other.sorted().first);
  }

  @override
  bool operator ==(Object other) {
    if (other is! SpecificDays) return false;
    return setEquals(days, other.days);
  }

  @override
  int get hashCode => days.hashCode;

  @override
  SpecificDays removeIntersections(DaysRange other) {
    if (isEmpty || other.isEmpty || other is! SpecificDays) return this;
    final otherDays = Set.of(other.days);
    return SpecificDays(
        days.where((element) => !otherDays.contains(element)).toSet());
  }
}
