import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ComboChooserPage extends StatefulWidget {
  final ComboPresetField field;
  final List<String> values;
  final bool allowEmpty;

  const ComboChooserPage(this.field, this.values, {this.allowEmpty = true});

  @override
  _ComboChooserPageState createState() => _ComboChooserPageState();
}

class _ComboChooserPageState extends State<ComboChooserPage> {
  String filter = '';
  late List<String> values;

  @override
  void initState() {
    super.initState();
    values = List.of(widget.values);
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
      floatingActionButton: widget.field.isSingularValue ? null : FloatingActionButton(
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
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
        ),
        Expanded(child: buildChooser(context)),
      ],
    );
  }

  Widget buildChooser(BuildContext context) {
    var options = List.of(widget.field.options);
    // options = options.where((opt) => !widget.hideValues.contains(opt.value)).toList();
    if (filter.isNotEmpty) {
      // Prune options
      options =
          options.where((element) => element.value.contains(filter)).toList();
      if (widget.field.customValues) {
        // Add this new value as an option
        options.insert(0, ComboOption(filter));
        // options.insert(0, ComboOption(newValue, 'Use this new value'));
      }
    } else if (widget.allowEmpty && widget.field.isSingularValue) {
      options.insert(0, ComboOption('', '<empty>'));
    }

    return ResponsiveGridList(
      children: [
        for (final opt in options)
          ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(opt.label ?? opt.value, style: kFieldTextStyle),
            subtitle: opt.label == null ? null : Text(opt.value),
            selected: values.contains(opt.value),
            tileColor: kFieldColor.withOpacity(0.2),
            selectedTileColor: kFieldColor,
            selectedColor: Colors.white,
            onTap: () {
              if (widget.field.isSingularValue) {
                Navigator.pop(context, opt.value.isEmpty ? <String>[] : [opt.value]);
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
      minItemWidth: 150.0,
      horizontalGridSpacing: 5,
      verticalGridSpacing: 5,
      rowMainAxisAlignment: MainAxisAlignment.start,
    );
  }
}
