class HoursInterval {
  String start;
  String end;

  HoursInterval(this.start, this.end);
  HoursInterval.full()
      : start = '00:00',
        end = '24:00';

  bool get isAllDay =>
      start.endsWith('0:00') && (end == '23:59' || end == '24:00');

  @override
  String toString() => '$start-$end';

  @override
  bool operator ==(Object other) {
    return other is HoursInterval && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode + end.hashCode;
}

class HoursFragment {
  final List<bool> weekdays;
  HoursInterval interval;
  List<HoursInterval> breaks;

  HoursFragment(this.weekdays, this.interval, this.breaks);

  bool get isAllWeek => weekdays.every((open) => open);
  bool get is24 => breaks.isEmpty && interval.isAllDay;
  bool get is24_7 => is24 && isAllWeek;
}

class HoursData {
  String hours;
  List<HoursFragment> fragments;

  HoursData(this.hours) : fragments = [] {
    _parseHours();
  }

  bool get raw => fragments.isEmpty;
  bool get isEmpty => hours.isEmpty;

  static final kReHoursPart = RegExp(
    r'^[,; ]*((?:Mo|Tu|We|Th|Fr|Sa|Su)(?:[, -]+(?:Mo|Tu|We|Th|Fr|Sa|Su))*)?'
    r'\s*((?:\d?\d:\d\d\s*-\s*\d?\d:\d\d)(?:\s*,\s*(?:\d?\d:\d\d\s*-\s*\d?\d:\d\d))*)',
    caseSensitive: true,
  );
  static final kReInterval = RegExp(r'(\d?\d:\d\d)\s*-\s*(\d?\d:\d\d)');

  _parseHours() {
    hours = hours.trim();
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
      List<bool> days = _parseWeekdays(match.group(1));
      List<String> lhours = [];
      for (final hpart in match.group(2)!.split(',')) {
        final hmatch = kReInterval.firstMatch(hpart.trim());
        if (hmatch != null) {
          lhours.add(hmatch.group(1)!);
          lhours.add(hmatch.group(2)!);
        }
      }
      fragments.add(HoursFragment(
        days,
        HoursInterval(lhours.first, lhours.last),
        [
          for (int i = 1; i < lhours.length - 1; i += 2)
            HoursInterval(lhours[i], lhours[i + 1])
        ],
      ));

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
      'su': 6
    };
    if (days == null) return List.filled(7, true);

    final result = List.filled(7, false);
    for (final part in days.toLowerCase().split(',')) {
      final interval = part.split('-');
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
    if (fragments.isEmpty) return '';
    if (fragments.first.is24_7) return '24/7';

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
    return parts.join('; ');
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
