import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'days_range.dart';

Widget buildEditorForDaysRange(DaysRange range, Function(DaysRange) onChange) {
  if (range is Weekdays) return WeekdaysPanel(range, onChange);
  if (range is PublicHolidays) return PublicHolidaysPanel(range, onChange);
  if (range is NumberedWeekday) return NumberedWeekdayPanel(range, onChange);
  if (range is SpecificDays) return SpecificDaysPanel(range, onChange);

  throw UnsupportedError('Unsupported range type: ${range.runtimeType}');
}

class WeekdaysPanel extends StatelessWidget {
  final Weekdays weekdays;
  final Function(Weekdays) onChange;

  const WeekdaysPanel(this.weekdays, this.onChange);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final weekdayTitles = loc.fieldHoursWeekdays.split(' ');

    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Column(
            children: [
              Checkbox(
                value: weekdays.days[i],
                onChanged: (value) {
                  // Forbid removing all checkboxes.
                  if (weekdays.days
                      .asMap()
                      .entries
                      .every((e) => e.key == i || !e.value)) return;

                  onChange(weekdays.copyWith(i, value ?? !weekdays.days[i]));
                },
              ),
              Text(weekdayTitles[i]),
            ],
          ),
      ],
    );
  }
}

class PublicHolidaysPanel extends StatelessWidget {
  final PublicHolidays ph;
  final Function(Weekdays) onChange;

  const PublicHolidaysPanel(this.ph, this.onChange);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // TODO: localize and style
    return Container(
      width: double.infinity,
      child: Center(
          child: Text(
        'Public Holidays',
        style: TextStyle(fontSize: 30.0),
      )),
    );
  }
}

class NumberedWeekdayPanel extends StatelessWidget {
  final NumberedWeekday weekday;
  final Function(NumberedWeekday) onChange;

  const NumberedWeekdayPanel(this.weekday, this.onChange);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final weekdayTitles = loc.fieldHoursWeekdays.split(' ');
    final days = [1, 2, 3, 4, -1];
    for (final d in weekday.days) {
      if (!days.contains(d)) days.insert(0, d);
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(weekdayTitles[weekday.weekday]),
        ),
        for (final i in days)
          Column(
            children: [
              Checkbox(
                value: weekday.days.contains(i),
                onChanged: (value) {
                  // Forbid removing all checkboxes.
                  if (value != true && weekday.days.length <= 1) return;
                  onChange(weekday.toggleDay(i, value));
                },
              ),
              Text(i.toString()),
            ],
          ),
      ],
    );
  }
}

class SpecificDaysPanel extends StatelessWidget {
  final SpecificDays days;
  final Function(SpecificDays) onChange;

  const SpecificDaysPanel(this.days, this.onChange);

  @override
  Widget build(BuildContext context) {
    // TODO
    return Text(days.makeString());
  }
}
