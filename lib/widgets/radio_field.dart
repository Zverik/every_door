import 'package:every_door/constants.dart';
import 'package:flutter/material.dart';

/// Field with multiple choices, presented in a row. It is a part of many
/// standard fields: combo, radio, checkbox.
class RadioField extends StatefulWidget {
  /// Which options — meaning tag values — are available.
  final List<String> options;

  /// Labels for options. If preset, they replace values in presentation.
  final List<String>? labels;

  /// Widget labels: for example, images. Has preference over [labels].
  /// Basically the latter are wrapped in [Text] and merged into a single list.
  final List<Widget>? widgetLabels;

  /// The currently present tag value. Can be empty of course. Can also contain
  /// several values joined by a semicolon ("yes;no").
  final String? value;

  /// Instead of [value], specify this when the field expects multiple values.
  /// See [multi].
  final List<String>? values;

  /// If set, the field will wrap at the edge of the screen. Otherwise it
  /// will be horizontally scrollable.
  final bool wrap;

  /// Whether to allow multi-selection.
  final bool multi;

  /// Whether to keep the order of options. If not set, and the options do not
  /// fit on the screen, when tapping one, it is moved to the front. This
  /// might be unwelcome, for example, with numeric options.
  final bool keepOrder;

  /// Keep the first options before all others. Use only for a fake first option,
  /// e.g. that launches a dialog. Warning: this implies the first option can never be a value.
  final bool keepFirst;

  /// A callback function for when the value (singular) changes. If multiple
  /// values can be chosen, they will be joined with a semicolon.
  final Function(String?)? onChange;

  /// A callback function for multiple changed values, if enabled.
  final Function(List<String>)? onMultiChange;

  /// Creates a widget. Only [options] are technically required, but you
  /// should also specify either of [value] or [values], and a callback
  /// function between [onChange] and [onMultiChange].
  const RadioField({
    required this.options,
    this.labels,
    this.widgetLabels,
    this.value,
    this.values,
    this.wrap = false,
    this.multi = false,
    this.keepFirst = false,
    this.keepOrder = false,
    this.onChange,
    this.onMultiChange,
  });

  @override
  State createState() => _RadioFieldState();
}

class _RadioFieldState extends State<RadioField> {
  /// Pre-built list of widget labels for every option. Guaranteed to be
  /// the same length as [widget.options].
  late List<Widget> labels;

  /// This is a copy of [widget.options] for verifying for a change
  /// in [didUpdateWidget].
  late String storedOptions;

  /// We use this to animate scrolling to the beginning when an option
  /// was tapped, and it slides to the first position.
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    storedOptions = widget.options.join(';');
    rebuildLabels();
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void rebuildLabels() {
    labels = [];
    for (int i = 0; i < widget.options.length; i++) {
      if (i < (widget.widgetLabels?.length ?? 0)) {
        labels.add(widget.widgetLabels![i]);
      } else {
        String label = widget.options[i];
        if (i < (widget.labels?.length ?? 0)) {
          label = widget.labels![i];
        }
        labels.add(Text(label));
      }
    }
  }

  int getMergedLength() {
    int length = 0;
    for (int i = 0; i < widget.options.length; i++) {
      if (i < (widget.widgetLabels?.length ?? 0)) {
        length += 3;
      } else if (i < (widget.labels?.length ?? 0)) {
        length += widget.labels![i].length;
      } else {
        length += widget.options[i].length;
      }
    }
    return length + widget.options.length * 3;
  }

  @override
  void didUpdateWidget(covariant RadioField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newOptions = widget.options.join(';');
    if (newOptions != storedOptions) {
      rebuildLabels();
      storedOptions = newOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values =
        widget.values ?? widget.value?.split(';').map((s) => s.trim()) ?? [];
    final labelsForValues = <String, Widget>{};
    for (final value in values) {
      int idx = widget.options.indexOf(value);
      labelsForValues[value] = idx >= 0 ? labels[idx] : Text(value);
    }
    bool pushFirst =
        !widget.keepOrder && !widget.wrap && getMergedLength() >= 35;

    final pills = [
      if (widget.keepFirst && widget.options.isNotEmpty)
        RadioPill(
          value: widget.options.first,
          label: labels[0],
          selected: values.contains(widget.options.first),
          onTap: () {
            if (widget.onChange != null) widget.onChange!(widget.options.first);
            if (widget.onMultiChange != null)
              widget.onMultiChange!([widget.options.first]);
          },
        ),
      for (final value in values)
        if (pushFirst || !widget.options.contains(value))
          RadioPill(
            value: value,
            label: labelsForValues[value]!,
            selected: true,
            onTap: () {
              final newValues = values.where((v) => v != value).toList();
              if (widget.onChange != null)
                widget
                    .onChange!(newValues.isEmpty ? null : newValues.join(';'));
              if (widget.onMultiChange != null)
                widget.onMultiChange!(newValues);
            },
          ),
      for (final entry in widget.options.asMap().entries)
        if ((!pushFirst || !values.contains(entry.value)) &&
            (!widget.keepFirst || entry.key != 0))
          RadioPill(
            value: entry.value,
            label: labels[entry.key],
            selected: values.contains(entry.value),
            onTap: () {
              final newValues = values.where((v) => v != entry.value).toList();
              if (newValues.length == values.length) {
                if (newValues.isEmpty || widget.multi)
                  newValues.add(entry.value);
                else
                  newValues.last = entry.value;
              }
              if (widget.onChange != null)
                widget
                    .onChange!(newValues.isEmpty ? null : newValues.join(';'));
              if (widget.onMultiChange != null)
                widget.onMultiChange!(newValues);
              if (pushFirst) {
                scrollController.animateTo(0.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
          ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: !widget.wrap
          ? SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(children: pills),
            )
          : Wrap(children: pills),
    );
  }
}

class RadioPill extends StatelessWidget {
  final String value;
  final Widget label;
  final bool selected;
  final VoidCallback onTap;

  const RadioPill(
      {required this.value,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        selected ? Theme.of(context).colorScheme.onPrimary : Colors.black;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).primaryColor : null,
            border: Border.all(),
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: IconTheme(
            data: IconThemeData(color: iconColor),
            child: DefaultTextStyle(
              child: label,
              style: kFieldTextStyle.copyWith(color: iconColor),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
