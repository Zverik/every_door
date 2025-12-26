// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

enum TextFieldCapitalize { no, asName, sentence, all }

class TextPresetField extends PresetField {
  final TextInputType keyboardType;
  final TextFieldCapitalize capitalize;
  final int? maxLines;
  final bool showClearButton;

  const TextPresetField({
    required super.key,
    required super.label,
    super.icon,
    super.placeholder,
    super.prerequisite,
    super.locationSet,
    this.keyboardType = TextInputType.text,
    this.capitalize = TextFieldCapitalize.sentence,
    this.maxLines,
    this.showClearButton = false,
  });

  @override
  Widget buildWidget(OsmChange element) => TextInputField(this, element);
}

class TextInputField extends ConsumerStatefulWidget {
  final TextPresetField field;
  final OsmChange element;

  const TextInputField(this.field, this.element);

  @override
  ConsumerState createState() => _TextInputFieldState();
}

class _TextInputFieldState extends ConsumerState<TextInputField> {
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
    final loc = AppLocalizations.of(context)!;
    final value = widget.element[widget.field.key] ?? '';
    if (value != _controller.text.trim()) {
      // Hopefully that's not the time when we type a letter in the field.
      // TODO: only update when page is back from inactive?
      _controller.text = value;
    }

    // Force replace numeric keyboard with a better option.
    final editorSettings = ref.watch(editorSettingsProvider);
    var keyboardType = widget.field.keyboardType;
    if (keyboardType == TextInputType.number) {
      keyboardType = editorSettings.keyboardType;
    }

    TextCapitalization capitalization;
    switch (widget.field.capitalize) {
      case TextFieldCapitalize.no:
        capitalization = TextCapitalization.none;
        break;
      case TextFieldCapitalize.sentence:
        capitalization = TextCapitalization.sentences;
        break;
      case TextFieldCapitalize.all:
        capitalization = TextCapitalization.characters;
        break;
      case TextFieldCapitalize.asName:
        capitalization = ref.watch(osmDataProvider).capitalizeNames
            ? TextCapitalization.words
            : TextCapitalization.sentences;
        break;
    }

    final showClearButton = _controller.text.isNotEmpty && widget.field.showClearButton;

    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        decoration: InputDecoration(
          hintText: widget.field.placeholder,
          labelText: widget.field.icon != null ? widget.field.label : null,
          suffixIcon: showClearButton
              ? IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: loc.tagsDelete,
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      widget.element[widget.field.key] = '';
                    });
                  },
                )
              : null,
        ),
        style: kFieldTextStyle,
        maxLines: widget.field.maxLines ?? 1,
        minLines: 1,
        maxLength:
            (widget.element[widget.field.key] ?? '').length > 200 ? 255 : null,
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
