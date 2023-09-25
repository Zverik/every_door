import 'dart:convert';

import 'package:country_coder/country_coder.dart';
import 'package:every_door/fields/checkbox.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/direction.dart';
import 'package:every_door/fields/email.dart';
import 'package:every_door/fields/floor.dart';
import 'package:every_door/fields/hours.dart';
import 'package:every_door/fields/name.dart';
import 'package:every_door/fields/phone.dart';
import 'package:every_door/fields/radio.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/fields/website.dart';
import 'package:every_door/fields/wheelchair.dart';
import 'package:every_door/fields/wiki_commons.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/amenity.dart';

class FieldPrerequisite {
  final String? key;
  final String? keyNot;
  final String? value;
  final String? valueNot;

  const FieldPrerequisite({this.key, this.value, this.keyNot, this.valueNot});

  bool matches(Map<String, String> tags) {
    if (keyNot != null) return !tags.containsKey(keyNot);
    if (key == null || !tags.containsKey(key)) return false;
    if (value != null) return tags[key] == value;
    if (valueNot != null) return tags[key] != valueNot;
    return false;
  }

  factory FieldPrerequisite.fromJson(Map<String, dynamic> data) {
    return FieldPrerequisite(
      key: data['key'],
      keyNot: data['keyNot'],
      value: data['value'],
      valueNot: data['valueNot'],
    );
  }
}

abstract class PresetField {
  final String key;
  final String label;
  final IconData? icon;
  final String? placeholder;
  final FieldPrerequisite? prerequisite;
  final LocationSet? locationSet;

  const PresetField({
    required this.key,
    required this.label,
    this.icon,
    this.placeholder,
    this.prerequisite,
    this.locationSet,
  });

  Widget buildWidget(OsmChange element);

  bool hasRelevantKey(Map<String, String> tags) => tags.containsKey(key);

  bool meetsPrerequisite(Map<String, String> tags) =>
      prerequisite != null && prerequisite!.matches(tags);
}

PresetField fieldFromJson(Map<String, dynamic> data,
    {List<ComboOption> options = const []}) {
  final String key = data['key'];
  final String label =
      data['loc_label'] ?? data['label'] ?? data['name'] ?? 'field';
  final placeholder = data['loc_placeholder'] ?? data['placeholder'];
  final prerequisite = data.containsKey('prerequisiteTag')
      ? FieldPrerequisite.fromJson(data['prerequisiteTag'])
      : null;
  final locationSet = data['locations'] == null
      ? null
      : LocationSet.fromJson(jsonDecode(data['locations']));

  // This switch should include at least every tag
  // from [PresetProvider.getStandardFields].
  switch (key) {
    case 'name':
      return NamePresetField(
        key: key,
        label: label,
        icon: Icons.format_quote,
        placeholder: placeholder,
        prerequisite: prerequisite,
      );
    case 'operator':
      return TextPresetField(
        key: key,
        label: label,
        icon: Icons.work_outlined,
        placeholder: placeholder,
        prerequisite: prerequisite,
      );
    case 'description':
      return TextPresetField(
        key: key,
        label: label,
        icon: Icons.comment_outlined,
        placeholder: placeholder,
        prerequisite: prerequisite,
        maxLines: 4,
      );
    case 'email':
      return EmailPresetField(
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
      );
    case 'phone':
      return PhonePresetField(
        key: key,
        label: label,
        prerequisite: prerequisite,
      );
    case 'website':
      return WebsiteField(label: label);
    case 'opening_hours':
      return HoursPresetField(
        key: key,
        label: label,
      );
    case 'payment:':
      return ComboPresetField(
        key: key,
        label: label,
        icon: Icons.credit_card,
        prerequisite: prerequisite,
        locationSet: locationSet,
        customValues: data['custom_values'] == 1,
        snakeCase: data['snake_case'] == 1,
        type: ComboType.multi,
        options: options,
      );
    case 'wheelchair':
      return WheelchairPresetField(label: label);
    case 'level':
      return FloorPresetField(label: label);
    case 'wikimedia_commons':
      return WikiCommonsPresetField(
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
      );
  }

  if (key.contains('opening_hours')) {
    return HoursPresetField(
      key: key,
      label: label,
      prerequisite: prerequisite,
    );
  }

  const kTextLowercase = {
    'colour',
    'connectivity',
    'distance',
    'duration',
    'geyser:height',
    'roof:colour',
    'vhf',
    'water_tank:volume',
  };

  // Patching the direction field.
  if ({'camera/direction', 'direction_point', 'direction'}
      .contains(data['name'])) {
    return DirectionPresetField(
        label: label, key: key, prerequisite: prerequisite);
  }

  // List of types: https://github.com/ideditor/schema-builder#type
  String typ = data['typ'] ?? 'text';
  if (data['name'] == 'ref') typ = 'number'; // Patch some refs to be numbers
  switch (typ) {
    case 'text':
    case 'colour': // TODO: remove when we have a colour picker
    case 'date':
    case 'textarea':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        maxLines: typ == 'textarea' ? 4 : null,
        capitalize: !kTextLowercase.contains(key),
      );
    case 'number':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        keyboardType: TextInputType.number,
      );
    case 'tel':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        keyboardType: TextInputType.phone,
      );
    case 'email':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        keyboardType: TextInputType.emailAddress,
      );
    case 'url':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        keyboardType: TextInputType.url,
      );
    case 'combo':
    case 'typeCombo':
    case 'multiCombo':
    case 'semiCombo':
      return ComboPresetField(
        key: key,
        label: label,
        prerequisite: prerequisite,
        locationSet: locationSet,
        customValues: data['custom_values'] == 1,
        snakeCase: data['snake_case'] == 1,
        type: kComboMapping[typ]!,
        options: options,
      );
    case 'radio':
      return RadioPresetField(
        key: key,
        label: label,
        options: options.map((e) => e.value).toList(),
        prerequisite: prerequisite,
        locationSet: locationSet,
      );
    case 'check':
    case 'defaultCheck':
      return CheckboxPresetField(
        key: key,
        label: label,
        tristate: typ == 'check',
        prerequisite: prerequisite,
      );
    default:
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
      );
  }
}
