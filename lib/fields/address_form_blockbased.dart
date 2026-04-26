import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/fields/address_form.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/address_blockbased.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressFormBlockBasedField extends AddressFormField {
  
  const AddressFormBlockBasedField(super.field, super.element);

  @override
  ConsumerState<AddressFormBlockBasedField> createState() => _AddressFormFieldBlockBasedState();
}

class _AddressFormFieldBlockBasedState extends ConsumerState<AddressFormBlockBasedField> {
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighController;
  late final TextEditingController _blockController;
  late final TextEditingController _houseController;
  late final TextEditingController _postcodeController;
  late final TextEditingController _countyController;
  late final TextEditingController _suburbController;
  late final TextEditingController _quarterController;

  List<String> nearestProvinces = [];
  List<String> nearestCities = [];
  List<String> nearestNeighbourhoods = [];

  @override
  void initState() {
    super.initState();
    final address = BlockBasedAddress.fromTags(widget.element.getFullTags());
    _provinceController = TextEditingController(text: address.province);
    _cityController = TextEditingController(text: address.city);
    _neighController = TextEditingController(text: address.neighbourhood);
    _blockController = TextEditingController(text: address.blockNumber);
    _houseController = TextEditingController(text: address.housenumber);
    _postcodeController = TextEditingController(text: address.postcode);
    _countyController = TextEditingController(text: address.county);
    _suburbController = TextEditingController(text: address.suburb);
    _quarterController = TextEditingController(text: address.quarter);
    _updateNearbyAddressHints();
  }

  @override
  void dispose() {
    _provinceController.dispose();
    _cityController.dispose();
    _neighController.dispose();
    _blockController.dispose();
    _houseController.dispose();
    _postcodeController.dispose();
    _countyController.dispose();
    _suburbController.dispose();
    _quarterController.dispose();

    super.dispose();
  }

  List<String> _filterDuplicates(Iterable<String?> source) {
    final values = <String>{};
    final result = source.whereType<String>().toList();
    result.retainWhere((element) => values.add(element));
    return result;
  }

  List<BlockBasedAddress> _nearbyAddresses = [];

  Future<void> _updateNearbyAddressHints() async {
    final provider = ref.read(osmDataProvider);
    final addrs = await provider.getBlockBasedAddressesAround(
      widget.element.location,
      limit: 30,
    );
    setState(() {
      _nearbyAddresses = addrs;
      nearestProvinces = _filterDuplicates(addrs.map((e) => e.province));
      nearestCities = _filterDuplicates(addrs.map((e) => e.city));
      nearestNeighbourhoods = _filterDuplicates(
        addrs.map((e) => e.neighbourhood ?? e.quarter ?? e.suburb),
      );
    });
  }

  String? _getValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void notifyOnChange() {
    String postcode = _postcodeController.text.trim();
    final isJapan = CountryCoder.instance.isIn(
      lat: widget.element.location.latitude,
      lon: widget.element.location.longitude,
      inside: 'Q17',
    );

    if (isJapan && postcode.length == 7 && !postcode.contains('-')) {
      postcode = postcode.substring(0, 3) + '-' + postcode.substring(3);
      _postcodeController.value = TextEditingValue(
        text: postcode,
        selection: TextSelection.collapsed(offset: postcode.length),
      );
    }

    final address = BlockBasedAddress(
      province: _getValue(_provinceController),
      city: _getValue(_cityController),
      neighbourhood: _getValue(_neighController),
      blockNumber: _getValue(_blockController),
      housenumber: _getValue(_houseController),
      postcode: _getValue(_postcodeController),
      county: _getValue(_countyController),
      suburb: _getValue(_suburbController),
      quarter: _getValue(_quarterController),
    );
    address.forceTags(widget.element);
    setState(() {});
  }

