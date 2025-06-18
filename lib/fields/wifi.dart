import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class WifiPresetField extends PresetField {
  WifiPresetField({
    required super.label,
  }) : super(key: 'internet_access', icon: Icons.wifi);

  @override
  Widget buildWidget(OsmChange element) => WifiInputField(this, element);
}

class WifiInputField extends StatefulWidget {
  final WifiPresetField field;
  final OsmChange element;

  const WifiInputField(this.field, this.element);

  @override
  State<WifiInputField> createState() => _WifiInputFieldState();
}

class _WifiInputFieldState extends State<WifiInputField> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final vPublic = loc.fieldWifiPublic;
    final vCustomers = loc.fieldWifiCustomers;
    final vNo = loc.fieldWifiNo;

    String? value;
    final access = widget.element['internet_access'];
    if (access == null) {
      value = null;
    } else if (access == 'wlan' || access == 'yes') {
      value = widget.element['internet_access:fee'] == 'no' ? 'public' : 'customers';
    } else {
      value = access;
    }

    return RadioField(
      options: const ['public', 'customers', 'no'],
      labels: [vPublic, vCustomers, vNo],
      value: value,
      onChange: (newValue) {
        setState(() {
          if (newValue == null) {
            widget.element.removeTag('internet_access');
            widget.element.removeTag('internet_access:fee');
          } else if (newValue == 'no') {
            widget.element['internet_access'] = 'no';
            widget.element.removeTag('internet_access:fee');
          } else {
            widget.element['internet_access'] = 'wlan';
            widget.element['internet_access:fee'] = newValue == 'customers' ? 'customers' : 'no';
          }
        });
      },
    );
  }
}
