import 'package:every_door/fields/helpers/new_addr.dart';
import 'package:every_door/fields/helpers/radio_field.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressField extends PresetField {
  AddressField({required String label})
      : super(
          key: "addr",
          label: label,
          icon: Icons.home_outlined,
        );

  @override
  Widget buildWidget(OsmChange element) => AddressInput(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    return StreetAddress.fromTags(tags).isNotEmpty;
  }
}

class AddressInput extends ConsumerStatefulWidget {
  final OsmChange element;
  final AddressField field;

  const AddressInput(this.field, this.element);

  @override
  _AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends ConsumerState<AddressInput> {
  List<StreetAddress> nearestAddresses = [];

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  loadAddresses() async {
    final osmData = ref.read(osmDataProvider);
    final addr = await osmData.getAddressesAround(widget.element.location, 3);
    setState(() {
      nearestAddresses = addr;
    });
  }

  addAddress(BuildContext context) async {
    final StreetAddress? addr = await showModalBottomSheet(
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
            child: NewAddressPane(),
          ),
        );
      },
    );

    if (addr == null || addr.isEmpty) return;
    setState(() {
      addr.setTags(widget.element);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nearestAddresses.isEmpty) {
      return Text('no addresses nearby');
    }

    final current = StreetAddress.fromTags(widget.element.getFullTags());
    return RadioField(
      options: nearestAddresses.map((e) => e.toString()).toList() + ['+'],
      value: current.isEmpty ? null : current.toString(),
      onChange: (value) {
        if (value == null) {
          setState(() {
            StreetAddress.clearTags(widget.element);
          });
        } else if (value == '+') {
          addAddress(context);
        } else {
          final addr = nearestAddresses
              .firstWhere((element) => element.toString() == value);
          setState(() {
            addr.setTags(widget.element);
          });
        }
      },
    );
  }
}
