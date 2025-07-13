import 'hours_model.dart';
import 'package:every_door/helpers/counter.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class ChooserIntervalField extends StatefulWidget {
  final HoursInterval? interval;
  final Function(HoursInterval)? onChange;
  final HoursInterval? breakParent;
  final TimeDefaults? timeDefaults;

  const ChooserIntervalField({
    required this.interval,
    this.onChange,
    this.breakParent,
    this.timeDefaults,
  });

  @override
  State<ChooserIntervalField> createState() => _ChooserIntervalFieldState();
}

enum _ChooserState { complete, first, firstOnly, second }

class _ChooserIntervalFieldState extends State<ChooserIntervalField> {
  late _ChooserState _state;
  StringTime? start;
  StringTime? end;
  late TimeDefaults timeDefaults;
  bool editingHours = false;

  @override
  void initState() {
    super.initState();
    start = widget.interval?.start;
    end = widget.interval?.end;
    timeDefaults = widget.timeDefaults ?? TimeDefaults();

    if (start == null) {
      _state = _ChooserState.first;
    } else {
      _state = end == null ? _ChooserState.second : _ChooserState.complete;
    }
  }

  @override
  void didUpdateWidget(covariant ChooserIntervalField oldWidget) {
    if (widget.interval == null) {
      _state = _ChooserState.first;
      start = null;
      end = null;
    } else if (_state == _ChooserState.complete) {
      start = widget.interval?.start;
      end = widget.interval?.end;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Widget result;
    if (widget.breakParent == null) {
      if (_state == _ChooserState.complete) {
        result = Row(
          children: [
            Expanded(
              child: ClockDisplay(
                first: start!,
                onTap: widget.onChange == null
                    ? null
                    : () {
                        setState(() {
                          _state = _ChooserState.firstOnly;
                        });
                      },
                title: loc.fieldHoursOpens,
              ),
            ),
            Expanded(
              child: ClockDisplay(
                first: end!,
                onTap: widget.onChange == null
                    ? null
                    : () {
                        setState(() {
                          _state = _ChooserState.second;
                        });
                      },
                title: loc.fieldHoursCloses,
              ),
            ),
          ],
        );
      } else {
        if (!editingHours) {
          if (_state != _ChooserState.second) {
            result = GridChooser<StringTime>(
              title: loc.fieldHoursOpens,
              columns: 3,
              options: [
                // TODO: Remove options less than start time, but account for 24h rollover.
                // TODO: maybe end times dependent on start time range?
                for (final t in timeDefaults.defaultStartTimes)
                  GridChooserItem(
                    value: t,
                    label:
                        t.isRound ? t.toString().substring(0, 2) : t.toString(),
                    labelSuffix: t.isRound ? ':00-' : '-',
                  ),
              ],
              onChoose: (value) {
                setState(() {
                  start = value;
                  if (_state == _ChooserState.firstOnly) {
                    _state = _ChooserState.complete;
                    if (widget.onChange != null)
                      widget.onChange!(HoursInterval(start!, end!));
                  } else
                    _state = _ChooserState.second;
                });
              },
              onMoreTime: () {
                setState(() {
                  editingHours = true;
                });
              },
            );
          } else {
            result = GridChooser<StringTime>(
              title: '$start- ${loc.fieldHoursCloses}',
              columns: 3,
              options: [
                for (final t in timeDefaults.defaultEndTimes)
                  GridChooserItem(
                    value: t,
                    label: '-' +
                        (t.isRound
                            ? t.toString().substring(0, 2)
                            : t.toString()),
                    labelSuffix: t.isRound ? ':00' : null,
                  ),
              ],
              onChoose: (value) {
                setState(() {
                  end = value;
                  _state = _ChooserState.complete;
                  if (widget.onChange != null)
                    widget.onChange!(HoursInterval(start!, end!));
                });
              },
              onMoreTime: () {
                setState(() {
                  editingHours = true;
                });
              },
            );
          }
        } else {
          final isOpens = _state != _ChooserState.second;
          result = HoursMinutesChooser(
            big: true,
            // TODO: bracket hours accounting for 24h rollover?
            startHour: isOpens ? 0 : 1,
            endHour: 24,
            onChoose: (value) {
              setState(() {
                editingHours = false;
                if (isOpens)
                  start = value;
                else
                  end = value;
                if (_state == _ChooserState.second ||
                    _state == _ChooserState.firstOnly) {
                  _state = _ChooserState.complete;
                  if (widget.onChange != null)
                    widget.onChange!(HoursInterval(start!, end!));
                } else
                  _state = _ChooserState.second;
              });
            },
          );
        }
      }
    } else {
      if (_state == _ChooserState.complete) {
        result = ClockDisplay(
          title: loc.fieldHoursBreak,
          first: start!,
          second: end!,
        );
      } else {
        if (!editingHours) {
          if (_state != _ChooserState.second) {
            result = GridChooser<StringTime>(
              title: loc.fieldHoursBreak,
              columns: 3,
              options: [
                for (final t in timeDefaults.defaultBreakStarts)
                  GridChooserItem(
                    value: t,
                    label:
                        t.isRound ? t.toString().substring(0, 2) : t.toString(),
                    labelSuffix: t.isRound ? ':00-' : '-',
                  ),
              ],
              onChoose: (value) {
                setState(() {
                  start = value;
                  _state = _ChooserState.second;
                });
              },
              onMoreTime: () {
                setState(() {
                  editingHours = true;
                });
              },
            );
          } else {
            result = GridChooser<StringTime>(
              title: '$start- ${loc.fieldHoursBreak}',
              columns: 3,
              options: [
                for (final t in timeDefaults.defaultBreakEnds)
                  if (t > start!)
                    GridChooserItem(
                      value: t,
                      label: '-' +
                          (t.isRound
                              ? t.toString().substring(0, 2)
                              : t.toString()),
                      labelSuffix: t.isRound ? ':00' : null,
                    ),
              ],
              onChoose: (value) {
                setState(() {
                  end = value;
                  _state = _ChooserState.complete;
                  if (widget.onChange != null)
                    widget.onChange!(HoursInterval(start!, end!));
                });
              },
              onMoreTime: () {
                setState(() {
                  editingHours = true;
                });
              },
            );
          }
        } else {
          final parentIntervalGood =
              widget.breakParent!.start < widget.breakParent!.end;
          final isOpens = _state != _ChooserState.second;
          result = HoursMinutesChooser(
            key: ValueKey(_state),
            title: isOpens
                ? loc.fieldHoursBreak
                : '${loc.fieldHoursBreak} $start-',
            big: false,
            startHour: start?.hour ??
                (parentIntervalGood ? widget.breakParent!.start.hour + 1 : 0),
            endHour: parentIntervalGood ? widget.breakParent!.end.hour - 1 : 24,
            onChoose: (value) {
              if (isOpens) {
                setState(() {
                  start = value;
                  _state = _ChooserState.second;
                });
              } else {
                setState(() {
                  end = value;
                  _state = _ChooserState.complete;
                  editingHours = false;
                });
                if (widget.onChange != null)
                  widget.onChange!(HoursInterval(start!, end!));
              }
            },
          );
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      child: result,
    );
  }
}

class ClockDisplay extends StatelessWidget {
  final String title;
  final StringTime first;
  final StringTime? second;
  final VoidCallback? onTap;

  const ClockDisplay({
    required this.title,
    required this.first,
    this.second,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String time = second == null ? first.toString() : '$first-$second';
    final double baseSize = second != null ? 14.0 : 18.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
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

class HoursMinutesChooser extends StatefulWidget {
  final bool big;
  final Function(StringTime) onChoose;
  final int startHour;
  final int endHour;
  final String? title;

  const HoursMinutesChooser(
      {required this.onChoose,
      this.big = true,
      this.title,
      this.startHour = 0,
      this.endHour = 23,
      super.key});

  @override
  State<HoursMinutesChooser> createState() => _HoursMinutesChooserState();
}

class _HoursMinutesChooserState extends State<HoursMinutesChooser> {
  String? hour;

  @override
  Widget build(BuildContext context) {
    List<GridChooserItem<String>> options;
    if (hour == null) {
      options = List.generate(
          widget.endHour - widget.startHour + 1,
          (index) => GridChooserItem(
                value: (index + widget.startHour).toString().padLeft(2, "0"),
                label: (index + widget.startHour).toString(),
                labelSuffix: ':',
              ));
    } else {
      options = Iterable.generate(12, (i) => i * 5)
          .map((v) => v.toString().padLeft(2, '0'))
          .map((v) => GridChooserItem(
                value: v,
                label: int.parse(v) % 15 == 0 ? ':$v' : '',
                labelSuffix: int.parse(v) % 15 == 0 ? '' : ':$v',
              ))
          .toList();
    }

    final loc = AppLocalizations.of(context)!;
    final localTitle =
        hour == null ? loc.fieldHoursHour : '$hour: ${loc.fieldHoursMinute}';
    return GridChooser<String>(
      title: '${widget.title ?? ""} $localTitle'.trimLeft(),
      columns: hour == null ? 5 : 4,
      options: options,
      transpose: hour == null,
      onChoose: (value) {
        if (hour == null) {
          setState(() {
            hour = value;
          });
        } else {
          final time = StringTime('$hour:$value');
          widget.onChoose(time);
        }
      },
    );
  }
}

class GridChooser<T> extends StatelessWidget {
  final String title;
  final List<GridChooserItem<T>> options;
  final bool big;
  final Function(T) onChoose;
  final VoidCallback? onMoreTime;
  final int columns;
  final bool transpose;

  const GridChooser(
      {required this.title,
      required this.options,
      required this.onChoose,
      this.columns = 4,
      this.onMoreTime,
      this.transpose = false,
      this.big = true});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final rows = transpose ? columns : (options.length / columns).ceil();
    final double baseSize = !big ? 14.0 : 18.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: baseSize, color: Colors.grey),
              ),
              if (onMoreTime != null)
                IconButton(
                  icon: Icon(Icons.more_time),
                  tooltip: loc.fieldHoursChooseTime,
                  onPressed: onMoreTime,
                ),
            ],
          ),
          Flex(
            direction: transpose ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < options.length; i += rows)
                Flex(
                  direction: transpose ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int j = 0; j < rows; j++)
                      if (i + j < options.length)
                        TextButton(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: DefaultTextStyle(
                              child: options[i + j].buildWidget(),
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.black),
                            ),
                          ),
                          onPressed: () {
                            onChoose(options[i + j].value);
                          },
                        ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GridChooserItem<T> {
  final T value;
  final String label;
  final String? labelSuffix;

  const GridChooserItem(
      {required this.value, required this.label, this.labelSuffix});

  Widget buildWidget() {
    if (labelSuffix == null) return Text(label);
    return Text.rich(TextSpan(children: [
      TextSpan(text: label, style: TextStyle(color: Colors.black)),
      TextSpan(text: labelSuffix, style: TextStyle(color: Colors.black45)),
    ]));
  }
}

class TimeDefaults {
  // Taken from taginfo. Last two values are added when there are no other
  // options around.
  static final kInitialStartTimes = [
    '7:00',
    '8:00',
    '8:30',
    '9:00',
    '10:00',
    '11:00',
    '6:00',
    '9:30',
    '12:00',
    '7:30',
    '6:30',
  ];
  static final kInitialEndTimes = [
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '16:00',
    '24:00',
    '15:00',
    '18:30',
  ];
  static final kInitialBreakStarts = [
    '12:00',
    '12:30',
    '13:00',
    '14:00',
    '14:30',
    '15:00',
  ];
  static final kInitialBreakEnds = [
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '17:00',
  ];
  static final kInitialBreaks = [
    '12:00-13:00',
    '13:00-14:00',
    '12:00-14:00',
    '12:30-14:00',
  ];

  late List<StringTime> defaultStartTimes;
  late List<StringTime> defaultEndTimes;
  late List<HoursInterval> defaultBreaks;
  late List<StringTime> defaultBreakStarts;
  late List<StringTime> defaultBreakEnds;

  TimeDefaults({List<String>? around, Iterable<HoursFragment>? fragments}) {
    updateFromAround(around ?? [], fragments);
  }

  void updateFromAround(List<String> hoursAround,
      [Iterable<HoursFragment>? fragments]) {
    final kStart = RegExp(r'(?:^|Mo|Tu|We|Th|Fr|Sa|Su|;)\s*(\d?\d:\d\d)-');
    final kEnd = RegExp(r'-(\d?\d:\d\d)(?:$|;)');
    final kBreak = RegExp(r'-(\d?\d:\d\d),\s*(\d?\d:\d\d)-');

    final starts = Counter<String>();
    final ends = Counter<String>();
    final breaks = Counter<String>();
    final breakStarts = Counter<String>();
    final breakEnds = Counter<String>();

    for (final hours in hoursAround) {
      for (final start in kStart.allMatches(hours))
        starts.add(start.group(1)!.padLeft(5, '0'));
      for (final end in kEnd.allMatches(hours))
        ends.add(end.group(1)!.padLeft(5, '0'));
      for (final break_ in kBreak.allMatches(hours)) {
        breaks.add(break_.group(1)!.padLeft(5, '0') +
            '-' +
            break_.group(2)!.padLeft(5, '0'));
        breakStarts.add(break_.group(1)!.padLeft(5, '0'));
        breakEnds.add(break_.group(2)!.padLeft(5, '0'));
      }
    }

    if (fragments != null) {
      for (final fragment in fragments) {
        if (fragment.active && fragment.interval != null) {
          starts.add(fragment.interval!.start.toString(), 10);
          ends.add(fragment.interval!.end.toString(), 10);
          breaks.addAll(fragment.breaks.map((b) => b.toString()), 10);
          breakStarts.addAll(
              fragment.breaks.map((b) => b.start.toString()), 10);
          breakEnds.addAll(fragment.breaks.map((b) => b.end.toString()), 10);
        }
      }
    }

    defaultStartTimes = _addFromAround(
      kInitialStartTimes.map((s) => StringTime(s)),
      starts.mostOccurentItems(cutoff: 4).map((s) => StringTime(s)),
      9,
    );
    defaultEndTimes = _addFromAround(
      kInitialEndTimes.map((s) => StringTime(s)),
      ends.mostOccurentItems(cutoff: 4).map((s) => StringTime(s)),
      9,
    );
    defaultBreaks = _addFromAround(
      kInitialBreaks.map((s) => HoursInterval.parse(s)),
      breaks.mostOccurentItems(cutoff: 3).map((s) => HoursInterval.parse(s)),
      4,
    );
    defaultBreakStarts = _addFromAround(
      kInitialBreakStarts.map((s) => StringTime(s)),
      breakStarts.mostOccurentItems(cutoff: 3).map((s) => StringTime(s)),
      6,
    );
    defaultBreakEnds = _addFromAround(
      kInitialBreakEnds.map((s) => StringTime(s)),
      breakEnds.mostOccurentItems(cutoff: 3).map((s) => StringTime(s)),
      6,
    );
  }

  List<T> _addFromAround<T>(
      Iterable<T> base, Iterable<T> around, int targetCount,
      [int? aroundCount]) {
    aroundCount ??= (targetCount / 4).ceil();
    final timesToAdd = base
        .take(targetCount - aroundCount)
        .followedBy(around)
        .followedBy(base.skip(targetCount - aroundCount));
    final resultSet = <T>{};
    for (final item in timesToAdd) {
      resultSet.add(item);
      if (resultSet.length >= targetCount) break;
    }
    final result = List.of(resultSet);
    result.sort();
    return result;
  }
}
