import 'package:every_door/fields/hours/days_editors.dart';
import 'package:flutter/material.dart';
import 'package:every_door/fields/hours/interval.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'days_range.dart';
import 'hours_model.dart';

class HoursFragmentEditor extends StatefulWidget {
  final HoursFragment fragment;
  final TimeDefaults? timeDefaults;
  final Function? onDelete;
  final Function(HoursFragment)? onChange;

  const HoursFragmentEditor(
      {required this.fragment,
      this.timeDefaults,
      this.onDelete,
      this.onChange});

  @override
  State<HoursFragmentEditor> createState() => _HoursFragmentEditorState();
}

class _HoursFragmentEditorState extends State<HoursFragmentEditor> {
  bool addingBreak = false;

  bool get isOff => widget.fragment.active && widget.fragment.interval == null;

  _callOnChange(
      {bool? isOff,
      DaysRange? weekdays,
      HoursInterval? interval,
      List<HoursInterval>? breaks}) {
    if (widget.onChange != null) {
      final newInterval = interval ?? widget.fragment.interval;
      final newOff = isOff ?? this.isOff;
      final fragment = newOff || newInterval != null
          ? HoursFragment(
              weekdays ?? widget.fragment.weekdays,
              newOff ? null : newInterval,
              breaks ?? widget.fragment.breaks,
            )
          : HoursFragment.inactive(weekdays ?? widget.fragment.weekdays);
      widget.onChange!(fragment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (widget.onDelete != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    widget.onDelete!();
                  },
                  icon: Icon(Icons.close)),
            ],
          ),
        buildEditorForDaysRange(widget.fragment.weekdays, (newDays) {
          _callOnChange(weekdays: newDays);
        }),
        SwitchListTile(
          title: Text('Closed'), // TODO: translate
          value: isOff,
          onChanged: (value) {
            _callOnChange(isOff: value);
          },
        ),
        if (!isOff)
          // Time interval
          ChooserIntervalField(
            interval: widget.fragment.interval,
            timeDefaults: widget.timeDefaults,
            onChange: (value) {
              _callOnChange(interval: value);
            },
          ),
        if (!isOff && widget.fragment.interval != null) ...[
          // Breaks
          for (int i = 0; i < widget.fragment.breaks.length; i++)
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ChooserIntervalField(
                  interval: widget.fragment.breaks[i],
                  timeDefaults: widget.timeDefaults,
                  breakParent: widget.fragment.interval!,
                ),
                IconButton(
                  padding: EdgeInsets.only(bottom: 12.0),
                  onPressed: () {
                    final breaks = List.of(widget.fragment.breaks);
                    breaks.removeAt(i);
                    _callOnChange(breaks: breaks);
                  },
                  icon: Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
          if (widget.fragment.breaks.length < 4 &&
              widget.fragment.interval!.end.hour -
                      widget.fragment.interval!.start.hour >
                  2) ...[
            if (addingBreak)
              ChooserIntervalField(
                interval: null,
                timeDefaults: widget.timeDefaults,
                breakParent: widget.fragment.interval!,
                onChange: (value) {
                  final breaks = List.of(widget.fragment.breaks);
                  breaks.add(value);
                  _callOnChange(breaks: breaks);
                  setState(() {
                    addingBreak = false;
                  });
                },
              ),
            if (!addingBreak)
              MaterialButton(
                onPressed: () async {
                  setState(() {
                    addingBreak = true;
                  });
                },
                child: Text(loc.fieldHoursAddBreak),
              ),
          ],
        ],
      ],
    );
  }
}
