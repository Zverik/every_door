import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/direction_page.dart';

class DirectionPresetField extends PresetField {
  DirectionPresetField(
      {required String key,
      required String label,
      FieldPrerequisite? prerequisite})
      : super(key: key, label: label, prerequisite: prerequisite);

  @override
  Widget buildWidget(OsmChange element) => DirectionField(this, element);
}

class DirectionField extends StatelessWidget {
  final OsmChange element;
  final PresetField field;

  const DirectionField(this.field, this.element);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: ElevatedButton(
        onPressed: () async {
          String? value = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DirectionValuePage(
                      element.location, element[field.key])));
          if (value != null) {
            element[field.key] = value == '-' ? null : value;
          }
        },
        child: Text(
          element[field.key] ?? '${loc.fieldDirectionSet}...',
          style: kFieldTextStyle,
        ),
      ),
    );
  }
}
