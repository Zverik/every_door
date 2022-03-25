import 'package:every_door/fields/helpers/hours_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClockIntervalField extends StatelessWidget {
  final HoursInterval interval;
  final Function(HoursInterval) onChange;
  final bool isBreak;

  const ClockIntervalField(
      {required this.interval, required this.onChange, this.isBreak = false});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (!isBreak) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: ClockEditor(
                interval: interval,
                onChange: onChange,
                title: loc.fieldHoursOpens,
                displayBoth: false,
                isSecond: false,
              ),
            ),
            Expanded(
              child: ClockEditor(
                interval: interval,
                onChange: onChange,
                title: loc.fieldHoursCloses,
                displayBoth: false,
                isSecond: true,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ClockEditor(
          interval: interval,
          onChange: onChange,
          title: loc.fieldHoursBreak,
          displayBoth: true,
        ),
      );
    }
  }
}

class ClockEditor extends StatefulWidget {
  final HoursInterval interval;
  final String title;
  final bool displayBoth;
  final bool isSecond;
  final Function(HoursInterval) onChange;

  const ClockEditor({
    required this.interval,
    required this.onChange,
    required this.title,
    this.displayBoth = true,
    this.isSecond = false,
  });

  @override
  State<ClockEditor> createState() => _ClockEditorState();

  static Future<String?> _showTimePickerIntl(
      BuildContext context, String initialHours,
      [String? confirmText]) async {
    TimeOfDay start;
    final parts = initialHours.split(':');
    if (parts.length != 2)
      start = TimeOfDay(hour: 9, minute: 0);
    else
      start = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: start,
      builder: (BuildContext context, Widget? child) {
        // Force 24-hour clock.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    return time == null
        ? null
        : '${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}';
  }

  static Future<HoursInterval?> showIntervalEditor(
      BuildContext context, HoursInterval interval,
      [bool onlySecond = false]) async {
    String start = interval.start;
    if (!onlySecond) {
      final loc = AppLocalizations.of(context)!;
      final result = await _showTimePickerIntl(context, start, loc.fieldHoursNext);
      if (result == null) return null;
      start = result;
    }
    final end = await _showTimePickerIntl(context, interval.end);
    if (end == null) return null;
    return HoursInterval(start, end);
  }
}

class _ClockEditorState extends State<ClockEditor> {
  @override
  Widget build(BuildContext context) {
    String time;
    if (widget.displayBoth) {
      time = widget.interval.toString();
    } else {
      time = widget.isSecond ? widget.interval.end : widget.interval.start;
    }
    final double baseSize = widget.displayBoth ? 14.0 : 18.0;

    return GestureDetector(
      onTap: () async {
        final result = await ClockEditor.showIntervalEditor(
            context, widget.interval, widget.isSecond);
        if (result != null && result != widget.interval) {
          widget.onChange(result);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: baseSize, color: Colors.grey),
          ),
          Text(
            time,
            style: TextStyle(fontSize: baseSize * 2),
          ),
        ],
      ),
    );
  }
}
