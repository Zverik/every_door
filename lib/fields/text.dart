import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';

class TextPresetField extends PresetField {
  final TextInputType keyboardType;
  final bool capitalize;
  final int? maxLines;

  const TextPresetField({
    required String key,
    required String label,
    IconData? icon,
    String? placeholder,
    FieldPrerequisite? prerequisite,
    this.keyboardType = TextInputType.text,
    this.capitalize = true,
    this.maxLines,
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.element[widget.field.key] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.element[widget.field.key];
    if (value != _controller.text.trim()) {
      // Hopefully that's not the time when we type a letter in the field.
      // TODO: only update when page is back from inactive?
      _controller.text = value ?? '';
    }

    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _controller,
        keyboardType: widget.field.keyboardType,
        textCapitalization: widget.field.capitalize
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        decoration: InputDecoration(
          hintText: widget.field.placeholder,
          labelText: widget.field.icon != null ? widget.field.label : null,
        ),
        style: kFieldTextStyle,
        maxLines: widget.field.maxLines ?? 1,
        minLines: 1,
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
