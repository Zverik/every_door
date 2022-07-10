import 'package:every_door/constants.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Text(
          loc.fieldHoursPublicHolidays,
          style: TextStyle(fontSize: 30.0),
        ),
      ),
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
          padding: const EdgeInsets.only(left: 15.0, right: 10.0),
          child: DropdownButton<int>(
            items: Iterable.generate(7)
                .map((i) => DropdownMenuItem<int>(
                      child: Text(weekdayTitles[i]),
                      value: i,
                    ))
                .toList(),
            value: weekday.weekday,
            onChanged: (value) {
              if (value != null) onChange(NumberedWeekday(value, weekday.days));
            },
          ),
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

  static Future<Date?> pickDate(BuildContext context, {Date? start}) async {
    final now = DateTime.now();
    final resp = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: start?.toDateTime() ?? DateTime(now.year, 1, 1),
      lastDate: DateTime(now.year, 12, 31),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    return resp == null ? null : Date.fromDateTime(resp);
  }

  @override
  Widget build(BuildContext context) {
    final parts = days.getIntervals();
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: [
          for (final part in parts)
            Container(
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child:
                        Text(days.makeDatePart(part), style: kFieldTextStyle),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onChange(days.withoutInterval(part));
                    },
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () async {
              final date = await SpecificDaysPanel.pickDate(context);
              if (date != null) onChange(days.withInterval([date, date]));
            },
          ),
          IconButton(
            icon: Icon(Icons.control_point_duplicate),
            onPressed: () async {
              final date1 = await SpecificDaysPanel.pickDate(context);
              if (date1 == null) return;
              final date2 = await SpecificDaysPanel.pickDate(context,
                  start: date1.next());
              if (date2 == null) return;
              onChange(days.withInterval([date1, date2]));
            },
          ),
        ],
      ),
    );
  }
}
