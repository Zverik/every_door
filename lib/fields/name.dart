import 'package:every_door/constants.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';

/// Language-aware field editor. E.g. name + name:en + ...
class NamePresetField extends PresetField {
  final bool capitalize;

  const NamePresetField({
    required String key,
    required String label,
    IconData? icon,
    required String placeholder,
    FieldPrerequisite? prerequisite,
    this.capitalize = true,
  }) : super(
            key: key,
            label: label,
            icon: icon,
            placeholder: placeholder,
            prerequisite: prerequisite);

  @override
  buildWidget(OsmChange element) => NameInputField(this, element);
}

class NameInputField extends StatefulWidget {
  final NamePresetField field;
  final OsmChange element;

  const NameInputField(this.field, this.element);

  @override
  State<NameInputField> createState() => _NameInputFieldState();
}

class _NameInputFieldState extends State<NameInputField> {
  final _controllers = <String, TextEditingController>{};
  final languages = [];

  @override
  void initState() {
    super.initState();
    _controllers[''] =
        TextEditingController(text: widget.element[widget.field.key] ?? '');
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main suffix-less field.
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers[''],
                textCapitalization: widget.field.capitalize
                    ? TextCapitalization.sentences
                    : TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: widget.field.placeholder,
                  labelText:
                      widget.field.icon != null ? widget.field.label : null,
                ),
                style: kFieldTextStyle,
                onChanged: (value) {
                  // On every keypress, since the focus can change at any minute.
                  setState(() {
                    widget.element[widget.field.key] = value.trim();
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.language),
            ),
          ],
        ),
      ],
    );
  }
}
