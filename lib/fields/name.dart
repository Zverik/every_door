import 'package:every_door/fields/text.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';

class NamePresetField extends TextPresetField {
  const NamePresetField(
      {required String key, required String label, required String placeholder, FieldPrerequisite? prerequisite})
      : super(key: key, label: label, placeholder: placeholder, prerequisite: prerequisite);

  @override
  buildWidget(OsmChange element) => TextInputField(this, element);
  // TODO: make a widget with language chooser
}