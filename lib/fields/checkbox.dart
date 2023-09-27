import 'package:every_door/fields/combo.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckboxPresetField extends PresetField {
  final bool tristate;
  List<ComboOption>? options;

  CheckboxPresetField({
    required String key,
    required String label,
    IconData? icon,
    FieldPrerequisite? prerequisite,
    required this.tristate,
    this.options,
  }) : super(key: key, label: label, prerequisite: prerequisite, icon: icon);

  @override
  Widget buildWidget(OsmChange element) => CheckboxInputField(this, element);
}

class CheckboxInputField extends StatefulWidget {
  final CheckboxPresetField field;
  final OsmChange element;

  const CheckboxInputField(this.field, this.element);

  @override
  State createState() => _CheckboxInputFieldState();
}

class _CheckboxInputFieldState extends State<CheckboxInputField> {
  @override
  Widget build(BuildContext context) {
    const falseValues = {'no', 'false', '0', 'off'};
    final loc = AppLocalizations.of(context)!;
    final vYes = widget.field.options?.length == 2
        ? (widget.field.options![1].label ?? loc.fieldCheckboxYes)
        : loc.fieldCheckboxYes;
    final vNo = loc.fieldCheckboxNo;

    final keyValue = widget.element[widget.field.key];
    String? value = falseValues.contains(keyValue)
            ? 'no'
            : keyValue;
    String yesValue = widget.field.options?.length == 2
        ? widget.field.options![1].value
        : 'yes';

    return RadioField(
      options: widget.field.tristate ? [yesValue, 'no'] : [yesValue],
      labels: [vYes, vNo],
      value: value,
      onChange: (newValue) {
        widget.element[widget.field.key] = newValue;
      },
    );
  }
}
