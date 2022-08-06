import 'package:every_door/constants.dart';
import 'package:every_door/helpers/common_keys.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/private.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<List<String>?> _newTagPanel(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 5.0,
              left: 15.0,
              right: 15.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 6.0,
            ),
            child: NewTagPanel(),
          ),
        );
      },
    );
    return result;
  }

  String _getUrl() => 'https://$kOsmAuth2Endpoint/${widget.amenity.id.fullRef}';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    String title = widget.amenity.isNew
        ? loc.tagsNewPoint
        : '${kOsmElementTypeName[widget.amenity.id.type]} ${widget.amenity.id.ref}';
    final sortedKeys = List.of(keys);
    sortedKeys.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!widget.amenity.isNew)
            GestureDetector(
              child: IconButton(
                // TODO: copy to clipboard?
                // https://stackoverflow.com/questions/55885433/flutter-dart-how-to-add-copy-to-clipboard-on-tap-to-a-app
                onPressed: () {
                  Share.share(_getUrl());
                },
                icon: Icon(Icons.share),
                tooltip: loc.tagsShare,
              ),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _getUrl())).then((_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(loc.tagsUrlCopied)));
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
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
                                (widget.amenity.element?.tags
                                        .containsKey(key) ??
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
                              fillColor:
                                  !widget.amenity.newTags.containsKey(key)
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
                            (widget.amenity.element?.tags
                                .containsKey(key) ??
                                false)
                            ? Icons.undo
                            : Icons.clear),
                        tooltip: widget.amenity.newTags.containsKey(key) &&
                                (widget.amenity.element?.tags
                                        .containsKey(key) ??
                                    false)
                            ? loc.tagsRestore
                            : loc.tagsDelete,
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
                        final result = await _newTagPanel(context);
                        if (result != null &&
                            result.length == 2 &&
                            result.every(
                                (element) => element.trim().isNotEmpty)) {
                          final k = result[0].trim();
                          final v = result[1].trim();
                          controllers[k] = TextEditingController(text: v);
                          widget.amenity[k] = v;
                          setState(() {
                            keys.add(k);
                          });
                        }
                      },
                      child: Text(loc.tagsAddTag, style: kFieldTextStyle),
                    ),
                    // Since we don't have colspan, add empty containers.
                    Container(),
                    Container(),
                  ])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewTagPanel extends StatefulWidget {
  const NewTagPanel({Key? key}) : super(key: key);

  @override
  State<NewTagPanel> createState() => _NewTagPanelState();
}

class _NewTagPanelState extends State<NewTagPanel> {
  String _key = '';
  String _value = '';
  final FocusNode _valueFocus = FocusNode();

  @override
  void dispose() {
    _valueFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Table(
          columnWidths: const {0: IntrinsicColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(loc.tagsKey, style: kFieldTextStyle),
                ),
                Autocomplete<String>(
                  optionsBuilder: (value) => value.text.isEmpty
                      ? <String>[]
                      : kCommonKeys.where((k) => k.startsWith(value.text)),
                  fieldViewBuilder: (context1, controller, focus, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focus,
                      autofocus: true,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => onSubmitted(),
                      onChanged: (value) {
                        _key = value.trim();
                      },
                    );
                  },
                  onSelected: (value) {
                    // Move focus to the next one.
                    _key = value.trim();
                    _valueFocus.requestFocus();
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(loc.tagsValue, style: kFieldTextStyle),
                ),
                TextFormField(
                  focusNode: _valueFocus,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    _value = value.trim();
                  },
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel)),
            TextButton(
                onPressed: () {
                  final List<String>? result =
                      _key.isNotEmpty && _value.isNotEmpty
                          ? [_key, _value]
                          : null;
                  Navigator.pop(context, result);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel)),
          ],
        )
      ],
    );
  }
}
