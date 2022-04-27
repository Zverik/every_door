import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/providers/editor_settings.dart';
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
  bool manualRef = false;
  bool putFlatsInUnit = false;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    entrance = widget.entrance?.copy() ??
        OsmChange.create(tags: {'entrance': 'yes'}, location: widget.location);

    if (entrance['building'] == 'entrance') {
      entrance.removeTag('building');
      entrance['entrance'] = 'yes';
    }
    if (entrance['addr:flats'] == null && entrance['addr:unit'] != null) {
      putFlatsInUnit = true;
      entrance['addr:flats'] = entrance['addr:unit'];
      entrance.removeTag('addr:unit');
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool isValidFlats(String? value) {
    if ((value ?? '').trim().isEmpty) return true;
    return RegExp(
            r'^(\d[\d\w]*(-\d[\d\w]*)?)(\s*;\s*(\d[\d\w]*(-\d[\d\w]*)?))*$')
        .hasMatch(value!.trim());
  }

  bool isSingleFlat(String? value) {
    if ((value ?? '').trim().isEmpty) return false;
    return RegExp(r'^\d[\d\w]*$').hasMatch(value!.trim());
  }

  saveAndClose() {
    entrance.removeTag(OsmChange.kCheckedKey);
    if (putFlatsInUnit) {
      entrance['addr:unit'] = entrance['addr:flats'];
      entrance.removeTag('addr:flats');
    }
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
      // Calculate from flat numbers (-1 ... +1)
      final match = RegExp(r'(\d+)-(\d+)').firstMatch(value);
      if (match != null) {
        int first = int.parse(match.group(1)!);
        int second = int.parse(match.group(2)!);
        int count = (second - first).abs() + 1;
        if (count > 0) {
          double middle = (second + first) / 2;
          int predicted = (middle / count + 0.5).round();
          int start = predicted > 2 ? predicted - 1 : 1;
          return [for (int r = 0; r < 3; r++) (r + start).toString()];
        }
      }
    }
    return ['1', '2', '3', '4'];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final editorSettings = ref.watch(editorSettingsProvider);

    final refOptions = suggestRefs(entrance['addr:flats']);
    if (entrance['ref'] == null) refOptions.add(kManualOption);

    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FixedColumnWidth(110.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(loc.entranceFlats, style: kFieldTextStyle),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: editorSettings.fixNumKeyboard
                            ? TextInputType.visiblePassword
                            : TextInputType.number,
                        autofocus: !manualRef && entrance['addr:flats'] == null,
                        initialValue: entrance['addr:flats'],
                        style: kFieldTextStyle,
                        decoration: const InputDecoration(hintText: '16-29;32'),
                        validator: (value) => isValidFlats(value)
                            ? null
                            : loc.entranceFlatsNumberList,
                        onChanged: (value) {
                          setState(() {
                            entrance['addr:flats'] = value.trim();
                          });
                        },
                      ),
                    ),
                    if (isSingleFlat(entrance['addr:flats']) ||
                        putFlatsInUnit) ...[
                      Text('unit?', style: kFieldTextStyle),
                      Switch(
                        value: putFlatsInUnit,
                        onChanged: (value) {
                          setState(() {
                            putFlatsInUnit = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(loc.entranceRef, style: kFieldTextStyle),
                ),
                if (!manualRef)
                  RadioField(
                    options: refOptions,
                    value: entrance['ref'],
                    onChange: (value) {
                      setState(() {
                        if (value == kManualOption) {
                          manualRef = true;
                          _focus.requestFocus();
                        } else {
                          entrance['ref'] = value;
                        }
                      });
                    },
                  ),
                if (manualRef)
                  TextFormField(
                    keyboardType: editorSettings.fixNumKeyboard
                        ? TextInputType.visiblePassword
                        : TextInputType.number,
                    style: kFieldTextStyle,
                    focusNode: _focus,
                    initialValue: entrance['ref'],
                    onChanged: (value) {
                      setState(() {
                        entrance['ref'] = value.trim();
                      });
                    },
                  ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(loc.entranceAccess, style: kFieldTextStyle),
                ),
                RadioField(
                  options: const ['yes', 'private', 'no', 'delivery'],
                  labels: [
                    loc.entranceAccessYes,
                    loc.entranceAccessPrivate,
                    loc.entranceAccessNo,
                    loc.entranceAccessDelivery,
                  ],
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
                  child: Text(loc.entranceWheelchair, style: kFieldTextStyle),
                ),
                RadioField(
                  options: const ['yes', 'limited', 'no'],
                  labels: [
                    loc.fieldWheelchairYes,
                    loc.fieldWheelchairLimited,
                    loc.fieldWheelchairNo,
                  ],
                  value: entrance['wheelchair'],
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
                  child: Text(loc.entranceType, style: kFieldTextStyle),
                ),
                RadioField(
                  options: const [
                    'main',
                    'staircase',
                    'home',
                    'shop',
                    'service',
                    'garage',
                    'emergency',
                  ],
                  labels: [
                    loc.entranceTypeMain,
                    loc.entranceTypeStaircase,
                    loc.entranceTypeHome,
                    loc.entranceTypeShop,
                    loc.entranceTypeService,
                    loc.entranceTypeGarage,
                    loc.entranceTypeEmergency,
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
        Row(
          children: [
            if (widget.entrance != null)
              TextButton(
                child: Text(loc.editorDeleteButton.toUpperCase()),
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
                ref.read(needMapUpdateProvider).trigger();
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
