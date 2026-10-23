import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/address_blockbased.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:latlong2/latlong.dart' show LatLng;

class AddressFormBlockBased extends ConsumerStatefulWidget {
  final LatLng location;
  final BlockBasedAddress? initialAddress;
  final Function(BlockBasedAddress) onChange;
  final double columnWidth;
  final bool autoFocus;

  const AddressFormBlockBased({
    this.initialAddress,
    required this.location,
    required this.onChange,
    this.columnWidth = 100.0,
    this.autoFocus = true,
  });

  @override
  ConsumerState<AddressFormBlockBased> createState() => _AddressFormBlockBasedState();
}

class _AddressFormBlockBasedState extends ConsumerState<AddressFormBlockBased> {
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
    final address = widget.initialAddress ?? BlockBasedAddress();
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
      widget.location,
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

  Future<void> _editValue(String label, TextEditingController controller,
      {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) async {
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

  void notifyOnChange() {
    String postcode = _postcodeController.text.trim();
    final isJapan = CountryCoder.instance.isIn(
      lat: widget.location.latitude,
      lon: widget.location.longitude,
      inside: 'Q17', // Japan
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

    // If we have nearby addresses, try to fill province from the selected city/neighbourhood
    if (address.province == null) {
      final provider = ref.read(osmDataProvider);
      // We don't want to await here to avoid lag, but maybe we can find it in already loaded addrs
      // Actually, it's better to do it in onChange of RadioField
    }

    widget.onChange(address);
    setState(() {});
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
    final displayOptions = hasOptions ? options + [kManualOption] : null;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 10.0),
          child: Text(label, style: kFieldTextStyle.copyWith(color: labelColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasOptions)
                RadioField(
                  options: displayOptions!,
                  value: options.contains(controller.text.trim()) ? controller.text.trim() : null,
                  onChange: (value) {
                    if (value == kManualOption) {
                      _editValue(label, controller,
                          keyboardType: keyboardType, inputFormatters: inputFormatters);
                    } else if (value != null) {
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
              if (!hasOptions)
                TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: autofocus,
                style: kFieldTextStyle,
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                validator: validator,
                inputFormatters: inputFormatters,
                onChanged: (value) => notifyOnChange(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final numericKeyboardType = ref.watch(editorSettingsProvider).keyboardType;
    final isJapan = CountryCoder.instance.isIn(
      lat: widget.location.latitude,
      lon: widget.location.longitude,
      inside: 'Q17',
    );
    final postcodeRegExp = RegExp(r'^\d{3}-\d{4}$');

    // Requested order: 郵便番号 -> 市町村 -> "町丁・字" -> 番地 -> 住居番号
    // Mapping to OSM tags:
    // 郵便番号: postcode
    // 市町村: city / county / province
    // 町丁・字: neighbourhood / quarter / suburb
    // 番地: block_number
    // 住居番号: housenumber

    return Table(
      columnWidths: {0: FixedColumnWidth(widget.columnWidth)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
        if (nearestProvinces.isNotEmpty)
          _buildRow(loc.addressProvince, _provinceController, options: nearestProvinces),
        _buildRow(loc.addressCity, _cityController, options: nearestCities),
        _buildRow(loc.addressNeighbourhood, _neighController, options: nearestNeighbourhoods),
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
          autofocus: widget.autoFocus,
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
