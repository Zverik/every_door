// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/fields/combo.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';

class ManyComboPresetField extends PresetField {
  final List<String> keys;
  final List<ComboOption> options;

  ManyComboPresetField({
    required this.keys,
    required super.label,
    super.icon,
    super.prerequisite,
    super.locationSet,
    required this.options,
  }) : super(key: keys.first);

  @override
  Widget buildWidget(OsmChange element) => ManyComboField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      keys.any((k) => tags.containsKey(k));
}

class ManyComboField extends StatefulWidget {
  final ManyComboPresetField field;
  final OsmChange element;

  const ManyComboField(this.field, this.element);

  @override
  State createState() => _ManyComboFieldState();
}

class _ManyComboFieldState extends State<ManyComboField> {
  List<String> getComboValues() {
    List<String> values = [];
    widget.element.getFullTags().forEach((key, value) {
      if (widget.field.keys.contains(key) && value != 'no') values.add(key);
    });
    return values;
  }

  void setComboValues(List<String> values) {
    List<String> keysToDelete = [];
    widget.element.getFullTags().forEach((key, value) {
      if (widget.field.keys.contains(key) && value != 'no') {
        if (!values.contains(key)) keysToDelete.add(key);
      }
    });
    for (final k in keysToDelete) widget.element.removeTag(k);
    for (final k in values) widget.element[k] = 'yes';
  }

  void removeComboValue(String value) {
    widget.element.removeTag(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.field.options.take(3).map((o) => o.value).toList();
    final labels = widget.field.options
        .take(3)
        .map((o) => o.label?.toLowerCase() ?? o.value)
        .toList();

    return RadioField(
      options: options,
      labels: labels,
      values: getComboValues(),
      multi: true,
      onMultiChange: (values) {
        setComboValues(values);
      },
    );
  }
}
