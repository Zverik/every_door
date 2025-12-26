// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class HeightPresetField extends PresetField {
  HeightPresetField(
      {required super.key,
      required super.label,
      super.placeholder,
      super.prerequisite})
      : super(
            icon: Icons.phone);

  @override
  Widget buildWidget(OsmChange element) => HeightInputField(this, element);
}

class HeightInputField extends StatefulWidget {
  final HeightPresetField field;
  final OsmChange element;

  const HeightInputField(this.field, this.element);

  @override
  State createState() => _HeightInputFieldState();
}

class _HeightInputFieldState extends State<HeightInputField> {
  late final TextEditingController _controller;
  late final bool? isKmh;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.element[widget.field.key] ?? '');

    final heightUnit = CountryCoder.instance.roadHeightUnit(
      lat: widget.element.location.latitude,
      lon: widget.element.location.longitude,
    );
    if (heightUnit == null)
      isKmh = null;
    else
      isKmh = heightUnit == RegionHeightUnit.meters;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static final _kReKmh = RegExp(r'^\d+(?:\.\d+)?(?: m)?$');
  static final _kReMph = RegExp(r'''^\d+'\d+"$''');

  @override
  Widget build(BuildContext context) {
    final value = widget.element[widget.field.key] ?? '';
    if (value != _controller.text.trim()) {
      // Hopefully that's not the time when we type a letter in the field.
      // TODO: only update when page is back from inactive?
      _controller.text = value;
    }

    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          hintText: widget.field.placeholder,
          labelText: widget.field.label,
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor, width: 2.0)),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          if ({'default', 'below_default', 'none'}.contains(value)) return null;
          final fitsKmh = _kReKmh.hasMatch(value);
          final fitsMph = _kReMph.hasMatch(value);
          if (isKmh == true && !fitsKmh)
            return loc.fieldHeightMeters;
          if (isKmh == false && !fitsMph)
            return loc.fieldHeightFeet;
          if (isKmh == null && !fitsMph && !fitsMph)
            return loc.fieldHeightAny;
          return null;
        },
        style: kFieldTextStyle,
        onChanged: (value) {
          // On every keypress, since the focus can change at any minute.
          setState(() {
            widget.element[widget.field.key] = value.trim();
          });
        },
      ),
    );
  }
}
