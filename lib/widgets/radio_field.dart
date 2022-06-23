import 'package:every_door/constants.dart';
import 'package:flutter/material.dart';

class RadioField extends StatefulWidget {
  final List<String> options;
  final List<String>? labels;
  final List<Widget>? widgetLabels;
  final String? value;
  final List<String>? values;
  final bool wrap;
  final bool multi;
  /// Keep the first options before all others. Warning: this implies the first option can never be a value.
  final bool keepFirst;
  final Function(String?)? onChange;
  final Function(List<String>)? onMultiChange;

  const RadioField({
    required this.options,
    this.labels,
    this.widgetLabels,
    this.value,
    this.values,
    this.wrap = false,
    this.multi = false,
    this.keepFirst = false,
    this.onChange,
    this.onMultiChange,
  });

  @override
  State createState() => _RadioFieldState();
}

class _RadioFieldState extends State<RadioField> {
  late List<Widget> labels;
  late String storedOptions;
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

  rebuildLabels() {
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
    bool pushFirst = getMergedLength() >= 30 && !widget.wrap;

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
            data: IconThemeData(
              color:
                  selected ? Theme.of(context).selectedRowColor : Colors.black,
            ),
            child: DefaultTextStyle(
              child: label,
              style: kFieldTextStyle.copyWith(
                color: selected
                    ? Theme.of(context).selectedRowColor
                    : Colors.black,
              ),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
