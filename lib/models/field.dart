// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:convert';

import 'package:eval_annotation/eval_annotation.dart';
import 'package:country_coder/country_coder.dart';
import 'package:every_door/fields/address.dart';
import 'package:every_door/fields/checkbox.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/direction.dart';
import 'package:every_door/fields/email.dart';
import 'package:every_door/fields/floor.dart';
import 'package:every_door/fields/height.dart';
import 'package:every_door/fields/hours.dart';
import 'package:every_door/fields/inline_combo.dart';
import 'package:every_door/fields/many_combo.dart';
import 'package:every_door/fields/name.dart';
import 'package:every_door/fields/phone.dart';
import 'package:every_door/fields/radio.dart';
import 'package:every_door/fields/section.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/fields/website.dart';
import 'package:every_door/fields/wheelchair.dart';
import 'package:every_door/fields/wiki_commons.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/amenity.dart';

/// Tag dependency definition. Basically a structure that defines
/// which tags and which values should or should not be preset in a tag list.
/// See https://github.com/ideditor/schema-builder/blob/main/README.md#prerequisitetag
@Bind()
class FieldPrerequisite {
  final String? key;
  final String? keyNot;
  final List<String>? values;
  final List<String>? valuesNot;

  const FieldPrerequisite({this.key, this.values, this.keyNot, this.valuesNot});

  bool matches(Map<String, String> tags) {
    if (keyNot != null) return !tags.containsKey(keyNot);
    if (key == null || !tags.containsKey(key)) return false;
    if (values != null) return values!.contains(tags[key]);
    if (valuesNot != null) return !valuesNot!.contains(tags[key]);
    return false;
  }

  factory FieldPrerequisite.fromJson(Map<String, dynamic> data) {
    final List<String> values = [];
    if (data.containsKey('values'))
      values.addAll(data['values']);
    else if (data.containsKey('value')) values.add(data['value']);

    final List<String> valuesNot = [];
    if (data.containsKey('valuesNot'))
      valuesNot.addAll(data['valuesNot']);
    else if (data.containsKey('valueNot')) valuesNot.add(data['valueNot']);

    return FieldPrerequisite(
      key: data['key'],
      keyNot: data['keyNot'],
      values: values.isNotEmpty ? values : null,
      valuesNot: valuesNot.isNotEmpty ? valuesNot : null,
    );
  }
}

/// Field definition. Each field type needs to subclass this one.
/// There are multiple examples in the `fields` directory.
@Bind(bridge: true, wrap: true)
abstract class PresetField {
  /// OSM tag key for this field. If the field does not use this
  /// attribute (or adds more keys, e.g. `contact:phone` for `phone`),
  /// do override the [hasRelevantKey] method.
  final String key;

  /// Field label to display alongside it. Can be overridden for
  /// a multi-line field in [buildWidgets].
  final String label;

  /// Icon for the field. Displayed only in the standard fields block
  /// in the full-page editor.
  final IconData? icon;

  /// Placeholder for text-based fields.
  final String? placeholder;

  /// Tag prerequisites for moving this field into the main block.
  /// If a field is in the "more fields" block, it's collapsed by default.
  /// When a prerequisite matches, it is moved to the main "fields" block.
  final FieldPrerequisite? prerequisite;

  /// Locations to determine whether to skip the field. It allows for
  /// country-specific fields.
  final LocationSet? locationSet;

  const PresetField({
    required this.key,
    required this.label,
    this.icon,
    this.placeholder,
    this.prerequisite,
    this.locationSet,
  });

  /// Builds a field-editing widget for the given [element].
  Widget buildWidget(OsmChange element);

  /// Tests whether the object has tags matching this field.
  /// The purpose is to check whether the field has a non-empty value.
  bool hasRelevantKey(Map<String, String> tags) => tags.containsKey(key);
}

@Bind()
class PresetFieldContext {
  late final String key;
  late final String label;
  late final String? placeholder;
  late final FieldPrerequisite? prerequisite;
  late final LocationSet? locationSet;

