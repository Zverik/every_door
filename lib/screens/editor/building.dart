import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/widgets/address_form.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class BuildingEditorPane extends ConsumerStatefulWidget {
  final OsmChange? building;
  final LatLng location;

  const BuildingEditorPane({this.building, required this.location});

  @override
  ConsumerState<BuildingEditorPane> createState() => _BuildingEditorPaneState();
}

class _BuildingEditorPaneState extends ConsumerState<BuildingEditorPane> {
  late final OsmChange building;
  List<String> nearestStreets = [];
  List<String> nearestPlaces = [];
  List<String> nearestCities = [];

  @override
  void initState() {
    super.initState();
    building = widget.building ??
        OsmChange.create(tags: {'building': 'yes'}, location: widget.location);
    updateStreets();
  }

  List<String> _filterDuplicates(Iterable<String?> source) {
    final values = <String>{};
    final result = source.whereType<String>().toList();
    result.retainWhere((element) => values.add(element));
    return result;
  }

  updateStreets() async {
    final provider = ref.read(osmDataProvider);
    final addrs = await provider.getAddressesAround(widget.location, limit: 30);
    setState(() {
      nearestStreets = _filterDuplicates(addrs.map((e) => e.street));
      nearestPlaces = _filterDuplicates(addrs.map((e) => e.place));
      nearestCities = _filterDuplicates(addrs.map((e) => e.city));
    });
  }

  bool validateLevels(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    final levels = int.tryParse(value.trim());
    if (levels == null) return false;
    return levels >= 1 && levels <= 40;
  }

  saveAndClose() {
    building.removeTag(OsmChange.kCheckedKey);
    final changes = ref.read(changesProvider);
    changes.saveChange(building);
    ref.read(needMapUpdateProvider).trigger();
    Navigator.pop(context);
  }

  deleteAndClose() {
    if (building.isNew) {
      final changes = ref.read(changesProvider);
      changes.deleteChange(building);
      ref.read(needMapUpdateProvider).trigger();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        AddressForm(
          location: widget.location,
          initialAddress: StreetAddress.fromTags(building.getFullTags()),
          autoFocus: building['addr:housenumber'] == null,
          onChange: (addr) {
            addr.setTags(building);
          },
        ),
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
                  child: Text('Levels', style: kFieldTextStyle),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: kFieldTextStyle,
                  initialValue: building['building:levels'],
                  validator: (value) =>
                      validateLevels(value) ? null : 'Please enter a number',
                  onChanged: (value) {
                    setState(() {
                      building['building:levels'] = value.trim();
                    });
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Roof levels', style: kFieldTextStyle),
                ),
                RadioField(
                    options: const ['1', '2', '3'],
                    value: building['roof:levels'],
                    onChange: (value) {
                      setState(() {
                        building['roof:levels'] = value;
                      });
                    })
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Roof Shape', style: kFieldTextStyle),
                ),
                RadioField(
                  // TODO: labels
                  options: const ['flat', 'gabled', 'hipped', 'pyramidal'],
                  value: building['roof:shape'],
                  onChange: (value) {
                    setState(() {
                      building['roof:shape'] = value;
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
                    'house',
                    'apartments',
                    'retail',
                    'commercial',
                    'shed',
                    'industrial'
                  ],
                  value: building['building'] == 'yes'
                      ? null
                      : building['building'],
                  onChange: (value) {
                    setState(() {
                      building['building'] = value ?? 'yes';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PoiEditorPage(amenity: building)),
                );
              },
              child: Text('MORE...'),
            ),
            if (building.isNew)
              TextButton(
                child:
                    Text(loc.editorDeleteButton), // TODO: does the label fit?
                onPressed: () async {
                  final answer = await showOkCancelAlertDialog(
                    context: context,
                    title:
                        loc.editorDeleteTitle('building'), // TODO: better msg
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
