import 'package:flutter/foundation.dart';

class HoursInterval implements Comparable {
  String start;
  String end;

  HoursInterval(this.start, this.end) {
    if (start.length < 4 ||
        !start.contains(':') ||
        end.length < 4 ||
        !end.contains(':'))
      throw ArgumentError(
          'Wrong start ($start) or end ($end) time for an interval.');

    if (start.length == 4) start = '0' + start;
    if (end.length == 4) end = '0' + end;
    if (end == '00:00') end = '24:00';
  }

  HoursInterval.full()
      : start = '00:00',
        end = '24:00';

  bool get isAllDay => start == '00:00' && (end == '23:59' || end == '24:00');

  @override
  String toString() => '$start-$end';

  @override
  bool operator ==(Object other) {
    return other is HoursInterval && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode + end.hashCode;

  @override
  int compareTo(other) {
    if (other is! HoursInterval) throw ArgumentError();
    int value = start.compareTo(other.start);
    if (value == 0) value = end.compareTo(other.end);
    return value;
  }
}

class HoursFragment implements Comparable {
  final List<bool> weekdays;
  HoursInterval interval;
  List<HoursInterval> breaks;

  HoursFragment(this.weekdays, this.interval, this.breaks);

  bool get isAllWeek => weekdays.every((open) => open);
  bool get isEmpty => weekdays.every((open) => !open);
  bool get is24 => breaks.isEmpty && interval.isAllDay;
  bool get is24_7 => is24 && isAllWeek;

  @override
  bool operator ==(Object other) {
    if (other is! HoursFragment) return false;
    return listEquals(weekdays, other.weekdays) && intervalsEquals(other);
  }

  bool intervalsEquals(HoursFragment other) =>
      interval == other.interval && listEquals(breaks, other.breaks);

  @override
  int get hashCode => weekdays.hashCode + interval.hashCode + breaks.hashCode;

  @override
  int compareTo(other) {
    if (other is! HoursFragment) throw ArgumentError();
    for (int i = 0; i < weekdays.length; i++) {
      if (weekdays[i] != other.weekdays[i]) return weekdays[i] ? -1 : 1;
    }
    return interval.compareTo(other.interval);
  }
}

class HoursData {
  String hours;
  List<HoursFragment> fragments;
  bool phOff = false;

  HoursData(this.hours) : fragments = [] {
    _parseHours();
  }

  bool get raw => hours.isNotEmpty && fragments.isEmpty;
  bool get isEmpty => hours.isEmpty;

  static final kReHoursPart = RegExp(
    r'^[,; ]*((?:Mo|Tu|We|Th|Fr|Sa|Su|PH)(?:[, -]+(?:Mo|Tu|We|Th|Fr|Sa|Su))*)?'
    r'\s*((?:\d?\d:\d\d\s*-\s*\d?\d:\d\d)(?:\s*,\s*(?:\d?\d:\d\d\s*-\s*\d?\d:\d\d))*|off)',
    caseSensitive: false,
  );
  static final kReInterval = RegExp(r'(\d?\d:\d\d)\s*-\s*(\d?\d:\d\d)');

  _parseHours() {
    hours = hours.trim();
    phOff = false;
    if (hours == '24/7' || hours.isEmpty) {
      this.fragments = [
        HoursFragment(List.filled(7, true), HoursInterval.full(), [])
      ];
      return;
    }

    List<HoursFragment> fragments = [];
    int lastIndex = 0;
    var match = kReHoursPart.matchAsPrefix(hours, lastIndex);
    while (match != null) {
      if (match.group(1) != null &&
          match.group(1)!.toUpperCase() == 'PH' &&
          match.group(2)!.toLowerCase() == 'off') {
        // We support public holidays ONLY in form "PH off".
        phOff = true;
      } else {
        if (match.group(1) != null && match.group(1)!.contains('PH')) break;
        List<bool> days = _parseWeekdays(match.group(1));
        List<String> hoursList = [];
        for (final hoursPart in match.group(2)!.split(',')) {
          final hoursMatch = kReInterval.firstMatch(hoursPart.trim());
          if (hoursMatch != null) {
            hoursList.add(hoursMatch.group(1)!);
            hoursList.add(hoursMatch.group(2)!);
          }
        }
        if (hoursList.isNotEmpty) {
          fragments.add(HoursFragment(
            days,
            HoursInterval(hoursList.first, hoursList.last),
            [
              for (int i = 1; i < hoursList.length - 1; i += 2)
                HoursInterval(hoursList[i], hoursList[i + 1])
            ],
          ));
        }
      }

      lastIndex += match.end;
      match = kReHoursPart.matchAsPrefix(hours.substring(lastIndex));
    }

    final complete = RegExp(r'^[;, ]*$').hasMatch(hours.substring(lastIndex));
    this.fragments = complete ? fragments : [];
  }

