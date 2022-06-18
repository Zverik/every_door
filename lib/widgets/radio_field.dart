import 'package:every_door/constants.dart';
import 'package:flutter/material.dart';

class RadioField extends StatefulWidget {
  final List<String> options;
  final List<String>? labels;
  final List<Widget>? widgetLabels;
  final String? value;
  final Function(String?) onChange;

  const RadioField({
    required this.options,
    this.labels,
    this.widgetLabels,
    this.value,
    required this.onChange,
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
    Widget? labelForValue;
    if (widget.value != null) {
      int idx = widget.options.indexOf(widget.value!);
      labelForValue = idx >= 0 ? labels[idx] : Text(widget.value!);
    }
    bool pushFirst = getMergedLength() >= 30;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (widget.value != null &&
                (pushFirst || !widget.options.contains(widget.value)))
              RadioPill(
                value: widget.value!,
                label: labelForValue!,
                selected: true,
                onTap: () {
                  widget.onChange(null);
                },
              ),
            for (final entry in widget.options.asMap().entries)
              if (!pushFirst || entry.value != widget.value)
                RadioPill(
                  value: entry.value,
                  label: labels[entry.key],
                  selected: entry.value == widget.value,
                  onTap: () {
                    widget.onChange(
                        entry.value == widget.value ? null : entry.value);
                    scrollController.animateTo(0.0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeOut);
                  },
                ),
          ],
        ),
      ),
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
