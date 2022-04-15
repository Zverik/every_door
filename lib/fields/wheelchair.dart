import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WheelchairPresetField extends PresetField {
  WheelchairPresetField({
    required String label,
  }) : super(key: 'wheelchair', label: label, icon: Icons.accessible);

  @override
  Widget buildWidget(OsmChange element) => WheelchairInputField(this, element);
}

class WheelchairInputField extends StatefulWidget {
  final WheelchairPresetField field;
  final OsmChange element;

  const WheelchairInputField(this.field, this.element);

  @override
  State<WheelchairInputField> createState() => _WheelchairInputFieldState();
}

class _WheelchairInputFieldState extends State<WheelchairInputField> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final vYes = loc.fieldWheelchairYes;
    final vLimited = loc.fieldWheelchairLimited;
    final vNo = loc.fieldWheelchairNo;

    return RadioField(
      options: const ['yes', 'limited', 'no'],
      labels: [vYes, vLimited, vNo],
      value: widget.element[widget.field.key],
      onChange: (value) {
        setState(() {
          widget.element[widget.field.key] = value;
        });
      },
    );
  }
}
