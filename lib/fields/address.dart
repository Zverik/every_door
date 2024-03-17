import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/new_addr.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor/addr_chooser.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressField extends PresetField {
  AddressField({required super.label, super.key = "addr"})
      : super(
          icon: key == 'addr' ? Icons.home_outlined : null,
        );

  @override
  Widget buildWidget(OsmChange element) => AddressInput(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    return StreetAddress.fromTags(tags, base: key).isNotEmpty;
  }
}

class AddressInput extends ConsumerStatefulWidget {
  final OsmChange element;
  final AddressField field;

  const AddressInput(this.field, this.element);

  @override
  ConsumerState createState() => _AddressInputState();
}

class _AddressInputState extends ConsumerState<AddressInput> {
  static const kChooseOnMap = '🗺️';
  List<StreetAddress> nearestAddresses = [];

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  loadAddresses() async {
    final osmData = ref.read(osmDataProvider);
    final addr =
        await osmData.getAddressesAround(widget.element.location, limit: 3);
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
            child: NewAddressPane(widget.element.location),
          ),
        );
      },
    );

    if (addr == null) return;
    setState(() {
      addr.withBase(widget.field.key).forceTags(widget.element);
    });
  }

  chooseAddressOnMap() async {
    final StreetAddress? addr = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddrChooserPage(location: widget.element.location),
      ),
    );
    if (addr != null && addr.isNotEmpty) {
      setState(() {
        addr.withBase(widget.field.key).forceTags(widget.element);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = StreetAddress.fromTags(widget.element.getFullTags(),
        base: widget.field.key);
    final options = nearestAddresses.map((e) => e.toString()).toList();
    if (current.isEmpty) {
      options.insert(0, kChooseOnMap);
      options.add(kManualOption);
    }
    return RadioField(
      options: options,
      value: current.isEmpty ? null : current.toString(),
      onChange: (value) {
        if (value == null) {
          setState(() {
            StreetAddress.clearTags(widget.element, base: widget.field.key);
          });
        } else if (value == kManualOption) {
          addAddress(context);
        } else if (value == kChooseOnMap) {
          chooseAddressOnMap();
        } else {
          final addr = nearestAddresses
              .firstWhere((element) => element.toString() == value);
          setState(() {
            addr.withBase(widget.field.key).setTags(widget.element);
          });
        }
      },
    );
  }
}
