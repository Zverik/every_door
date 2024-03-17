import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';

class EmailPresetField extends PresetField {
  const EmailPresetField({
    String? label,
    IconData? icon,
    super.placeholder,
    super.prerequisite,
  }) : super(
            key: 'email',
            label: label ?? 'Email',
            icon: Icons.email_outlined);

  @override
  Widget buildWidget(OsmChange element) => EmailInputField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      tags.containsKey('email') || tags.containsKey('contact:email');
}

class EmailInputField extends StatefulWidget {
  final EmailPresetField field;
  final OsmChange element;

  const EmailInputField(this.field, this.element);

  @override
  State createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.element[widget.field.key] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.element.getContact('email') ?? '';
    if (value != _controller.text.trim()) {
      // Hopefully that's not the time when we type a letter in the field.
      // TODO: only update when page is back from inactive?
      _controller.text = value;
    }

    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: widget.field.placeholder,
          labelText: widget.field.icon != null ? widget.field.label : null,
        ),
        style: kFieldTextStyle,
        maxLength: value.length > 200 ? 255 : null,
        onChanged: (value) {
          // On every keypress, since the focus can change at any minute.
          setState(() {
            widget.element.setContact('email', value.trim());
          });
        },
      ),
    );
  }
}
