import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/combo_page.dart';

class ComboOption {
  final String value;
  final String? label;

  const ComboOption(this.value, [this.label]);

  @override
  String toString() => value;
}

enum ComboType {
  /// surface=asphalt / dirt / ...
  regular,

  /// building=yes (default) / apartments / ...
  type,

  /// cuisine=russian;pizza;coffee
  semi,

  /// currency:USD=yes + currency:EUR=yes
  multi,
}

const kComboMapping = <String, ComboType>{
  'combo': ComboType.regular,
  'typeCombo': ComboType.type,
  'multiCombo': ComboType.multi,
  'semiCombo': ComboType.semi,
};

class ComboPresetField extends PresetField {
  final ComboType type;
  final List<ComboOption> options;
  final bool customValues;
  final bool snakeCase;

  const ComboPresetField({
    required String key,
    required String label,
    IconData? icon,
    FieldPrerequisite? prerequisite,
    required this.type,
    required this.options,
    this.customValues = true,
    this.snakeCase = true,
  }) : super(key: key, label: label, icon: icon, prerequisite: prerequisite);

  bool get isSingularValue {
    return type == ComboType.regular || type == ComboType.type;
  }

  @override
  Widget buildWidget(OsmChange element) => isSingularValue
      ? SingularComboField(this, element)
      : MultiComboField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    if (type == ComboType.multi) {
      for (final k in tags.keys) if (k.startsWith(key)) return true;
      return false;
    }
    return tags.containsKey(key);
  }
}

class SingularComboField extends StatefulWidget {
  final ComboPresetField field;
  final OsmChange element;

  const SingularComboField(this.field, this.element);

  @override
  State<SingularComboField> createState() => _SingularComboFieldState();
}

class _SingularComboFieldState extends State<SingularComboField> {
  setComboValue(String value) {
    value = value.trim();
    if (value.isEmpty) return;
    switch (widget.field.type) {
      case ComboType.regular:
      case ComboType.type:
        widget.element[widget.field.key] = value;
        break;
      default:
        break;
    }
  }

  removeComboValue() {
    switch (widget.field.type) {
      case ComboType.regular:
        widget.element.removeTag(widget.field.key);
        break;
      case ComboType.type:
        widget.element[widget.field.key] = 'yes';
        break;
      default:
        // Do nothing
        break;
    }
  }

  openChooser() async {
    final List<String>? newValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComboChooserPage(
          widget.field,
          [widget.element[widget.field.key]].whereType<String>().toList(),
          allowEmpty: true,
        ),
      ),
    );
    if (newValue != null) {
      setState(() {
        if (newValue.isNotEmpty)
          setComboValue(newValue.first);
        else
          removeComboValue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      child: SizedBox(
        height: 40.0,
        child: Row(
          children: [
            Expanded(
                child: Text(
              widget.element[widget.field.key] ?? loc.fieldComboChoose + '...',
              style: widget.element[widget.field.key] != null
                  ? kFieldTextStyle
                  : kFieldTextStyle.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3)),
            )),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      onTap: () {
        openChooser();
      },
    );
  }
}

class MultiComboField extends StatefulWidget {
  final ComboPresetField field;
  final OsmChange element;

  const MultiComboField(this.field, this.element);

  @override
  State createState() => _MultiComboFieldState();
}

class _MultiComboFieldState extends State<MultiComboField> {
  List<String> getComboValues() {
    if (widget.field.type == ComboType.multi) {
      List<String> values = [];
      widget.element.getFullTags().forEach((key, value) {
        if (key.startsWith(widget.field.key) && value == 'yes')
          values.add(key.substring(widget.field.key.length));
      });
      return values;
    }

    final value = widget.element[widget.field.key];
    if (value == null) return [];
    switch (widget.field.type) {
      case ComboType.regular:
        return [value];
      case ComboType.type:
        return value == 'yes' ? [] : [value];
      case ComboType.semi:
        return value
            .split(';')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList();
      default:
        // This part is never called.
        return [value];
    }
  }

  setComboValues(List<String> values) {
    if (widget.field.type == ComboType.multi) {
      List<String> keysToDelete = [];
      widget.element.getFullTags().forEach((key, value) {
        if (key.startsWith(widget.field.key) && value == 'yes') {
          if (!values.contains(key.substring(widget.field.key.length)))
            keysToDelete.add(key);
        }
      });
      for (final k in keysToDelete) widget.element.removeTag(k);
      for (final k in values) widget.element[widget.field.key + k] = 'yes';
    } else if (values.isEmpty) {
      if (widget.field.type == ComboType.type)
        widget.element[widget.field.key] = 'yes';
      else
        widget.element.removeTag(widget.field.key);
      return;
    } else {
      switch (widget.field.type) {
        case ComboType.regular:
        case ComboType.type:
          widget.element[widget.field.key] = values.first;
          break;
        case ComboType.semi:
          String value = values.map((e) => e.trim()).join(';');
          if (value.length > 255) {
            // Cut at an appropriate value.
            value = value.substring(0, 255);
            final pos = value.lastIndexOf(';');
            if (pos > 0) value = value.substring(0, pos);
          }
          widget.element[widget.field.key] = value;
          break;
        default:
        // this is not called
      }
    }
  }

  removeComboValue(String value) {
    switch (widget.field.type) {
      case ComboType.regular:
        widget.element.removeTag(widget.field.key);
        break;
      case ComboType.type:
        widget.element[widget.field.key] = 'yes';
        break;
      case ComboType.semi:
        final values = getComboValues();
        if (values.remove(value.trim())) {
          if (values.isEmpty)
            widget.element.removeTag(widget.field.key);
          else
            widget.element[widget.field.key] = values.join(';');
        }
        break;
      case ComboType.multi:
        widget.element.removeTag(widget.field.key + value.trim());
        break;
    }
  }

  openChooser(List<String> values) async {
    final List<String>? newValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComboChooserPage(widget.field, values),
      ),
    );
    if (newValue != null) {
      setState(() {
        setComboValues(newValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = getComboValues();
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 6.0,
        runSpacing: 6.0,
        children: [
          for (final v in values)
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  color: Colors.blueGrey.shade50,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 6.0),
                      constraints: BoxConstraints(maxWidth: 150.0),
                      child: Text(v,
                          style: kFieldTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    Icon(Icons.close),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  removeComboValue(v);
                });
              },
            ),
          GestureDetector(
            onTap: () {
              openChooser(values);
            },
            child: Container(
              padding: EdgeInsets.all(1.0),
              color: Colors.blueGrey.shade50,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
