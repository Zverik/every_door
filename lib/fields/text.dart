import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';

class TextPresetField extends PresetField {
  final TextInputType keyboardType;
  final bool capitalize;

  const TextPresetField({
    required String key,
    required String label,
    IconData? icon,
    String? placeholder,
    FieldPrerequisite? prerequisite,
    this.keyboardType = TextInputType.text,
    this.capitalize = true,
  }) : super(
            key: key,
            label: label,
            icon: icon,
            placeholder: placeholder,
            prerequisite: prerequisite);

  @override
  Widget buildWidget(OsmChange element) => TextInputField(this, element);
}

class TextInputField extends StatefulWidget {
  final TextPresetField field;
  final OsmChange element;

  const TextInputField(this.field, this.element);

  @override
  State createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  @override
  Widget build(BuildContext context) {
    final value = widget.element[widget.field.key];

    return Container(
      decoration: BoxDecoration(
        // color: value == null ? kFieldColor : Colors.greenAccent,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: TextFormField(
        initialValue: value,
        keyboardType: widget.field.keyboardType,
        textCapitalization: widget.field.capitalize
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        decoration: InputDecoration(
          // fillColor: value == null ? kFieldColor : Colors.greenAccent,
          // hintText: widget.field.placeholder,
          labelText: widget.field.icon != null ? widget.field.label : null,
        ),
        style: kFieldTextStyle,
        onChanged: (value) {
          // On every keypress, since the focus can change at any minute.
          setState(() {
            widget.element[widget.field.key] = value.trim();
          });
        },
      ),
    );
  }
}
