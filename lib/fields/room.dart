// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/fields/text.dart';
import 'package:flutter/material.dart';

class RoomPresetField extends TextPresetField {
  const RoomPresetField({String? label})
      : super(
          key: 'addr:door',
          label: label ?? 'Room Number',
          icon: Icons.door_front_door_outlined,
          keyboardType: TextInputType.visiblePassword,
        );
}