  Future<void> _editValue(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controllerCopy = TextEditingController(text: controller.text);
        return AlertDialog(
          title: Text(label),
          content: TextFormField(
            controller: controllerCopy,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autofocus: true,
            decoration: InputDecoration(hintText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controllerCopy.text),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );

    if (result != null) {
      controller.text = result;
      notifyOnChange();
    }
  }

  TableRow _buildRow(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      String? hintText,
      bool autofocus = false,
      String? Function(String?)? validator,
      Color? labelColor,
      List<TextInputFormatter>? inputFormatters,
      List<String>? options}) {
    final hasOptions = options != null && options.isNotEmpty;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 15.0),
          child: Text(label, style: kFieldTextStyle.copyWith(color: labelColor)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasOptions)
              Row(
                children: [
                  Expanded(
                    child: RadioField(
                      options: options,
                      value: options.contains(controller.text.trim()) ? controller.text.trim() : null,
                      onChange: (value) {
                        if (value != null) {
                          controller.text = value;
                          if (_provinceController.text.isEmpty) {
                            final addr = _nearbyAddresses.firstWhere(
                              (e) =>
                                  e.city == value ||
                                  e.neighbourhood == value ||
                                  e.quarter == value ||
                                  e.suburb == value,
                              orElse: () => BlockBasedAddress.empty,
                            );
                            if (addr.province != null) {
                              _provinceController.text = addr.province!;
                            }
                          }
                          notifyOnChange();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Text(kManualOption, style: TextStyle(fontSize: 20.0)),
                    onPressed: () => _editValue(label, controller,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters),
                  ),
                ],
              ),
            if (!hasOptions)
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: autofocus,
                style: kFieldTextStyle,
                decoration: InputDecoration(hintText: hintText),
                validator: validator,
                inputFormatters: inputFormatters,
                onChanged: (value) => notifyOnChange(),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final numericKeyboardType = ref.watch(editorSettingsProvider).keyboardType;
    final isJapan = CountryCoder.instance.isIn(
      lat: widget.element.location.latitude,
      lon: widget.element.location.longitude,
      inside: 'Q17',
    );
    final postcodeRegExp = RegExp(r'^\d{3}-\d{4}$');

    // Order: Postcode -> Province -> County -> City -> Suburb -> Quarter -> Neighbourhood -> Block -> House
    return Table(
      columnWidths: const { 0: FixedColumnWidth(100.0)},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        _buildRow(loc.addressPostcode, _postcodeController,
            keyboardType: TextInputType.number,
            hintText: '123-4567',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              LengthLimitingTextInputFormatter(8),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              if (isJapan && !postcodeRegExp.hasMatch(value)) return loc.addressPostcodeWrong;
              return null;
            }),
        _buildRow(loc.addressProvince, _provinceController,
            options: nearestProvinces.isNotEmpty ? nearestProvinces : null),
        _buildRow(loc.addressCounty, _countyController),
        _buildRow(loc.addressCity, _cityController,
            options: nearestCities.isNotEmpty ? nearestCities : null),
        _buildRow(loc.addressSuburb, _suburbController),
        _buildRow(loc.addressQuarter, _quarterController),
        _buildRow(loc.addressNeighbourhood, _neighController,
            options: nearestNeighbourhoods.isNotEmpty
                ? nearestNeighbourhoods
                : null),
        _buildRow(
          loc.addressBlock,
          _blockController,
          keyboardType: numericKeyboardType,
          labelColor: _houseController.text.trim().isNotEmpty &&
                  _blockController.text.trim().isEmpty
              ? Colors.red
              : null,
        ),
        _buildRow(
          loc.addressHouseNumber,
          _houseController,
          keyboardType: TextInputType.visiblePassword,
          autofocus: widget.field.autoFocus,
          hintText: '1, 89, 154A, ...',
          validator: (value) => value == null || value.trim().isEmpty
              ? loc.addressHouseNotEmpty
              : null,
          labelColor: _houseController.text.trim().isEmpty &&
                  _blockController.text.trim().isNotEmpty
              ? Colors.red
              : null,
        ),
      ],
    );
  }
}
