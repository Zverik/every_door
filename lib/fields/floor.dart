import 'package:every_door/fields/helpers/floor_chooser.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/radio_field.dart';

class FloorPresetField extends PresetField {
  FloorPresetField({required String label})
      : super(
          key: "level",
          label: label,
          icon: Icons.menu,
        );

  @override
  Widget buildWidget(OsmChange element) => FloorInputField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      tags.containsKey('level') || tags.containsKey('addr:floor');
}

class FloorInputField extends ConsumerStatefulWidget {
  final OsmChange element;
  final FloorPresetField field;

  const FloorInputField(this.field, this.element);

  @override
  _FloorInputFieldState createState() => _FloorInputFieldState();
}

class _FloorInputFieldState extends ConsumerState<FloorInputField> {
  List<Floor> floors = [];
  late StreetAddress address;

  @override
  void initState() {
    super.initState();
    address = StreetAddress.fromTags(widget.element.getFullTags());
    widget.element.addListener(updateFloors);
    updateFloors();
  }

  @override
  dispose() {
    widget.element.removeListener(updateFloors);
    super.dispose();
  }

  updateFloors() async {
    final osmData = ref.read(osmDataProvider);
    final tags = widget.element.getFullTags();
    final addr = StreetAddress.fromTags(tags);
    List<Floor> floors;
    try {
      floors = await osmData.getFloorsAround(widget.element.location, addr);
      Floor.collapseList(floors);
    } on Exception catch (e) {
      print(e);
      floors = [];
    }
    final currentFloor = Floor.fromTags(tags);
    if (currentFloor.isNotEmpty && !floors.contains(currentFloor)) {
      floors.add(currentFloor);
      floors.sort();
    }
    if (mounted) {
      setState(() {
        address = addr;
        this.floors = floors;
      });
    }
  }

  addFloor(BuildContext context) async {
    final List<String>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 6.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FloorChooserPane(),
          ),
        );
      },
    );

    if (result == null || result.length != 2) return;
    if (result.every((value) => value.trim().isEmpty)) return;
    
    final floor = Floor(
      level: result[1].isEmpty ? null : double.parse(result[1].trim()),
      floor: result[0].isEmpty ? null : result[0].trim(),
    );
    setState(() {
      floor.setTags(widget.element);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final current = Floor.fromTags(widget.element.getFullTags());
    if (address.isEmpty && current.isEmpty) {
      return Text(loc.fieldFloorEmpty);
    }

    final options = floors.map((e) => e.string).toList();
    if (current.isEmpty) options.add('+');

    return RadioField(
      options: options,
      value: current.isEmpty ? null : current.string,
      onChange: (value) {
        if (value == null) {
          setState(() {
            Floor.clearTags(widget.element);
          });
        } else if (value == '+') {
          addFloor(context);
        } else {
          final addr = floors.firstWhere((element) => element.string == value);
          setState(() {
            addr.setTags(widget.element);
          });
        }
      },
    );
  }
}
