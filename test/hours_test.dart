import 'package:every_door/fields/hours/days_range.dart';
import 'package:test/test.dart';
import 'package:every_door/fields/hours/hours_model.dart';

void main() {
  test('StringTime initializes correctly', () {
    expect(StringTime('06:10').toString(), equals('06:10'));
    expect(StringTime('6:10').toString(), equals('06:10'));
    expect(StringTime('25:00').toString(), equals('25:00'));
    expect(StringTime('24:00').is2400, isTrue);
    expect(StringTime('0:00').is2400, isTrue);
    expect(StringTime('23:59').is2400, isTrue);
    expect(StringTime('00:00').fix_2400().toString(), equals('24:00'));
    expect(StringTime('00:00').fix_2400(), equals(StringTime('24:00')));

    expect(() => StringTime('10'), throwsArgumentError);
    expect(() => StringTime('10:0'), throwsArgumentError);
  });

  test('StringTime compares correctly', () {
    expect(StringTime('06:12'), lessThan(StringTime('06:23')));
    expect(StringTime('06:12'), greaterThan(StringTime('06:02')));
    expect(StringTime('18:10'), equals(StringTime('18:10')));
    expect(StringTime('06:12').compareTo(StringTime('08:19')), lessThan(0));
    expect(StringTime('16:12').compareTo(StringTime('08:19')), greaterThan(0));
  });

  test('HoursInterval parses time correctly', () {
    expect(HoursInterval.parse('06:10-22:00'), equals(HoursInterval.str('06:10', '22:00')));
    expect(HoursInterval.parse('06:10 -0:00'), equals(HoursInterval.str('06:10', '24:00')));
    expect(HoursInterval.parse('16:10-10:00'), equals(HoursInterval.str('16:10', '10:00')));
    expect(() => HoursInterval.parse('whatever'), throwsException);
    expect(() => HoursInterval.parse('12:10'), throwsException);
    expect(() => HoursInterval.parse('12:10-10'), throwsException);
  });
  
  test('HoursInterval compares correctly', () {
    expect(HoursInterval.str('10:00', '20:00').crossesMidnight, isFalse);
    expect(HoursInterval.str('10:00', '20:00').contains(HoursInterval.str('09:00', '09:30')), isFalse);
    expect(HoursInterval.str('10:00', '20:00').contains(HoursInterval.str('09:00', '10:30')), isFalse);
    expect(HoursInterval.str('10:00', '20:00').contains(HoursInterval.str('19:00', '19:30')), isTrue);
    expect(HoursInterval.str('10:00', '20:00').contains(HoursInterval.str('20:00', '20:30')), isFalse);
    expect(HoursInterval.str('10:00', '20:00').contains(HoursInterval.str('20:00', '09:30')), isFalse);

    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('09:00', '09:30')), isFalse);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('09:00', '10:30')), isTrue);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('19:00', '19:30')), isTrue);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('20:00', '20:30')), isFalse);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('19:59', '20:30')), isTrue);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('19:59', '09:30')), isTrue);
    expect(HoursInterval.str('10:00', '20:00').intersects(HoursInterval.str('20:00', '09:30')), isFalse);

    expect(HoursInterval.str('19:00', '05:00').crossesMidnight, isTrue);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('09:00', '09:30')), isFalse);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('02:00', '03:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('19:00', '19:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('09:00', '19:30')), isFalse);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('23:00', '01:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').contains(HoursInterval.str('05:00', '19:00')), isFalse);
    expect(HoursInterval.str('00:00', '24:00').contains(HoursInterval.str('23:00', '01:30')), isTrue);
    expect(HoursInterval.str('19:00', '26:00').contains(HoursInterval.str('23:00', '01:30')), isTrue);

    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('09:00', '09:30')), isFalse);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('09:00', '19:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('09:00', '08:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('01:00', '09:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('05:00', '09:30')), isFalse);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('18:00', '19:00')), isFalse);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('04:59', '09:30')), isTrue);
    expect(HoursInterval.str('19:00', '05:00').intersects(HoursInterval.str('05:00', '19:00')), isFalse);
  });

  test('HoursFragment initializes and tests correctly', () {
    HoursFragment fragment = HoursFragment(
      Weekdays([true, false, true, false, true, false, true]),
      HoursInterval.parse('10:00-18:00'),
      [HoursInterval.str('14:00', '15:00')],
    );
    expect(fragment.interval, equals(HoursInterval.str('10:00', '18:00')));
    expect(fragment.breaks, isNotEmpty);
    expect(fragment.breaks.first, equals(HoursInterval.str('14:00', '15:00')));
    expect(fragment.is24_7, isFalse);

    fragment = HoursFragment.make24();
    expect(fragment.weekdays, equals(Weekdays.fullWeek()));
    expect(fragment.interval, equals(HoursInterval.full()));
    expect(fragment.breaks, isEmpty);
    expect(fragment.is24_7, isTrue);
  });

  test('HoursFragment merges intervals', () {
    HoursFragment fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '13:00'), []);
    fragment.addInterval(HoursInterval.str('14:00', '20:00'));
    expect(fragment.interval, equals(HoursInterval.str('10:00', '20:00')));
    expect(fragment.breaks.length, equals(1));
    expect(fragment.breaks.first, equals(HoursInterval.str('13:00', '14:00')));

    fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '13:00'), []);
    fragment.addInterval(HoursInterval.str('1:00', '8:00'));
    expect(fragment.interval, equals(HoursInterval.str('01:00', '13:00')));
    expect(fragment.breaks.length, equals(1));
    expect(fragment.breaks.first, equals(HoursInterval.str('08:00', '10:00')));

    fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '15:00'), []);
    fragment.addInterval(HoursInterval.str('14:00', '20:00'));
    expect(fragment.interval, equals(HoursInterval.str('10:00', '20:00')));
    expect(fragment.breaks, isEmpty);
  });

  test('HoursFragment sorts breaks', () {
    HoursFragment fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '15:00'),
        [HoursInterval.str('10:00', '11:00')]);
    expect(fragment.interval, equals(HoursInterval.str('11:00', '15:00')));
    expect(fragment.breaks, isEmpty);

    fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '15:00'),
        [HoursInterval.str('13:00', '14:00'), HoursInterval.str('11:00', '11:30')]);
    expect(fragment.interval, equals(HoursInterval.str('10:00', '15:00')));
    expect(fragment.breaks.length, equals(2));
    expect(fragment.breaks.first, equals(HoursInterval.str('11:00', '11:30')));
    expect(fragment.breaks.last, equals(HoursInterval.str('13:00', '14:00')));

    fragment = HoursFragment(Weekdays.fullWeek(), HoursInterval.str('10:00', '15:00'),
        [HoursInterval.str('12:00', '14:00'), HoursInterval.str('11:00', '12:30')]);
    expect(fragment.interval, equals(HoursInterval.str('10:00', '15:00')));
    expect(fragment.breaks.length, equals(1), reason: fragment.breaks.toString());
    expect(fragment.breaks.first, equals(HoursInterval.str('11:00', '14:00')));
  });

  test('HoursData parses time correctly', () {
    HoursData data = HoursData('6:30-20:00');
    expect(data.fragments.length, equals(1));
    expect(data.fragments.first.interval, isNotNull);
    expect(data.fragments.first.interval, equals(HoursInterval.str('06:30', '20:00')));
    expect(data.fragments.first.breaks, isEmpty);
    // expect(data.fragments.first.weekdays.days, equals(List.filled(7, true) + [false]));

    data = HoursData('Mo-We 6:30-00:00');
    expect(data.fragments.length, equals(1));
    expect(data.fragments.first.interval, isNotNull);
    expect(data.fragments.first.interval, equals(HoursInterval.str('06:30', '24:00')));
    expect(data.fragments.first.breaks, isEmpty);
    // expect(data.fragments.first.weekdays.days, equals(List.filled(3, true) + List.filled(5, false)));

    data = HoursData('Mo-Fr 6:30-14:00; Sa-Su 15:00-20:00');
    expect(data.fragments.length, equals(2));
    expect(data.fragments.first.interval, isNotNull);
    expect(data.fragments.first.interval, equals(HoursInterval.str('06:30', '14:00')));
    expect(data.fragments.first.breaks, isEmpty);
    // expect(data.fragments.first.weekdays.days, equals([true, true, true, true, true, false, false, false]));
    expect(data.fragments.last.interval, equals(HoursInterval.str('15:00', '20:00')));
    // expect(data.fragments.last.weekdays.days, equals([false, false, false, false, false, true, true, false]));
    expect(data.fragments.last.breaks, isEmpty);

    data = HoursData('Mo-We, Fr 6:30-14:00, 15:00-20:00; Su,PH off');
    expect(data.fragments.length, equals(3), reason: data.buildHours());
    expect(data.fragments.first.interval, isNotNull);
    expect(data.fragments.first.interval, equals(HoursInterval.str('06:30', '20:00')));
    expect(data.fragments.first.breaks.length, equals(1));
    expect(data.fragments.first.breaks.first, equals(HoursInterval.str('14:00', '15:00')));
    expect(data.fragments.first.weekdays, equals(Weekdays([true, true, true, false, true, false, false])));
    expect(data.fragments[1].interval, isNull);
    expect(data.fragments.last.interval, isNull);
    expect(data.fragments.last.weekdays is PublicHolidays, isTrue);
    // expect(data.fragments.last.weekdays.days, equals([false, false, false, false, false, false, true, true]));

    data = HoursData('10:00-20:00; PH off');
    expect(data.fragments.length, equals(2));
    expect(data.fragments.first.interval, isNotNull);
    expect(data.fragments.first.weekdays, equals(Weekdays.fullWeek()));
    expect(data.fragments.last.interval, isNull);
    expect(data.fragments.last.weekdays is PublicHolidays, isTrue);
  });

  test('HoursData formats time correctly', () {
    HoursData data = HoursData('Mo-We, Fr 6:30-14:00, 15:00-20:00; Su,PH off');
    expect(data.fragments, isNotEmpty);
    expect(data.buildHours(), equals('Mo-We,Fr 06:30-14:00,15:00-20:00; Su,PH off'));

    // No rollover for now.
    data = HoursData('Sa-Tu 10:00-02:00');
    expect(data.fragments, isNotEmpty);
    expect(data.buildHours(), equals('Mo-Tu,Sa-Su 10:00-02:00'));

    data = HoursData('10:00-02:00');
    expect(data.fragments, isNotEmpty);
    expect(data.buildHours(), equals('10:00-02:00'));

    data = HoursData('Mo-Su, PH 10:00-02:00');
    expect(data.fragments, isNotEmpty);
    expect(data.buildHours(), equals('Mo-Su,PH 10:00-02:00'));
  });

  test('Date class calculates difference correctly', () {
    expect(Date.fromDateTime(DateTime(2010, 5, 16)), equals(Date(5, 16)));
    expect(Date(12, 5).difference(Date(12, 3)), equals(2));
    expect(Date(12, 1).difference(Date(11, 30)), equals(1));
    expect(Date(3, 1).difference(Date(2, 28)), equals(2));
    expect(Date(12, 31).difference(Date(1, 1)), equals(365));
    expect(Date(12, 3).difference(Date(12, 5)), equals(-2));
    expect(Date(1, 31).difference(Date(3, 1)), equals(-30));
  });

  test('SpecificDays parses and formats dates correctly', () {
    expect(SpecificDays.parse(''), isNull);
    expect(SpecificDays.parse('Jan 1'), isNotNull);
    expect(SpecificDays.parse('Feb 30'), isNull);
    expect(SpecificDays.parse('Jan 1'), equals(SpecificDays({Date(1, 1)})));
    expect(SpecificDays.parse('Jan 1')?.makeString(), equals('Jan 1'));
    expect(SpecificDays.parse('Aug 20-23')?.makeString(), equals('Aug 20-23'));
    expect(SpecificDays.parse('Feb 27-Mar 3')?.makeString(), equals('Feb 27-Mar 3'));
    // Does not account for New Year switch.
    expect(SpecificDays.parse('Dec 30-Jan 2')?.makeString(), equals('Jan 1-2,Dec 30-31'));
  });
}