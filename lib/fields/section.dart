import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

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
