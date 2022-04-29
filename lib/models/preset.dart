import 'dart:convert';
import 'package:country_coder/country_coder.dart';
import 'package:every_door/fields/name.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';

class Preset {
  final List<PresetField> fields; // Always open
  final List<PresetField> moreFields; // Open when set or requested
  final bool onArea; // Can this preset be used on a area?
  final Map<String, String> addTags; // Added when preset is chosen
  final Map<String, String?> removeTags; // Removed when preset is replaced
  final String id;
  final String name;
  final String? _subtitle;
  final String? icon;
  final LocationSet? locationSet;
  final bool fromNSI;
  final bool isFixme;

  // Hope we don't resort to using this
  static const defaultPreset = Preset(
    id: 'default',
    name: 'Amenity',
    fields: [NamePresetField(key: 'name', label: 'Name', placeholder: '')],
    addTags: {},
  );

  const Preset({
    required this.id,
    this.fields = const [],
    this.moreFields = const [],
    this.onArea = true,
    required this.addTags,
    this.removeTags = const {},
    required this.name,
    String? subtitle,
    this.icon,
    this.locationSet,
    this.fromNSI = false,
    this.isFixme = false,
  }) : _subtitle = subtitle;

  factory Preset.fixme(String title, {String? subtitle}) {
    return Preset(
      id: 'fixme $title',
      fields: const [],
      moreFields: const [],
      onArea: true,
      addTags: {
        'amenity': 'fixme',
        'fixme': 'type',
        'fixme:type': title,
      },
      removeTags: const {},
      name: title,
      subtitle: subtitle ?? 'fixme',
      icon: null,
      locationSet: null,
      fromNSI: false,
      isFixme: true,
    );
  }

  static Map<String, String?> decodeTags(Map<String, dynamic>? tags) {
    if (tags == null) return const {};
    return tags.map(
        (key, value) => MapEntry(key, value == '*' ? null : value.toString()));
  }

  static Map<String, String> decodeTagsSkipNull(Map<String, dynamic>? tags) {
    tags = decodeTags(tags);
    if (tags.isNotEmpty) {
      tags.removeWhere((key, value) => value == null);
    }
    return tags.cast<String, String>();
  }

  factory Preset.fromJson(Map<String, dynamic> data) {
    // Note: does not fill fields.
    return Preset(
      id: data['name'],
      onArea: data['can_area'] == 1,
      addTags: decodeTagsSkipNull(
          data['add_tags'] != null ? jsonDecode(data['add_tags']) : null),
      removeTags: decodeTagsSkipNull(
          data['remove_tags'] != null ? jsonDecode(data['remove_tags']) : null),
      icon: data['icon'],
      locationSet: data['locations'] == null
          ? null
          : LocationSet.fromJson(jsonDecode(data['locations'])),
      name: data['loc_name'],
    );
  }

  factory Preset.fromNSIJson(Map<String, dynamic> data) {
    return Preset(
      id: data['id'],
      name: data['name'],
      subtitle: data['preset_ref'],
      addTags: decodeTagsSkipNull(jsonDecode(data['tags'])),
      locationSet: data['locations'] == null
          ? null
          : LocationSet.fromJson(jsonDecode(data['locations'])),
      fromNSI: true,
    );
  }

  String get subtitle {
    if (_subtitle != null) return _subtitle!;
    final key = getMainKey(addTags);
    if (key == null) return '';
    return '$key=${addTags[key]}';
  }

  Preset withFields(List<PresetField> fields, List<PresetField> moreFields) {
    return Preset(
      id: id,
      fields: fields,
      moreFields: moreFields,
      onArea: onArea,
      addTags: addTags,
      removeTags: removeTags,
      name: name,
      subtitle: _subtitle,
      icon: icon,
      fromNSI: fromNSI,
    );
  }

  Preset withSubtitle(String subtitle) {
    return Preset(
      id: id,
      fields: fields,
      moreFields: moreFields,
      onArea: onArea,
      addTags: addTags,
      removeTags: removeTags,
      name: name,
      subtitle: subtitle,
      icon: icon,
      fromNSI: fromNSI,
    );
  }

  doAddTags(OsmChange change) {
    final mainKey = getMainKey(addTags);
    addTags.forEach((key, value) {
      if (value == '*') return;
      if (change[key] != null && mainKey != key) return;
      change[key] = value;
    });
  }

  doRemoveTags(OsmChange change) {
    removeTags.forEach((key, value) {
      if (change[key] != null) {
        if (value == '*' || value == change[key]) change.removeTag(key);
      }
    });
  }

  @override
  bool operator ==(Object other) => other is Preset && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Preset(id="$id", name="$name", can_area=$onArea, nsi=$fromNSI)';
}