  List<bool> _parseWeekdays(String? days) {
    const weekdays = <String, int>{
      'mo': 0,
      'tu': 1,
      'we': 2,
      'th': 3,
      'fr': 4,
      'sa': 5,
      'su': 6,
    };
    if (days == null) return List.filled(7, true);

    final result = List.filled(7, false);
    for (final part in days.toLowerCase().split(',')) {
      final interval = part.split('-').map((d) => d.trim()).toList();
      if (interval.isEmpty || interval.first.trim().isEmpty) continue;
      if (interval.length == 1) {
        result[weekdays[interval.first]!] = true;
      } else {
        // assuming it's 2
        int start = weekdays[interval[0]]!;
        int end = weekdays[interval[1]]!;
        for (int i = start; i != end; i = (i + 1) % 7) result[i] = true;
        result[end] = true;
      }
    }
    return result;
  }

  String _buildWeekdays(List<bool> days) {
    assert(days.length == 7);
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    int day = 0;
    final List<String> intervals = [];
    while (day < days.length && !days[day]) day++;
    while (day < 7) {
      final start = day;
      while (day < days.length && days[day]) day++;
      if (day - start > 1) {
        intervals.add('${weekdays[start]}-${weekdays[day - 1]}');
      } else {
        intervals.add(weekdays[start]);
        if (day - start == 2) intervals.add(weekdays[start + 1]);
      }
      while (day < days.length && !days[day]) day++;
    }
    return intervals.join(',');
  }

  String buildHours() {
    if (this.fragments.isEmpty) return hours;
    if (this.fragments.first.is24_7) return '24/7';

    // Sort and remove duplicates.
    final fragments = List.of(this.fragments);
    fragments.sort();
    for (int i = fragments.length - 1; i > 0; i--) {
      if (fragments[i].intervalsEquals(fragments[i - 1])) {
        for (int j = 0; j < fragments[i].weekdays.length; j++)
          fragments[i - 1].weekdays[j] |= fragments[i].weekdays[j];
        fragments.removeAt(i);
      }
    }

    List<String> parts = [];
    for (final fragment in fragments) {
      String? weekdays;
      if (!fragment.isAllWeek) {
        weekdays = _buildWeekdays(fragment.weekdays);
      }
      List<String> hours = [
        for (final b in fragment.breaks) ...[b.start, b.end]
      ];
      hours.insert(0, fragment.interval.start);
      hours.add(fragment.interval.end);
      List<String> intervals = [
        for (int i = 0; i < hours.length; i += 2) '${hours[i]}-${hours[i + 1]}'
      ];
      String hoursStr = intervals.join(',');
      parts.add([weekdays, hoursStr].whereType<String>().join(' '));
    }

    if (phOff) parts.add('PH off');
    return parts.join('; ');
  }

  updateHours(String newHours) {
    hours = newHours.trim();
  }

  List<bool> getMissingDays() {
    List<bool> result = List.filled(7, true);
    for (final f in fragments) {
      for (int i = 0; i < 7; i++) result[i] = result[i] ^ f.weekdays[i];
    }
    return result;
  }

  bool get haveMissingDays {
    return getMissingDays().any((day) => day);
  }
}
