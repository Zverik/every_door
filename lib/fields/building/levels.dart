import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildingLevelsPresetField extends PresetField {
  BuildingLevelsPresetField({
    required super.key,
    required super.label,
  });

  @override
  Widget buildWidget(OsmChange element) => BuildingLevelsField(this, element);
}

class BuildingLevelsField extends ConsumerStatefulWidget {
  final BuildingLevelsPresetField field;
  final OsmChange element;

  const BuildingLevelsField(this.field, this.element, {super.key});

  @override
  ConsumerState<BuildingLevelsField> createState() => _BuildingLevelsFieldState();
}

class _BuildingLevelsFieldState extends ConsumerState<BuildingLevelsField> {
  bool manual = false;
  late final FocusNode _focusNode;
  List<String> nearestLevels = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    updateLevels();
  }

  updateLevels() async {
    // TODO: wtf is this mess?! Simplify.
    final provider = ref.read(osmDataProvider);
    const radius = kVisibilityRadius;
    List<OsmChange> data = await provider.getElements(widget.element.location, radius);
    final levelCount = <int, int>{};
    const distance = DistanceEquirectangular();
    data
        .where((e) =>
    distance(widget.element.location, e.location) <= radius &&
        e['building:levels'] != null)
        .forEach((e) {
      final levels = int.tryParse(e['building:levels']!);
      if (levels != null) {
        levelCount[levels] = (levelCount[levels] ?? 0) + 1;
      }
    });
    levelCount.remove(1);
    levelCount.remove(2);
    // Add two level values for defaults.
    levelCount[3] = 0;
    levelCount[5] = 0;

    final values = levelCount.entries.toList();
    values.sort((a, b) => b.value.compareTo(a.value));

    final List<int> nearestInt = values.map((e) => e.key).take(2).toList();
    nearestInt.sort();

    if (!mounted) return;
    setState(() {
      nearestLevels = nearestInt.map((e) => e.toString()).toList();
    });
  }

  bool validateLevels(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    final levels = int.tryParse(value.trim());
    if (levels == null) return false;
    return levels >= 1 && levels <= 40;
  }

  @override
  Widget build(BuildContext context) {
    if (manual) {
      final loc = AppLocalizations.of(context)!;
      return TextFormField(
        keyboardType: TextInputType.number,
        style: kFieldTextStyle,
        initialValue: widget.element[widget.field.key],
        focusNode: _focusNode,
        validator: (value) => validateLevels(value)
            ? null
            : loc.fieldFloorShouldBeNumber,
        onChanged: (value) {
          setState(() {
            widget.element[widget.field.key] = value.trim();
          });
        },
      );
    } else {
      final levelOptions = ['1', '2'] + nearestLevels;
      levelOptions.add(kManualOption);

      return RadioField(
        options: levelOptions,
        value: widget.element[widget.field.key],
        onChange: (value) {
          setState(() {
            if (value == kManualOption) {
              widget.element.removeTag(widget.field.key);
              manual = true;
              _focusNode.requestFocus();
            } else {
              widget.element[widget.field.key] = value;
            }
          });
        },
      );
    }
  }
}
