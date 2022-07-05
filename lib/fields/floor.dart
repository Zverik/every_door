import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/floor_chooser.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class FloorPresetField extends PresetField {
  FloorPresetField({required String label})
      : super(
          key: "level",
          label: label,
          icon: Icons.stairs_outlined,
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
  ConsumerState createState() => _FloorInputFieldState();
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
      Logger('FloorInputField').warning('Error getting floors', e);
      floors = [];
    }
    final currentFloors = MultiFloor.fromTags(tags);
    if (currentFloors.isNotEmpty) {
      for (final f in currentFloors.floors)
        if (!floors.contains(f)) floors.add(f);
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
      final current = MultiFloor.fromTags(widget.element.getFullTags());
      if (!current.floors.contains(floor)) {
        current.floors.add(floor);
        current.setTags(widget.element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = MultiFloor.fromTags(widget.element.getFullTags());
    final options = floors.map((e) => e.string).toList();
    final optionMap = {for (final f in floors) f.string: f};
    if (current.isEmpty) options.add(kManualOption);

    return RadioField(
      options: options,
      values: current.strings,
      multi: true,
      onMultiChange: (value) {
        if (value.contains(kManualOption)) {
          addFloor(context);
        } else {
          final newFloors =
              MultiFloor(value.map((v) => optionMap[v]!).toList());
          setState(() {
            // It clears the tags if addr is empty
            newFloors.setTags(widget.element);
          });
        }
      },
    );
  }
}
