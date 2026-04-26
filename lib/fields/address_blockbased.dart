import 'package:every_door/constants.dart';
import 'package:every_door/fields/address_form_blockbased.dart';
import 'package:every_door/models/address_blockbased.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor/addr_chooser.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/fields/address_form.dart';

import '../widgets/radio_field.dart';

/// Block-based address field (counterpart of lib/fields/address.dart)
/// Uses BlockBasedAddress model and the blockbased form for manual editing.
class AddressBlockBasedField extends PresetField {
  AddressBlockBasedField({required super.label, super.key = "addr"})
      : super(
          icon: key == 'addr' ? Icons.home_outlined : null,
        );

  @override
  Widget buildWidget(OsmChange element) => AddressBlockBasedInput(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    return BlockBasedAddress.fromTags(tags, base: key).isNotEmpty;
  }
}

class AddressBlockBasedInput extends ConsumerStatefulWidget {
  final OsmChange element;
  final AddressBlockBasedField field;

  const AddressBlockBasedInput(this.field, this.element);

  @override
  ConsumerState createState() => _AddressBlockBasedInputState();
}

class _AddressBlockBasedInputState extends ConsumerState<AddressBlockBasedInput> {
  static const kChooseOnMap = '🗺️';
  List<BlockBasedAddress> nearestAddresses = [];

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final osmData = ref.read(osmDataProvider);
    final addr = await osmData.getBlockBasedAddressesAround(
      widget.element.location,
      limit: 3,
    );
    setState(() {
      nearestAddresses = addr;
    });
  }

  Future<void> _openManualEditor(BuildContext context) async {
    await showModalBottomSheet(
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
            child: AddressFormBlockBasedField(
              AddressFormPresetField(key: widget.field.key, label: widget.field.label),
              widget.element,
            ),
          ),
        );
      },
    );
    // Element tags are updated in-place by the form; no return value needed.
    setState(() {});
  }

  BlockBasedAddress _convertFromStreet(StreetAddress sa) {
    // Prefer city if present, otherwise place as suburb.
    return BlockBasedAddress(
      housenumber: sa.housenumber,
      blockNumber: sa.blockNumber,
      city: sa.city,
      province: sa.province,
      suburb: sa.city == null ? sa.place : null,
    ).withBase(widget.field.key);
  }

  Future<void> _chooseAddressOnMap() async {
    final StreetAddress? sa = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddrChooserPage(location: widget.element.location),
      ),
    );
    if (sa != null && sa.isNotEmpty) {
      final ba = _convertFromStreet(sa);
      setState(() {
        ba.forceTags(widget.element);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = BlockBasedAddress.fromTags(
      widget.element.getFullTags(),
      base: widget.field.key,
    );

    final List<String> options =
        nearestAddresses.map((e) => e.toShortString()).toList();
    final String? currentValue = current.isEmpty ? null : current.toShortString();
    if (currentValue != null && !options.contains(currentValue)) {
      options.insert(0, currentValue);
    }

    if (current.isEmpty) {
      options.insert(0, kChooseOnMap);
      options.add(kManualOption);
    } else {
      options.insert(0, kManualOption);
    }

    return RadioField(
      options: options,
      value: currentValue,
      keepFirst: true,
      onChange: (value) async {
        if (value == null) {
          setState(() {
            BlockBasedAddress.clearTags(widget.element, base: widget.field.key);
          });
        } else if (value == kManualOption) {
          await _openManualEditor(context);
        } else if (value == kChooseOnMap) {
          await _chooseAddressOnMap();
        } else {
          final ba = nearestAddresses.cast<BlockBasedAddress?>().firstWhere(
                (e) => e?.toShortString() == value,
                orElse: () => value == currentValue ? current : null,
              );
          if (ba != null) {
            setState(() {
              ba.withBase(widget.field.key).setTags(widget.element);
            });
          }
        }
      },
    );
  }
}