  PresetFieldContext(Map<String, dynamic> data) {
    key = data['key'];
    label = data['loc_label'] ?? data['label'] ?? data['name'] ?? key;
    placeholder = data['loc_placeholder'] ?? data['placeholder'];
    prerequisite = data.containsKey('prerequisiteTag')
        ? FieldPrerequisite.fromJson(data['prerequisiteTag'])
        : null;
    locationSet = data['locations'] == null
        ? null
        : LocationSet.fromJson(jsonDecode(data['locations']));
  }
}

PresetField? fieldForKey(Map<String, dynamic> data, List<ComboOption> options) {
  final ctx = PresetFieldContext(data);
  final String key = ctx.key;
  final String label = ctx.label;
  final placeholder = ctx.placeholder;
  final prerequisite = ctx.prerequisite;
  final locationSet = ctx.locationSet;

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
        capitalize: TextFieldCapitalize.asName,
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
    case 'fixme':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        showClearButton: true,
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

  return null;
}

PresetField fieldFromJson(Map<String, dynamic> data,
    {List<ComboOption> options = const []}) {
  final ctx = PresetFieldContext(data);
  final String key = ctx.key;
  final String label = ctx.label;
  final placeholder = ctx.placeholder;
  final prerequisite = ctx.prerequisite;
  final locationSet = ctx.locationSet;

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

  bool parseBool(dynamic data, [bool def = true]) {
    if (data is bool) return data;
    if (data is num) return data == 1;
    return def;
  }

  // List of types: https://github.com/ideditor/schema-builder#type
  String typ = data['typ'] ?? data['type'] ?? 'text';
  if (data['name'] == 'ref') typ = 'number'; // Patch some refs to be numbers
  switch (typ) {
    case 'text':
    case 'colour': // TODO: remove when we have a colour picker
    case 'date':
    case 'textarea':
      TextFieldCapitalize capitalize = kTextLowercase.contains(key)
          ? TextFieldCapitalize.no
          : TextFieldCapitalize.sentence;
      switch (data['capitalize']) {
        case 'no':
          capitalize = TextFieldCapitalize.no;
        case 'sentence':
          capitalize = TextFieldCapitalize.sentence;
        case 'asName':
          capitalize = TextFieldCapitalize.asName;
        case 'all':
          capitalize = TextFieldCapitalize.all;
      }
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        maxLines: typ == 'textarea' ? 4 : null,
        capitalize: capitalize,
        showClearButton: typ == 'colour' || parseBool(data['clearButton']),
      );
    case 'number':
    case 'roadspeed':
      return TextPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        prerequisite: prerequisite,
        locationSet: locationSet,
        keyboardType: TextInputType.number,
        showClearButton: true,
      );
    case 'tel':
      return PhonePresetField(
        key: key,
        label: label,
        prerequisite: prerequisite,
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
    case 'address':
      return AddressField(
        key: key,
        label: label,
      );
    case 'inline':
    case 'inlineCombo':
      return InlineComboPresetField(
        key: key,
        label: label,
        placeholder: placeholder,
        options: options,
        customValues: parseBool(data['custom_values'] ?? data['customValues']),
        numeric: parseBool(data['numeric'], true),
        // TODO: other things
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
        customValues: parseBool(data['custom_values'] ?? data['customValues']),
        snakeCase: parseBool(data['snake_case'] ?? data['snakeCase']),
        type: kComboMapping[typ]!,
        options: options,
      );
    case 'manyCombo':
      return ManyComboPresetField(
        keys: key.split('\\'),
        label: label,
        prerequisite: prerequisite,
        locationSet: locationSet,
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
        options: options,
        prerequisite: prerequisite,
      );
    case 'roadheight':
      return HeightPresetField(
        key: key,
        label: label,
        prerequisite: prerequisite,
      );
    case 'schedule':
      return HoursPresetField(
        key: key,
        label: label,
        prerequisite: prerequisite,
      );
    case 'label':
    case 'section':
      return SectionPresetField(label);
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
