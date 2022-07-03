import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/fields/hours/interval.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'days_range.dart';
import 'hours_fragment.dart';
import 'hours_model.dart';

class OpeningHoursPage extends ConsumerStatefulWidget {
  final String? hours;
  final OsmChange? element;
  final bool isCollectionTimes;

  const OpeningHoursPage(this.hours,
      {this.element, this.isCollectionTimes = false});

  @override
  ConsumerState<OpeningHoursPage> createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends ConsumerState<OpeningHoursPage> {
  late HoursData hours;
  final timeDefaults = TimeDefaults();
  final ScrollController _scrollController = ScrollController();
  bool isRaw = false;

  @override
  initState() {
    super.initState();
    final hoursStr = widget.hours?.trim() ?? '';
    // Erase 24/7.
    hours = HoursData(hoursStr == '24/7' ? '' : hoursStr);
    isRaw = hours.raw;
    _findDefaultIntervals();
    _updateInactiveCard();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _findDefaultIntervals() async {
    if (widget.element == null) return;
    final data = ref.read(osmDataProvider);
    timeDefaults.updateFromAround(
        await data.getOpeningHoursAround(widget.element!.location, limit: 50));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldHoursTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, '-');
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
          child: isRaw
              ? buildRawHoursEditor(context)
              : buildFragmentsEditor(context)),
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
        decoration: InputDecoration(filled: true, fillColor: Colors.white),
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            hours.updateHours(value);
          });
        },
      ),
    );
  }

  _updateInactiveCard() {
    if (isRaw) return;
    int pos = hours.fragments.indexWhere((fragment) => !fragment.active);
    if (hours.fragments.isEmpty) {
      // No fragments — add a new empty one.
      setState(() {
        hours.fragments.add(HoursFragment.inactive(Weekdays.parse('Mo-Fr')!));
      });
    } else if (pos < 0) {
      // If there are no inactive cards, check if we need to add one.
      final missingDays = hours.getMissingWeekdays();
      if (missingDays.isNotEmpty) {
        // Add a card for missing days.
        setState(() {
          hours.fragments.add(HoursFragment.inactive(missingDays));
        });
      }
    } else {
      // The last one is inactive, but maybe we need to remove it or update weekdays.
      final inactive = hours.fragments[pos];
      if (inactive.weekdays is Weekdays ||
          inactive.weekdays is PublicHolidays) {
        final missingDays = hours.getMissingWeekdays();
        if (inactive.weekdays != missingDays) {
          setState(() {
            if (missingDays.isEmpty)
              hours.fragments.removeAt(pos);
            else
              hours.fragments[pos] = inactive.copyWith(weekdays: missingDays);
          });
        }
      }
    }
  }

  Widget buildFragmentsEditor(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: style
              ElevatedButton(
                // TODO: localize
                child: Text('As text', style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  setState(() {
                    isRaw = true;
                  });
                },
              ),
              SizedBox(width: 10.0),
              ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('24/7', style: TextStyle(fontSize: 20.0)),
                ),
                onPressed: () {
                  Navigator.pop(context, '24/7');
                },
              ),
            ],
          ),
        ),
        for (int i = 0; i < hours.fragments.length; i++)
          Card(
            // elevation: hours.fragments[i].active ? null : 0.0,
            color: hours.fragments[i].active ? null : Colors.white60,
            child: HoursFragmentEditor(
              fragment: hours.fragments[i],
              timeDefaults: timeDefaults,
              onDelete: i == 0 || !hours.fragments[i].active
                  ? null
                  : () {
                      setState(() {
                        final rem = hours.fragments.removeAt(i);
                        print('Removed $rem at $i');
                        for (int k = 0; k < hours.fragments.length; k++)
                          print('Fragment $k: ${hours.fragments[k]}');

                        // TODO: this inactive card copies interval from the removed fragment.
                        _updateInactiveCard();
                        print('After reshuffling:');
                        for (int k = 0; k < hours.fragments.length; k++)
                          print('Fragment $k: ${hours.fragments[k]}');
                      });
                    },
              onChange: (newFragment) {
                setState(() {
                  hours.fragments[i] = newFragment;
                  print('Changed at $i to $newFragment');
                  for (int k = 0; k < hours.fragments.length; k++)
                    print('Fragment $k: ${hours.fragments[k]}');
                  // Remove weekdays from other fragments.
                  for (int j = 0; j < hours.fragments.length; j++) {
                    if (i != j) {
                      final fragmentJ = hours.fragments[j];
                      final deduped = fragmentJ.weekdays
                          .removeIntersections(newFragment.weekdays);
                      if (deduped != fragmentJ.weekdays) {
                        if (deduped.isEmpty)
                          hours.fragments.removeAt(j);
                        else
                          hours.fragments[j] =
                              fragmentJ.copyWith(weekdays: deduped);
                      }
                    }
                  }
                  _updateInactiveCard();
                  print('After reshuffling:');
                  for (int k = 0; k < hours.fragments.length; k++)
                    print('Fragment $k: ${hours.fragments[k]}');
                });
                return true;
              },
            ),
          ),
        if (hours.fragments.length >= 2) SizedBox(height: 80.0),
      ],
    );
  }
}
