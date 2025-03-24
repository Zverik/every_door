import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:flutter/material.dart';

class InlineComboPresetField extends PresetField {
  final List<ComboOption> options;
  final bool customValues;
  final bool numeric;

  InlineComboPresetField({
    required super.key,
    required super.label,
    required this.options,
    this.customValues = false,
    this.numeric = true,
  });

  @override
  Widget buildWidget(OsmChange element) => InlineComboField(this, element);
}

class InlineComboField extends StatefulWidget {
  final InlineComboPresetField field;
  final OsmChange element;

  const InlineComboField(this.field, this.element, {super.key});

  @override
  State<InlineComboField> createState() => _InlineComboFieldState();
}

class _InlineComboFieldState extends State<InlineComboField> {
  bool manual = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  bool validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    final levels = int.tryParse(value.trim());
    if (levels == null) return false;
    return levels >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final options = List.of(widget.field.options);
    if (widget.field.customValues) {
      options.add(ComboOption(kManualOption));
    }

    if (manual) {
      return TextFormField(
        keyboardType:
            widget.field.numeric ? TextInputType.number : TextInputType.text,
        style: kFieldTextStyle,
        initialValue: widget.element[widget.field.key],
        focusNode: _focusNode,
        validator: (value) => !widget.field.numeric || validateNumber(value)
            ? null
            : 'Should be a number',
        onChanged: (value) {
          setState(() {
            widget.element[widget.field.key] = value.trim();
          });
        },
      );
    } else {
      return RadioField(
        options: options.map((o) => o.value).toList(),
        labels: options.map((o) => o.label ?? o.value).toList(),
        widgetLabels: options
            .map((o) => o.widget ?? Text(o.label ?? o.value))
            .toList(),
        value: widget.element[widget.field.key],
        onChange: (value) {
          setState(() {
            if (value == kManualOption) {
              widget.element.removeTag(widget.field.key);
              manual = true;
              _focusNode.requestFocus();
            } else {
              widget.element[widget.field.key] = value;
            }
          });
        },
      );
    }
  }
}
