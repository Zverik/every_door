import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter/material.dart';

class NotesModeDefinition extends BaseModeDefinition {
  NotesModeDefinition(super.ref);

  @override
  String get name => "notes";

  @override
  MultiIcon get icon => MultiIcon(fontIcon: Icons.note_alt);

  @override
  MultiIcon get iconOutlined => MultiIcon(fontIcon: Icons.note_alt_outlined);

  @override
  Future<void> updateNearest() async {
    // TODO
  }

  @override
  void updateFromJson(Map<String, dynamic> data) {
    // TODO: implement updateFromJson
  }
}