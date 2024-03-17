import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hours/hours_model.dart';
import 'hours/hours_page.dart';

class HoursPresetField extends PresetField {
  HoursPresetField(
      {required super.key,
      required super.label,
      super.prerequisite})
      : super(
            icon: Icons.schedule);

  @override
  Widget buildWidget(OsmChange element) => HoursInputField(this, element);
}

class CollectionPresetField extends PresetField {
  CollectionPresetField(
      {required super.key,
      required super.label,
      super.prerequisite})
      : super(
            icon: Icons.schedule);

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
    const kMinMatchingIntervals = 3;

    final data = ref.read(osmDataProvider);
    List<String> hoursList =
        await data.getOpeningHoursAround(widget.element.location, limit: 20);

    // Consider those with 3+ occurrences.
    final counter = <String, int>{};
    for (final h in hoursList) counter[h] = (counter[h] ?? 0) + 1;
    hoursList = counter.entries
        .where((e) => e.value >= kMinMatchingIntervals)
        .map((e) => e.key)
        .toList();

    // Parse opening hours and remove those with 24/7 entries.
    final parsed = hoursList
        .map((s) => HoursData(s))
        .where((h) => h.fragments.isNotEmpty)
        .where((h) => h.fragments.every((f) => !f.is24h && f.interval != null))
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
                            widget.element[widget.field.key],
                            element: widget.element)));
                if (value != null) {
                  widget.element[widget.field.key] =
                      value == '-' ? null : value;
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
          if (mostCommonHours != null &&
              widget.element[widget.field.key] != mostCommonHours)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ElevatedButton(
                child: Icon(Icons.event_repeat),
                style: widget.element[widget.field.key] == null
                    ? null
                    : ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                      ),
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