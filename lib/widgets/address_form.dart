import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/road_names.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/address.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

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
  late final TextEditingController _houseController;
  late final TextEditingController _unitController;
  late final TextEditingController _blockController;
  late final FocusNode _streetFocus;
  List<String> nearestStreets = [];
  List<String> nearestBlocks = [];
  List<String> nearestPlaces = [];
  List<String> nearestCities = [];
  String? street;
  String? place;
  bool isName = false;
  bool editingStreet = false;
  bool needBlockNumber = false;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress ?? StreetAddress();
    isName = address.housename != null && address.housenumber == null;
    _houseController =
        TextEditingController(text: address.housenumber ?? address.housename);
    _unitController = TextEditingController(text: address.unit);
    _blockController =
        TextEditingController(text: address.blockNumber ?? address.block);
    _streetFocus = FocusNode();
    street = address.street;
    place = address.place ?? address.city;
    needBlockNumber = CountryCoder.instance.isIn(
      lat: widget.location.latitude,
      lon: widget.location.longitude,
      inside: 'Q17', // Japan
    );
    updateStreets();
  }

  @override
  dispose() {
    _houseController.dispose();
    _unitController.dispose();
    _blockController.dispose();
    _streetFocus.dispose();
    super.dispose();
  }

  List<String> _filterDuplicates(Iterable<String?> source) {
    final values = <String>{};
    final result = source.whereType<String>().toList();
    result.retainWhere((element) => values.add(element));
    return result;
  }

  Future<void> updateStreets() async {
    final provider = ref.read(osmDataProvider);
    nearestStreets =
        await ref.read(roadNameProvider).getNamesAround(widget.location);
    final addrs = await provider.getAddressesAround(widget.location, limit: 30);
    setState(() {
      nearestBlocks = _filterDuplicates(
          addrs.map((e) => needBlockNumber ? e.blockNumber : e.block));
      nearestPlaces = _filterDuplicates(addrs.map((e) => e.place));
      nearestCities = _filterDuplicates(addrs.map((e) => e.city));
    });
  }

  String? get house {
    final value = _houseController.text.trim();
    return value.isEmpty ? null : value;
  }

  void notifyOnChange() {
    final unit = _unitController.text.trim();
    final block = _blockController.text.trim();
    final address = StreetAddress(
      housenumber: isName ? null : house,
      housename: isName ? house : widget.initialAddress?.housename,
      unit: unit.isEmpty ? null : unit,
      block: needBlockNumber || block.isEmpty ? null : block,
      blockNumber: !needBlockNumber || block.isEmpty ? null : block,
      street: street,
      place: nearestPlaces.isNotEmpty ? place : null,
      city: nearestPlaces.isNotEmpty ? null : place,
    );
    setState(() {});
    widget.onChange(address);
  }

  static final kHouseName = RegExp(r'^[a-z]', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final numericKeyboardType = ref.watch(editorSettingsProvider).keyboardType;

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
              child: Text(loc.addressHouseNumber,
                  style: kFieldTextStyle.copyWith(
                      color: _houseController.text.trim().isEmpty &&
                              (street != null ||
                                  _blockController.text.trim().isNotEmpty)
                          ? Colors.red
                          : null)),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _houseController,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: widget.autoFocus,
                    style: kFieldTextStyle,
                    decoration:
                        const InputDecoration(hintText: '1, 89, 154A, ...'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? loc.addressHouseNotEmpty
                        : null,
                    onChanged: (value) {
                      notifyOnChange();
                    },
                  ),
                ),
                if (isName ||
                    ((house?.length ?? 0) >= 3 &&
                        kHouseName.hasMatch(house ?? ''))) ...[
                  Text('name?', style: kFieldTextStyle),
                  Switch(
                    value: isName,
                    onChanged: (value) {
                      setState(() {
                        isName = value;
                      });
                      notifyOnChange();
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
        if (needBlockNumber)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  loc.addressBlock,
                  style: kFieldTextStyle.copyWith(
                      color: _houseController.text.trim().isNotEmpty &&
                          (street == null &&
                              _blockController.text.trim().isEmpty)
                          ? Colors.red
                          : null),
                ),
              ),
              TextFormField(
                controller: _blockController,
                keyboardType: numericKeyboardType,
                style: kFieldTextStyle,
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
              child: Text(
                loc.addressStreet,
                style: kFieldTextStyle.copyWith(
                    color: _houseController.text.trim().isNotEmpty &&
                            (street == null &&
                                _blockController.text.trim().isEmpty)
                        ? Colors.red
                        : null),
              ),
            ),
            if (!editingStreet)
              RadioField(
                  options: street != null
                      ? nearestStreets
                      : nearestStreets + [kManualOption],
                  value: street,
                  onChange: (value) {
                    setState(() {
                      if (value == kManualOption) {
                        street = null;
                        editingStreet = true;
                        _streetFocus.requestFocus();
                      } else {
                        street = value;
                      }
                    });
                    if (value != kManualOption) notifyOnChange();
                  }),
            if (editingStreet)
              TextFormField(
                focusNode: _streetFocus,
                style: kFieldTextStyle,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  street = value.trim().isEmpty ? null : value.trim();
                  notifyOnChange();
                },
              ),
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
