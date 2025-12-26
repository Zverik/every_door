// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';

class WikiCommonsPresetField extends PresetField {
  const WikiCommonsPresetField({
    String? key,
    String? label,
    super.icon,
    super.placeholder,
    super.prerequisite,
  }) : super(
            key: key ?? 'wikimedia_commons',
            label: label ?? 'Wikimedia Commons');

  @override
  Widget buildWidget(OsmChange element) => WikiCommonsInputField(this, element);
}

class WikiCommonsInputField extends StatefulWidget {
  final WikiCommonsPresetField field;
  final OsmChange element;

  const WikiCommonsInputField(this.field, this.element);

  @override
  State createState() => _WikiCommonsInputFieldState();
}

class _WikiCommonsInputFieldState extends State<WikiCommonsInputField> {
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

  final kReMarkup = RegExp(r'^\s*\[\[([^|\]]+)(?:\|.*)?\]\]\s*$');
  final kReURL = RegExp(r'^.*(https://commons\S+(?:File|Category)\S+\.[a-z]+)\s*$');

  String _removeWikiMarkup(String value) {
    final match = kReMarkup.matchAsPrefix(value);
    if (match != null) return match.group(1)!;
    final urlMatch = kReURL.firstMatch(value);
    if (urlMatch != null) return urlMatch.group(1)!;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.element[widget.field.key] ?? '';
    if (value != _controller.text.trim()) {
      // Hopefully that's not the time when we type a letter in the field.
      // TODO: only update when page is back from inactive?
      _controller.text = value;
    }

    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: widget.field.placeholder,
          labelText: widget.field.icon != null ? widget.field.label : null,
        ),
        style: kFieldTextStyle,
        maxLength: value.length > 200 ? 255 : null,
        onChanged: (value) {
          // On every keypress, since the focus can change at any minute.
          setState(() {
            widget.element[widget.field.key] = _removeWikiMarkup(value.trim());
          });
        },
      ),
    );
  }
}
