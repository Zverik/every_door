import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntranceEditorPane extends ConsumerStatefulWidget {
  final OsmChange? entrance;
  final LatLng location;

  const EntranceEditorPane({this.entrance, required this.location});

  @override
  ConsumerState<EntranceEditorPane> createState() => _EntranceEditorPaneState();
}

class _EntranceEditorPaneState extends ConsumerState<EntranceEditorPane> {
  late OsmChange entrance;

  @override
  void initState() {
    super.initState();
    entrance = widget.entrance ??
        OsmChange.create(tags: {'entrance': 'yes'}, location: widget.location);
  }

  bool isValidFlats(String? value) {
    if ((value ?? '').trim().isEmpty) return true;
    return RegExp(r'^(\d+(-\d+)?)(\s*;\s*(\d+(-\d+)?))*$')
        .hasMatch(value!.trim());
  }

  saveAndClose() {
    entrance.removeTag(OsmChange.kCheckedKey);
    final changes = ref.read(changesProvider);
    changes.saveChange(entrance);
    ref.read(needMapUpdateProvider).trigger();
    Navigator.pop(context);
  }

  deleteAndClose() {
    final changes = ref.read(changesProvider);
    if (entrance.isNew) {
      changes.deleteChange(entrance);
    } else {
      for (final k in {
        'entrance',
        'ref',
        'addr:flats',
        'access',
        OsmChange.kCheckedKey,
      }) entrance.removeTag(k);
      changes.saveChange(entrance);
    }
    ref.read(needMapUpdateProvider).trigger();
    Navigator.pop(context);
  }

  List<String> suggestRefs(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Calculate from flat numbers (-2 ... +2)
      final match = RegExp(r'(\d+)-(\d+)').firstMatch(value);
      if (match != null) {
        int first = int.parse(match.group(1)!);
        int second = int.parse(match.group(2)!);
        int count = (second - first).abs() + 1;
        if (second < first) first = second;
        int start = (first / count).round() + 1; // TODO: test
        // test options: 3-4, 31-45, 30-45
        start = start > 2 ? start - 2 : 1;
        return [for (int r = 0; r < 5; r++) (r + start).toString()];
      }
    }
    // By default return the progression.
    return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FixedColumnWidth(100.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Flats', style: kFieldTextStyle),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  autofocus: entrance['addr:flats'] == null,
                  initialValue: entrance['addr:flats'],
                  style: kFieldTextStyle,
                  decoration: const InputDecoration(hintText: '16-29;32'),
                  validator: (value) =>
                      isValidFlats(value) ? null : 'Should be a number list',
                  onChanged: (value) {
                    setState(() {
                      entrance['addr:flats'] = value.trim();
                    });
                  },
                ),
              ],
            ),
            // TODO: addr:unit for a single flat?
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Ref', style: kFieldTextStyle),
                ),
                // TODO: option to enter a custom number?
                RadioField(
                  options: suggestRefs(entrance['addr:flats']),
                  value: entrance['ref'],
                  onChange: (value) {
                    setState(() {
                      entrance['ref'] = value;
                    });
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Access', style: kFieldTextStyle),
                ),
                RadioField(
                  // TODO: labels
                  options: const ['yes', 'private', 'delivery', 'no'],
                  value: entrance['access'],
                  onChange: (value) {
                    setState(() {
                      entrance['access'] = value;
                    });
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Wheelchair', style: kFieldTextStyle),
                ),
                RadioField(
                  options: const ['yes', 'limited', 'no'],
                  labels: [
                    loc.fieldWheelchairYes,
                    loc.fieldWheelchairLimited,
                    loc.fieldWheelchairNo,
                  ],
                  onChange: (value) {
                    setState(() {
                      entrance['wheelchair'] = value;
                    });
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Type', style: kFieldTextStyle),
                ),
                RadioField(
                  // TODO: labels
                  options: const [
                    'main',
                    'staircase',
                    'home',
                    'shop',
                    'service',
                    'garage',
                    'emergency',
                  ],
                  value: entrance['entrance'] == 'yes'
                      ? null
                      : entrance['entrance'],
                  onChange: (value) {
                    setState(() {
                      entrance['entrance'] = value ?? 'yes';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        // TODO: enable when snapping is done
        if (entrance.isNew && false)
          SwitchListTile(
            title: Text(
              'Snap to building contour',
              style: kFieldTextStyle,
            ),
            value: entrance.snapToBuilding,
            onChanged: (bool newValue) {
              setState(() {
                entrance.snapToBuilding = newValue;
              });
            },
          ),
        Row(
          children: [
            if (widget.entrance != null && entrance.canDelete)
              TextButton(
                child:
                    Text(loc.editorDeleteButton), // TODO: does the label fit?
                onPressed: () async {
                  final answer = await showOkCancelAlertDialog(
                    context: context,
                    title:
                        loc.editorDeleteTitle('entrance'), // TODO: better msg
                    okLabel: loc.editorDeleteButton,
                    isDestructiveAction: true,
                  );
                  if (answer == OkCancelResult.ok) {
                    deleteAndClose();
                  }
                },
              ),
            Expanded(child: Container()),
            TextButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                if (true) {
                  saveAndClose();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
