// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';

class SectionPresetField extends PresetField {
  final String title;

  SectionPresetField(this.title) : super(key: '-', label: '');

  @override
  Widget buildWidget(OsmChange element) {
    return Container(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: Text(title), // TODO: formatting
    );
  }

  @override
  bool hasRelevantKey(Map<String, String> tags) => false;
}
