import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckboxPresetField extends PresetField {
  final bool tristate;

  CheckboxPresetField({
    required String key,
    required String label,
    IconData? icon,
    FieldPrerequisite? prerequisite,
    required this.tristate,
  }) : super(key: key, label: label, prerequisite: prerequisite, icon: icon);

  @override
  Widget buildWidget(OsmChange element) => CheckboxInputField(this, element);
}

class CheckboxInputField extends StatefulWidget {
  final CheckboxPresetField field;
  final OsmChange element;

  const CheckboxInputField(this.field, this.element);

  @override
  _CheckboxInputFieldState createState() => _CheckboxInputFieldState();
}

class _CheckboxInputFieldState extends State<CheckboxInputField> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final vYes = loc.fieldCheckboxYes;
    final vNo = loc.fieldCheckboxNo;

    String? value = widget.element[widget.field.key] == 'yes' ? 'yes' : null;
    if (value == null && widget.field.tristate) {
      if (widget.element[widget.field.key] == 'no') value = 'no';
    }

    return RadioField(
      options: widget.field.tristate ? const ['yes', 'no'] : const ['yes'],
      labels: [vYes, vNo],
      value: value,
      onChange: (newValue) {
        widget.element[widget.field.key] = newValue;
      },
    );
  }

  Widget buildCheckbox(BuildContext context) {
    // Disabled: radio field is better UX-wise.
    bool? value = widget.element[widget.field.key] == 'yes';
    if (!value && widget.field.tristate) {
      if (widget.element[widget.field.key] != 'no') value = null;
    }

    return Row(
      children: [
        Checkbox(
          tristate: widget.field.tristate,
          value: value,
          onChanged: (newValue) {
            setState(() {
              if (newValue == true) {
                widget.element[widget.field.key] = 'yes';
              } else {
                if (newValue == false && widget.field.tristate)
                  widget.element[widget.field.key] = 'no';
                else
                  widget.element.removeTag(widget.field.key);
              }
            });
          },
        ),
        Spacer(),
      ],
    );
  }
}
