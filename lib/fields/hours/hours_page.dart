import 'package:every_door/constants.dart';
import 'package:every_door/fields/hours/days_editors.dart';
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
  List<String> _cachedAround = [];
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
    _cachedAround =
        await data.getOpeningHoursAround(widget.element!.location, limit: 50);
    _updateTimeDefaults();
    setState(() {});
  }

  _updateTimeDefaults() {
    timeDefaults.updateFromAround(_cachedAround, hours.fragments);
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

  int _getInactiveCardPosition() {
    // We don't care about inactive fragments other than weekdays and holidays.
    return hours.fragments.indexWhere((fragment) =>
        !fragment.active &&
        (fragment.weekdays is Weekdays || fragment.weekdays is PublicHolidays));
  }

  _updateInactiveCard() {
    if (isRaw) return;
    int pos = _getInactiveCardPosition();
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
            if (missingDays.isEmpty) hours.fragments.removeAt(pos);
            /*else
              hours.fragments[pos] = inactive.copyWith(weekdays: missingDays);*/
          });
        }
      }
    }
  }

  Widget buildFragmentsEditor(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListView(
      controller: _scrollController,
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text(loc.fieldHoursAsText,
                    style: TextStyle(fontSize: 20.0)),
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
              onDelete: i == 0
                  ? null
                  : () {
                      setState(() {
                        hours.fragments.removeAt(i);
                        _updateInactiveCard();
                      });
                    },
              onChange: (newFragment) {
                setState(() {
                  hours.fragments[i] = newFragment;
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
                  _updateTimeDefaults();
                  _updateInactiveCard();
                });
                return true;
              },
            ),
          ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text(loc.fieldHoursNumberedWeekday,
                    style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  final newFragment =
                      HoursFragment.inactive(NumberedWeekday(0, {}));
                  int inactivePos = _getInactiveCardPosition();
                  setState(() {
                    if (inactivePos <= 0)
                      hours.fragments.add(newFragment);
                    else
                      hours.fragments.insert(inactivePos, newFragment);
                  });
                },
              ),
              SizedBox(width: 10.0),
              ElevatedButton(
                child: Text(loc.fieldHoursSpecificDays,
                    style: TextStyle(fontSize: 20.0)),
                onPressed: () async {
                  final date = await SpecificDaysPanel.pickDate(context);
                  if (date != null) {
                    final newFragment =
                        HoursFragment.inactive(SpecificDays({date}));
                    int inactivePos = _getInactiveCardPosition();
                    setState(() {
                      if (inactivePos <= 0)
                        hours.fragments.add(newFragment);
                      else
                        hours.fragments.insert(inactivePos, newFragment);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        if (hours.fragments.length >= 2) SizedBox(height: 80.0),
      ],
    );
  }
}
