import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class PhonePresetField extends PresetField {
  PhonePresetField(
      {required String key,
      required String label,
      FieldPrerequisite? prerequisite})
      : super(
            key: key,
            label: label,
            icon: Icons.phone,
            prerequisite: prerequisite);

  @override
  Widget buildWidget(OsmChange element) => PhoneInputField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      tags.containsKey('phone') || tags.containsKey('contact:phone');
}

class PhoneInputField extends StatefulWidget {
  final PhonePresetField field;
  final OsmChange element;

  const PhoneInputField(this.field, this.element);

  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final TextEditingController _controller;
  late final List<String> numbers;
  late final String? countryIso;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    numbers = (widget.element.getContact('phone') ?? '')
        .split(';')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    countryIso = CountryCoder.instance.iso1A2Code(
      lat: widget.element.location.latitude,
      lon: widget.element.location.longitude,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? format(String value) {
    if (value.length < 5) return null;
    final kDigits = '0123456789'.split('');
    String digits = value.characters.where((p0) => kDigits.contains(p0)).string;
    if (value.startsWith('+') || digits.length >= 11) {
      final res = PhoneNumber.fromRaw('+$digits');
      return res.validate()
          ? '+${res.countryCode} ${res.getFormattedNsn()}'
          : null;
    }
    final res = countryIso != null
        ? PhoneNumber.fromIsoCode(countryIso!, value)
        : PhoneNumber.fromRaw(value);
    if (!res.validate()) return null;
    if (!value.contains('-')) {
      value = res.getFormattedNsn();
    }
    return '+${res.countryCode} ${res.getFormattedNsn()}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: widget.field.label,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) =>
              value != null && value.isNotEmpty && format(value.trim()) == null
                  ? 'Wrong phone'
                  : null,
          onFieldSubmitted: (value) {
            final phone = format(value.trim());
            if (phone == null) return;
            _controller.clear();
            if (numbers.contains(phone)) return;
            setState(() {
              numbers.add(phone);
              widget.element.setContact('phone', numbers.join('; '));
            });
          },
        ),
        for (final number in numbers)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                color: Colors.blueGrey.shade50,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: GestureDetector(
                      child: Text(number, style: kFieldTextStyle),
                      onTap: () {
                        if (kFollowLinks && RegExp(r'^\+?[0-9 .-]+$').hasMatch(number)) {
                          launch('tel:$number');
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    child: Icon(Icons.close, size: 30.0),
                    onTap: () {
                      setState(() {
                        numbers.remove(number);
                        widget.element.setContact('phone', numbers.join('; '));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
