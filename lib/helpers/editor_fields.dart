import 'package:every_door/models/field.dart';

/// A group of fields in the editor. Only the [fields] list is mandatory.
class EditorFields {
  /// Title of the group. If present, an expansion tile is used to mark it.
  final String? title;

  /// If the title is present, whether to show the group folded
  /// when opening the editor.
  final bool collapsed;

  /// Whether to show labels as icons. Very few standard fields have labels set,
  /// so it might not work.
  final bool iconLabels;

  /// A list of fields to present in this group.
  final Iterable<PresetField> fields;

  /// Labels for fields, whose tag keys are in this set, will be colored
  /// green or red depending on whether they have values. The idea is that
  /// those fields need to be filled usually.
  final Set<String> mandatoryKeys;

  EditorFields({
    required this.fields,
    this.title,
    this.collapsed = true,
    this.iconLabels = false,
    this.mandatoryKeys = const {},
  });
}
