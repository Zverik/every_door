// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';

class RadioPresetField extends PresetField {
  List<String> options;

  RadioPresetField({
    required super.key,
    required super.label,
    super.icon,
    super.prerequisite,
    super.locationSet,
    required this.options,
  });

  @override
  Widget buildWidget(OsmChange element) => RadioFieldIntl(this, element);
}

class RadioFieldIntl extends StatefulWidget {
  final RadioPresetField field;
  final OsmChange element;

  const RadioFieldIntl(this.field, this.element);

  @override
  State<RadioFieldIntl> createState() => _RadioFieldIntlState();
}

class _RadioFieldIntlState extends State<RadioFieldIntl> {
  @override
  Widget build(BuildContext context) {
    return RadioField(
      options: widget.field.options,
      value: widget.element[widget.field.key],
      onChange: (value) {
        setState(() {
          widget.element[widget.field.key] = value;
        });
      },
    );
  }
}
