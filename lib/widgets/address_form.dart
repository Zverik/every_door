import 'package:every_door/constants.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/road_names.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/address.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddressForm extends ConsumerStatefulWidget {
  final LatLng location;
  final StreetAddress? initialAddress;
  final Function(StreetAddress) onChange;
  final double columnWidth;
  final bool autoFocus;

  const AddressForm({
    this.initialAddress,
    required this.location,
    required this.onChange,
    this.columnWidth = 100.0,
    this.autoFocus = true,
  });

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  late StreetAddress address;
  late final TextEditingController _houseController;
  late final TextEditingController _unitController;
  List<String> nearestStreets = [];
  List<String> nearestPlaces = [];
  List<String> nearestCities = [];
  String? street;
  String? place;

  @override
  void initState() {
    super.initState();
    address = widget.initialAddress ?? StreetAddress();
    _houseController = TextEditingController(text: address.housenumber);
    _unitController = TextEditingController(text: address.unit);
    street = address.street;
    place = address.place ?? address.city;
    updateStreets();
  }

  @override
  dispose() {
    _houseController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  List<String> _filterDuplicates(Iterable<String?> source) {
    final values = <String>{};
    final result = source.whereType<String>().toList();
    result.retainWhere((element) => values.add(element));
    return result;
  }

  updateStreets() async {
    final provider = ref.read(osmDataProvider);
    nearestStreets = await ref.read(roadNameProvider).getNamesAround(widget.location);
    final addrs = await provider.getAddressesAround(widget.location, limit: 30);
    setState(() {
      nearestPlaces = _filterDuplicates(addrs.map((e) => e.place));
      nearestCities = _filterDuplicates(addrs.map((e) => e.city));
    });
  }

  notifyOnChange() {
    final house = _houseController.text.trim();
    final unit = _unitController.text.trim();
    final address = StreetAddress(
      housenumber: house.isEmpty ? null : house,
      unit: unit.isEmpty ? null : unit,
      street: street,
      place: nearestPlaces.isNotEmpty ? place : null,
      city: nearestPlaces.isNotEmpty ? null : place,
    );
    widget.onChange(address);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final editorSettings = ref.watch(editorSettingsProvider);

    return Table(
      columnWidths: {
        0: FixedColumnWidth(widget.columnWidth),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(loc.addressHouseNumber, style: kFieldTextStyle),
            ),
            TextFormField(
              controller: _houseController,
              keyboardType: editorSettings.fixNumKeyboard
                  ? TextInputType.visiblePassword
                  : TextInputType.numberWithOptions(signed: true),
              autofocus: widget.autoFocus,
              style: kFieldTextStyle,
              decoration: const InputDecoration(hintText: '1, 89, 154A, ...'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? loc.addressHouseNotEmpty
                  : null,
              onChanged: (value) {
                notifyOnChange();
              },
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(loc.addressUnit, style: kFieldTextStyle),
            ),
            TextFormField(
              controller: _unitController,
              keyboardType: TextInputType.visiblePassword,
              style: kFieldTextStyle,
              decoration: InputDecoration(hintText: loc.addressUnitOptional),
              onChanged: (value) {
                notifyOnChange();
              },
            ),
          ],
        ),
        if (nearestStreets.isNotEmpty)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(loc.addressStreet, style: kFieldTextStyle),
              ),
              RadioField(
                  options: nearestStreets,
                  value: street,
                  onChange: (value) {
                    setState(() {
                      street = value;
                    });
                    notifyOnChange();
                  }),
            ],
          ),
        if (nearestPlaces.isNotEmpty || nearestCities.isNotEmpty)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(loc.addressPlace, style: kFieldTextStyle),
              ),
              RadioField(
                  options:
                      nearestPlaces.isNotEmpty ? nearestPlaces : nearestCities,
                  value: place,
                  onChange: (value) {
                    setState(() {
                      place = value;
                    });
                    notifyOnChange();
                  }),
            ],
          ),
      ],
    );
  }
}
