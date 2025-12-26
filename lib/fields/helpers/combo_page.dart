// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class ComboChooserPage extends StatefulWidget {
  final ComboPresetField field;
  final List<String> values;
  final bool allowEmpty;

  const ComboChooserPage(this.field, this.values, {this.allowEmpty = true});

  @override
  State createState() => _ComboChooserPageState();
}

class _ComboChooserPageState extends State<ComboChooserPage> {
  String filter = '';
  late List<String> values;
  late final List<ComboOption> missingOptions;

  @override
  void initState() {
    super.initState();
    values = List.of(widget.values);
    missingOptions = widget.values
        .where(
            (value) => !widget.field.options.any((opt) => opt.value == value))
        .map((e) => ComboOption(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.field.label} (${widget.field.key})'),
      ),
      body: widget.field.customValues
          ? buildCustom(context)
          : buildChooser(context),
      floatingActionButton: widget.field.isSingularValue
          ? null
          : FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, values);
              },
            ),
    );
  }

  Widget buildCustom(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextField(
          autofocus: widget.field.options.length > 12,
          onChanged: (value) {
            if (widget.field.snakeCase) {
              value = value.toLowerCase().trim().replaceAll(' ', '_');
            }
            setState(() {
              filter = value.trim();
            });
          },
          decoration: InputDecoration(
            fillColor: Theme.of(context).canvasColor,
            filled: true,
          ),
          onSubmitted: (value) {
            final newValue = value.trim();
            if (newValue.isEmpty) return;
            Navigator.pop(
                context, values.contains(value) ? values : ([value] + values));
          },
        ),
        Expanded(child: buildChooser(context)),
      ],
    );
  }

  Widget buildChooser(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    var options = missingOptions + List.of(widget.field.options);
    if (filter.isNotEmpty) {
      // Prune options
      final nFilter = normalizeString(filter);
      options = options
          .where((element) =>
              normalizeString(element.value).contains(nFilter) ||
              (element.label != null &&
                  normalizeString(element.label ?? '').contains(nFilter)))
          .toList();
      if (widget.field.customValues) {
        // Add this new value as an option
        options.insert(0, ComboOption(filter));
        // options.insert(0, ComboOption(newValue, 'Use this new value'));
      }
    } else if (widget.allowEmpty && widget.field.isSingularValue) {
      options.insert(0, ComboOption('', label: '<${loc.fieldComboEmpty}>'));
    }

    return ResponsiveGridList(
      minItemWidth: 150.0,
      horizontalGridSpacing: 5,
      verticalGridSpacing: 5,
      rowMainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final opt in options)
          ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(opt.label ?? opt.value, style: kFieldTextStyle),
            subtitle: opt.label == null ? null : Text(opt.value),
            selected: values.contains(opt.value),
            tileColor: kFieldColor.withValues(alpha: 0.2),
            selectedTileColor: kFieldColor,
            selectedColor: Colors.white,
            onTap: () {
              if (widget.field.isSingularValue) {
                Navigator.pop(
                    context, opt.value.isEmpty ? <String>[] : [opt.value]);
              } else {
                setState(() {
                  if (values.contains(opt.value)) {
                    values.remove(opt.value);
                  } else {
                    values.add(opt.value);
                  }
                });
              }
            },
          ),
      ],
    );
  }
}
