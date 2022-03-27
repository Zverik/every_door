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

  @override
  void initState() {
    super.initState();
    keys = Set.of(widget.amenity.newTags.keys.toList() +
        (widget.amenity.element?.tags.keys.toList() ?? []));
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.amenity.isNew
        ? 'New point'
        : '${kOsmElementTypeName[widget.amenity.id.type]} ${widget.amenity.id.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (final key in keys)
                  TableRow(children: [
                    Text(key,
                        style: kFieldTextStyle.copyWith(
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        initialValue: widget.amenity[key],
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
                      icon: Icon(!widget.amenity.isNew &&
                              widget.amenity.newTags.containsKey(key)
                          ? Icons.undo
                          : Icons.clear),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      iconSize: 30.0,
                      onPressed: () {
                        setState(() {
                          if (widget.amenity.newTags.containsKey(key))
                            widget.amenity.newTags.remove(key);
                          else
                            widget.amenity.removeTag(key);
                        });
                      },
                    ),
                  ]),
                TableRow(children: [
                  ElevatedButton(
                    onPressed: () {},
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
