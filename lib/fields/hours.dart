import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/interval2.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/hours_model.dart';

class HoursPresetField extends PresetField {
  HoursPresetField(
      {required String key,
      required String label,
      FieldPrerequisite? prerequisite})
      : super(
            key: key,
            label: label,
            icon: Icons.schedule,
            prerequisite: prerequisite);

  @override
  Widget buildWidget(OsmChange element) => HoursInputField(this, element);
}

class HoursInputField extends StatelessWidget {
  final OsmChange element;
  final HoursPresetField field;

  const HoursInputField(this.field, this.element);

  String? _prettifyHours(String? hours) {
    if (hours == null) return null;
    return hours
        .replaceAll(':00', '')
        .replaceAll(RegExp(r'\s*;\s*'), '\n')
        .replaceAllMapped(RegExp(r',(\S)'), (m) => ', ${m.group(1)}');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          String? value = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OpeningHoursPage(element[field.key] ?? '24/7')));
          if (value != null) {
            element[field.key] = value;
          }
        },
        child: Container(
          width: double.infinity, // To align contents to the left
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
              _prettifyHours(element[field.key]) ?? loc.fieldHoursButton,
              style: kFieldTextStyle),
        ),
      ),
    );
  }
}

class OpeningHoursPage extends StatefulWidget {
  final String hours;

  const OpeningHoursPage(this.hours);

  @override
  State<StatefulWidget> createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends State<OpeningHoursPage> {
  late HoursData hours;

  @override
  initState() {
    super.initState();
    hours = HoursData(widget.hours);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldHoursTitle),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < hours.fragments.length; i++)
            Card(
              child: HoursFragmentEditor(
                fragment: hours.fragments[i],
                autofocus: i == 0,
                onDelete: i == 0
                    ? null
                    : () {
                        setState(() {
                          hours.fragments.removeAt(i);
                        });
                      },
                onChange: () {
                  setState(() {
                    // Remove duplicate weekdays from other fragments
                    for (int j = 0; j < hours.fragments.length; j++) {
                      if (i != j) {
                        for (int wd = 0;
                            wd < hours.fragments[i].weekdays.length;
                            wd++) {
                          if (hours.fragments[i].weekdays[wd]) {
                            hours.fragments[j].weekdays[wd] = false;
                            if (hours.fragments[j].isEmpty) {
                              // Would not clear a fragment; reverse the change.
                              hours.fragments[j].weekdays[wd] = true;
                              hours.fragments[i].weekdays[wd] = false;
                              return;
                            }
                          }
                        }
                      }
                    }
                  });
                  return true;
                },
              ),
            ),
          if (hours.haveMissingDays)
            MaterialButton(
              onPressed: () {
                setState(() {
                  hours.fragments.add(HoursFragment(
                      hours.getMissingDays(), HoursInterval.full(), []));
                });
              },
              child: Text(loc.fieldHoursAddFragment),
            ),
          if (hours.fragments.length >= 2)
            SizedBox(height: 80.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          // print(buildHours());
          Navigator.pop(context, hours.buildHours());
        },
      ),
    );
  }
}

class HoursFragmentEditor extends StatefulWidget {
  final HoursFragment fragment;
  final bool autofocus;
  final Function? onDelete;
  final Function? onChange;

  const HoursFragmentEditor(
      {required this.fragment,
      this.autofocus = false,
      this.onDelete,
      this.onChange});

  @override
  State<HoursFragmentEditor> createState() => _HoursFragmentEditorState();
}

class _HoursFragmentEditorState extends State<HoursFragmentEditor> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final weekdays = loc.fieldHoursWeekdays.split(' ');
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
        // Days of week
        Row(
          children: [
            for (int i = 0; i < 7; i++)
              Column(
                children: [
                  Checkbox(
                    value: widget.fragment.weekdays[i],
                    onChanged: (value) {
                      // Forbid removing all checkboxes.
                      if (widget.fragment.weekdays
                          .asMap()
                          .entries
                          .every((e) => e.key == i || !e.value)) return;

                      setState(() {
                        widget.fragment.weekdays[i] =
                            !widget.fragment.weekdays[i];
                      });
                      if (widget.onChange != null) widget.onChange!();
                    },
                  ),
                  Text(weekdays[i]),
                ],
              ),
          ],
        ),

        // 24/7
        SwitchListTile(
          title: Text(loc.fieldHoursFullDay),
          value: widget.fragment.is24,
          onChanged: (bool newValue) async {
            if (newValue) {
              setState(() {
                widget.fragment.interval = HoursInterval.full();
                widget.fragment.breaks.clear();
              });
            } else {
              // Ask for a value right away.
              final result = await ClockEditor.showIntervalEditor(
                  context, HoursInterval('09:00', '18:00'));
              if (result != null) {
                setState(() {
                  widget.fragment.interval = result;
                });
                if (widget.onChange != null) widget.onChange!();
              }
            }
          },
        ),

        // Time interval
        if (!widget.fragment.is24)
          ClockIntervalField(
            interval: widget.fragment.interval,
            onChange: (value) {
              setState(() {
                widget.fragment.interval = value;
              });
              if (widget.onChange != null) widget.onChange!();
            },
            isBreak: false,
          ),

        // Breaks
        for (int i = 0; i < widget.fragment.breaks.length; i++)
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClockIntervalField(
                interval: widget.fragment.breaks[i],
                onChange: (value) {
                  setState(() {
                    widget.fragment.breaks[i] = value;
                  });
                  if (widget.onChange != null) widget.onChange!();
                },
                isBreak: true,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.fragment.breaks.removeAt(i);
                  });
                  if (widget.onChange != null) widget.onChange!();
                },
                icon: Icon(Icons.close),
                color: Colors.grey,
              ),
            ],
          ),
        if (widget.fragment.breaks.length < 2 && !widget.fragment.is24)
          MaterialButton(
            onPressed: () async {
              final result = await ClockEditor.showIntervalEditor(
                  context, HoursInterval('14:00', '15:00'));
              if (result != null) {
                setState(() {
                  widget.fragment.breaks.add(result);
                });
                if (widget.onChange != null) widget.onChange!();
              }
            },
            child: Text(loc.fieldHoursAddBreak),
          ),
      ],
    );
  }
}
