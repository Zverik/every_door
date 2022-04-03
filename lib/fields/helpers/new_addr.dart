import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/radio_field.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class NewAddressPane extends ConsumerStatefulWidget {
  final LatLng location;

  const NewAddressPane(this.location);

  @override
  ConsumerState<NewAddressPane> createState() => _NewAddressPaneState();
}

class _NewAddressPaneState extends ConsumerState<NewAddressPane> {
  late StreetAddress address;
  final _formKey = GlobalKey<FormState>();
  final _houseController = TextEditingController();
  final _unitController = TextEditingController();
  List<String> nearestStreets = [];
  List<String> nearestPlaces = [];
  String? street;
  String? place;

  @override
  void initState() {
    super.initState();
    address = StreetAddress();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
                    child: Text('House Number', style: kFieldTextStyle),
                  ),
                  TextFormField(
                    controller: _houseController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: kFieldTextStyle,
                    decoration: const InputDecoration(hintText: '1, 89, 154A, ...'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Should not be empty'
                        : null,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text('Unit', style: kFieldTextStyle),
                  ),
                  TextFormField(
                    controller: _unitController,
                    keyboardType: TextInputType.number,
                    style: kFieldTextStyle,
                    decoration: const InputDecoration(hintText: 'optional'),
                  ),
                ],
              ),
              if (nearestStreets.isNotEmpty)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text('Street', style: kFieldTextStyle),
                    ),
                    RadioField(
                        options: nearestStreets,
                        value: street,
                        onChange: (value) {
                          setState(() {
                            street = value;
                          });
                        }),
                  ],
                ),
              if (nearestPlaces.isNotEmpty)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text('Place', style: kFieldTextStyle),
                    ),
                    RadioField(
                        options: nearestPlaces,
                        value: place,
                        onChange: (value) {
                          setState(() {
                            place = value;
                          });
                        }),
                  ],
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: (street ?? place) == null ? null : () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: construct an address
                    final house = _houseController.text.trim();
                    final unit = _unitController.text.trim();
                    final address = StreetAddress(
                      housenumber: house.isEmpty ? null : house,
                      unit: unit.isEmpty ? null : unit,
                      street: street,
                      place: place,
                    );
                    Navigator.pop(context, address);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
