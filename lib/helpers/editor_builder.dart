import 'dart:ui' show Locale;

import 'package:every_door/fields/payment.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/generated/l10n/app_localizations.dart';
import 'package:every_door/helpers/editor_fields.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart' show TextInputType;

abstract class EditorFieldsBuilder {
  Future<List<EditorFields>> sortFields(OsmChange amenity, Preset preset);
}

class StandardEditorFieldsBuilder implements EditorFieldsBuilder {
  final PresetProvider presets;
  final Locale locale;
  final AppLocalizations loc;

  StandardEditorFieldsBuilder(this.presets, this.locale, this.loc);

  @override
  Future<List<EditorFields>> sortFields(
      OsmChange amenity, Preset preset) async {
    final stdFields = await buildStandard(amenity, preset);
    final otherFields =
        extractFields(amenity, preset, stdFields.map((f) => f.key).toSet());

    return [
      if (stdFields.isNotEmpty)
        EditorFields(
          fields: stdFields,
          iconLabels: true,
          mandatoryKeys: {
            'opening_hours',
            'level',
            'addr',
            'internet_access',
            'wheelchair',
            'phone',
            'payment'
          },
        ),
      if (otherFields.$1.isNotEmpty)
        EditorFields(
          fields: otherFields.$1,
        ),
      if (otherFields.$2.isNotEmpty)
        EditorFields(
          fields: otherFields.$2,
          title: loc.editorMoreFields,
        ),
    ];
  }

  Future<List<PresetField>> buildStandard(
      OsmChange amenity, Preset preset) async {
    if (preset.noStandard || !needsAddress(amenity.getFullTags())) return [];

    final bool needsStdFields =
        preset.fields.length <= 1 || needsStandardFields(preset);
    final stdFields = await presets.getStandardFields(locale, needsStdFields);

    // Remove the field for level if the object is a building.
    if (amenity['building'] != null) {
      stdFields.removeWhere((e) => e.key == 'level');
    }

    // Move some fields to stdFields if present.
    if (!needsStdFields) {
      final hasStdFields = stdFields.map((e) => e.key).toSet();
      for (final f in preset.fields) {
        if (PresetProvider.kStandardPoiFields.contains(f.key) &&
            !hasStdFields.contains(f.key)) {
          stdFields.add(f);
        }
        // Also move payment_multi.
        if (f.key == 'payment:' && !hasStdFields.contains('payment')) {
          stdFields.add(PaymentPresetField(label: 'Accept cards'));
        }
      }
    }

    // Add postcode to fields for buildings, moreFields for others.
    // The reason for this hack is that our addresses don't transfer postcodes.
    // But the addresses in the presets are indivisible, so we can't choose.
    final postcodeString = loc.buildingPostCode;
    final postcodeField = TextPresetField(
      key: "addr:postcode",
      label: postcodeString,
      keyboardType: TextInputType.visiblePassword,
      capitalize: TextFieldCapitalize.all,
    );
    final postcodeFirst = ElementKind.matchChange(
            amenity, [ElementKind.building, ElementKind.address]) !=
        ElementKind.unknown;
    if (postcodeFirst)
      preset.fields.add(postcodeField);
    else {
      preset.moreFields.insert(0, postcodeField);
    }

    // Add opening_hours to moreFields if it's not anywhere.
    if (!preset.fields.any((field) => field.key == 'opening_hours') &&
        !preset.moreFields.any((field) => field.key == 'opening_hours')) {
      final hoursField = await presets.getField('opening_hours', locale);
      preset.moreFields.insert(0, hoursField);
    }
    return stdFields;
  }

  /// Whether we should display address and floor fields in the editor.
  bool needsAddress(Map<String, String> tags) {
    final kind = ElementKind.match(tags);
    if ({ElementKind.amenity, ElementKind.building, ElementKind.address}
        .contains(kind)) return true;
    const kAmenityLoc = {'atm', 'vending_machine', 'parcel_locker'};
    return kAmenityLoc.contains(tags['amenity']);
  }

  bool needsStandardFields(Preset preset) {
    if (preset.type == PresetType.fixme) return true;
    if (preset.type == PresetType.taginfo) {
      return ElementKind.amenity.matchesTags(preset.addTags);
    }

    Set<String> allFields =
        (preset.fields + preset.moreFields).map((e) => e.key).toSet();
    return allFields.contains('opening_hours') && allFields.contains('phone');
  }

  (List<PresetField>, List<PresetField>) extractFields(
      OsmChange amenity, Preset preset, Set<String> hasStdFields) {
    hasStdFields.remove('internet_access');

    List<PresetField> fields;
    List<PresetField> moreFields = [];

    try {
      fields =
          preset.fields.where((f) => !hasStdFields.contains(f.key)).toList();
    } on StateError {
      fields = [];
    }

    final tags = amenity.getFullTags();
    for (final f in preset.moreFields) {
      if (hasStdFields.contains(f.key)) continue;
      final meetsPrerequisite = f.prerequisite?.matches(tags) ?? false;
      if (f.hasRelevantKey(tags) || meetsPrerequisite) {
        fields.add(f);
      } else {
        moreFields.add(f);
      }
    }

    return (fields, moreFields);
  }
}
