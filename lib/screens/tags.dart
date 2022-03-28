import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:flutter/material.dart';

class TagEditorPage extends StatefulWidget {
  final OsmChange amenity;

  const TagEditorPage(this.amenity);

  @override
  State<TagEditorPage> createState() => _TagEditorPageState();
}

class _TagEditorPageState extends State<TagEditorPage> {
  late final Set<String> keys;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    keys = Set.of(widget.amenity.newTags.keys.toList() +
        (widget.amenity.element?.tags.keys.toList() ?? []));
    for (final k in keys)
      controllers[k] = TextEditingController(text: widget.amenity[k] ?? '');
  }

  @override
  void dispose() {
    for (final v in controllers.values) v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.amenity.isNew
        ? 'New point'
        : '${kOsmElementTypeName[widget.amenity.id.type]} ${widget.amenity.id.id}';
    final sortedKeys = List.of(keys);
    sortedKeys.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              columnWidths: const {
                0: FixedColumnWidth(130.0),
                1: FlexColumnWidth(),
                2: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (final key in sortedKeys)
                  TableRow(children: [
                    Text(
                      key,
                      style: widget.amenity.newTags.containsKey(key) ||
                              (widget.amenity.element?.tags.containsKey(key) ??
                                  false)
                          ? kFieldTextStyle.copyWith(
                              fontWeight: FontWeight.bold)
                          : kFieldTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: controllers[key],
                        style: kFieldTextStyle,
                        decoration: InputDecoration(
                            fillColor: !widget.amenity.newTags.containsKey(key)
                                ? Colors.grey.shade100
                                : (widget.amenity[key] == null
                                    ? Colors.red.shade100
                                    : Colors.yellow.shade100),
                            filled: true),
                        onChanged: (value) {
                          value = value.trim();
                          setState(() {
                            if (value.isEmpty)
                              widget.amenity.removeTag(key);
                            else
                              widget.amenity[key] = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(widget.amenity.newTags.containsKey(key) &&
                              (widget.amenity.element?.tags.containsKey(key) ??
                                  false)
                          ? Icons.undo
                          : Icons.clear),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      iconSize: 30.0,
                      onPressed: () {
                        if (widget.amenity.newTags.containsKey(key))
                          widget.amenity.undoTagChange(key);
                        else
                          widget.amenity.removeTag(key);
                        controllers[key]!.text = widget.amenity[key] ?? '';
                        setState(() {});
                      },
                    ),
                  ]),
                TableRow(children: [
                  ElevatedButton(
                    onPressed: () async {
                      // TODO: suggestions using taginfo database.
                      final result = await showTextInputDialog(
                        context: context,
                        textFields: [
                          DialogTextField(hintText: 'Key'),
                          DialogTextField(hintText: 'Value'),
                        ],
                      );
                      if (result != null &&
                          result.length == 2 &&
                          result
                              .every((element) => element.trim().isNotEmpty)) {
                        final k = result[0].trim();
                        final v = result[1].trim();
                        controllers[k] = TextEditingController(text: v);
                        widget.amenity[k] = v;
                        setState(() {
                          keys.add(k);
                        });
                      }
                    },
                    child: Text('Add a tag', style: kFieldTextStyle),
                  ),
                  Container(),
                  Container(),
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }
}
