import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/interval2.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CollectionPresetField extends PresetField {
  CollectionPresetField(
      {required String key,
      required String label,
      FieldPrerequisite? prerequisite})
      : super(
            key: key,
            label: label,
            icon: Icons.schedule,
            prerequisite: prerequisite);

  @override
  Widget buildWidget(OsmChange element) =>
      HoursInputField(this, element, isCollectionTimes: true);
}

class HoursInputField extends ConsumerStatefulWidget {
  final OsmChange element;
  final PresetField field;
  final bool isCollectionTimes;

  const HoursInputField(this.field, this.element,
      {this.isCollectionTimes = false});

  @override
  ConsumerState<HoursInputField> createState() => _HoursInputFieldState();
}

class _HoursInputFieldState extends ConsumerState<HoursInputField> {
  String? mostCommonHours;

  @override
  initState() {
    super.initState();
    findMostCommonInterval();
  }

  String? _prettifyHours(String? hours) {
    if (hours == null) return null;
    return hours
        .replaceAll(':00', '')
        .replaceAll(RegExp(r'\s*;\s*'), '\n')
        .replaceAllMapped(RegExp(r',(\S)'), (m) => ', ${m.group(1)}');
  }

  findMostCommonInterval() async {
    final data = ref.read(osmDataProvider);
    List<String> hoursList =
        await data.getOpeningHoursAround(widget.element.location, limit: 20);

    // Consider those with 3+ occurrences.
    final counter = <String, int>{};
    for (final h in hoursList) counter[h] = (counter[h] ?? 0) + 1;
    hoursList =
        counter.entries.where((e) => e.value >= 3).map((e) => e.key).toList();

    // Parse opening hours and remove those with 24/7 entries.
    final parsed = hoursList
        .map((s) => HoursData(s))
        .where((h) => h.fragments.isNotEmpty)
        .where((h) => h.fragments.every((f) => !f.is24))
        .map((h) => h.buildHours())
        .toList();
    if (parsed.isEmpty) return;

    // Find the most common value.
    counter.clear();
    for (final h in parsed) counter[h] = (counter[h] ?? 0) + 1;
    final counterEntries = counter.entries.toList();
    counterEntries.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      mostCommonHours = counterEntries.first.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                String? value = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpeningHoursPage(
                            widget.element[widget.field.key] ?? '24/7',
                            element: widget.element)));
                if (value != null) {
                  widget.element[widget.field.key] = value == '-' ? null : value;
                }
              },
              child: Container(
                width: double.infinity, // To align contents to the left
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                    _prettifyHours(widget.element[widget.field.key]) ??
                        loc.fieldHoursButton,
                    style: kFieldTextStyle),
              ),
            ),
          ),
          if (widget.element[widget.field.key] == null &&
              mostCommonHours != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ElevatedButton(
                child: Icon(Icons.event_repeat),
                onPressed: () {
                  setState(() {
                    widget.element[widget.field.key] = mostCommonHours;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class OpeningHoursPage extends ConsumerStatefulWidget {
  final String hours;
  final OsmChange? element;
  final bool isCollectionTimes;

  const OpeningHoursPage(this.hours, {this.element, this.isCollectionTimes = false});

  @override
  ConsumerState<OpeningHoursPage> createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends ConsumerState<OpeningHoursPage> {
  late HoursData hours;
  HoursInterval? defaultInterval;
  final ScrollController _scrollController = ScrollController();
  bool isRaw = false;

  @override
  initState() {
    super.initState();
    hours = HoursData(widget.hours);
    isRaw = hours.raw;
    findDefaultInterval();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  findDefaultInterval() async {
    if (widget.element == null) return;
    final data = ref.read(osmDataProvider);
    final hoursList =
        await data.getOpeningHoursAround(widget.element!.location);

    // Parse opening hours and remove those with 24/7 entries.
    final parsed = hoursList
        .map((s) => HoursData(s))
        .where((h) => h.fragments.isNotEmpty)
        .where((h) => h.fragments.every((f) => !f.is24))
        .toList();
    if (parsed.isEmpty) return;

    // For each set, take the one with the most weekdays.
    final intervals = <HoursInterval, int>{};
    for (final p in parsed) {
      final fragments = List.of(p.fragments);
      fragments.sort((a, b) => b.weekdays
          .fold<int>(0, (v, w) => v + (w ? 1 : 0))
          .compareTo(a.weekdays.fold<int>(0, (v, w) => v + (w ? 1 : 0))));
      intervals[fragments.first.interval] =
          (intervals[fragments.first.interval] ?? 0) + 1;
    }

    // Finally sort the map by count and return the most common interval.
    final sorted = intervals.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      defaultInterval = sorted.first.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldHoursTitle),
        actions: [
          if (!hours.raw && !isRaw)
            IconButton(
              onPressed: () {
                setState(() {
                  isRaw = true;
                });
              },
              icon: Icon(Icons.create),
            ),
          IconButton(
            onPressed: () {
              Navigator.pop(context, '-');
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body:
          isRaw ? buildRawHoursEditor(context) : buildFragmentsEditor(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          final result = isRaw ? hours.hours : hours.buildHours();
          Navigator.pop(context, result);
        },
      ),
    );
  }

  Widget buildRawHoursEditor(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextFormField(
        initialValue: hours.hours,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.visiblePassword,
        autovalidateMode: AutovalidateMode.always,
        style: kFieldTextStyle,
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            hours.updateHours(value);
          });
        },
        validator: (value) =>
            value == null || HoursData.isValid(value) ? null : 'Wrong format',
      ),
    );
  }

  Widget buildFragmentsEditor(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListView(
      controller: _scrollController,
      children: [
        for (int i = 0; i < hours.fragments.length; i++)
          Card(
            child: HoursFragmentEditor(
              fragment: hours.fragments[i],
              defaultInterval: defaultInterval,
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
            onPressed: () async {
              HoursInterval interval = hours.fragments.last.interval;
              if (!interval.isAllDay) {
                final result =
                    await ClockEditor.showIntervalEditor(context, interval);
                if (result != null)
                  interval = result;
                else
                  return;
              }
              setState(() {
                hours.fragments
                    .add(HoursFragment(hours.getMissingDays(), interval, []));
              });
              Timer(Duration(milliseconds: 100), () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                );
              });
            },
            child: Text(loc.fieldHoursAddFragment),
          ),
        SwitchListTile(
          title: Text('Closed on public holidays'),
          value: hours.phOff,
          onChanged: (value) {
            setState(() {
              hours.phOff = !hours.phOff;
            });
          },
        ),
        if (hours.fragments.length >= 2) SizedBox(height: 80.0),
      ],
    );
  }
}

class HoursFragmentEditor extends StatefulWidget {
  final HoursFragment fragment;
  final HoursInterval? defaultInterval;
  final Function? onDelete;
  final Function? onChange;

  const HoursFragmentEditor(
      {required this.fragment,
      this.defaultInterval,
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
              final result = await ClockEditor.showIntervalEditor(context,
                  widget.defaultInterval ?? HoursInterval('09:00', '18:00'));
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
        if (widget.fragment.breaks.length < 4)
          MaterialButton(
            onPressed: () async {
              final result = await ClockEditor.showIntervalEditor(
                  context, HoursInterval('14:00', '15:00'));
              if (result != null) {
                setState(() {
                  if (widget.fragment.is24) {
                    // Split the 24 hour interval at the given points.
                    widget.fragment.interval =
                        HoursInterval(result.end, result.start);
                  } else {
                    widget.fragment.breaks.add(result);
                  }
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