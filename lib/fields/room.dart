import 'package:every_door/fields/text.dart';
import 'package:flutter/material.dart';

class RoomPresetField extends TextPresetField {
  const RoomPresetField({String? label})
      : super(
          key: 'addr:door',
          label: label ?? 'Room Number',
          icon: Icons.door_front_door_outlined,
          keyboardType: TextInputType.number,
        );
}
