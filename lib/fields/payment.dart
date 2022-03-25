import 'package:every_door/fields/helpers/radio_field.dart';
import 'package:every_door/helpers/payment_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const kGenericKeys = ['cards', 'debit_cards', 'credit_cards'];

class PaymentPresetField extends PresetField {
  PaymentPresetField({
    required String label,
  }) : super(key: 'payment', label: label, icon: Icons.credit_card);

  @override
  Widget buildWidget(OsmChange element) =>
      PaymentCheckboxInputField(this, element);

  bool haveGenericNo(Map<String, String> tags) =>
      kGenericKeys.any((key) => tags['payment:$key'] == 'no');

  bool haveCardYes(Map<String, String> tags) =>
      kCardPaymentOptions.any((key) => tags['payment:$key'] == 'yes');

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      haveGenericNo(tags) || haveCardYes(tags);
}

class PaymentCheckboxInputField extends ConsumerStatefulWidget {
  final PaymentPresetField field;
  final OsmChange element;

  const PaymentCheckboxInputField(this.field, this.element);

  @override
  _PaymentCheckboxInputFieldState createState() =>
      _PaymentCheckboxInputFieldState();
}

class _PaymentCheckboxInputFieldState
    extends ConsumerState<PaymentCheckboxInputField> {
  Iterable<String> commonPayment = ['payment:visa', 'payment:mastercard'];

  @override
  initState() {
    super.initState();
    updateCommonPayment();
  }

  updateCommonPayment() async {
    final osmData = ref.read(osmDataProvider);
    final tags = await osmData.getCardPaymentOptions(widget.element.location);
    setState(() {
      commonPayment = tags;
    });
  }

  genericNo(bool remove) {
    for (final key in kGenericKeys)
      widget.element['payment:$key'] = remove ? null : 'no';
  }

  paymentYes(bool remove) {
    if (remove) {
      for (final key in kCardPaymentOptions) {
        widget.element.removeTag('payment:$key');
      }
    } else {
      for (var key in commonPayment) {
        widget.element[key] = 'yes';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final vAccepted = loc.fieldCardsAccepted;
    final vNo = loc.fieldCardsNo;

    String? value;
    final tags = widget.element.getFullTags();
    if (widget.field.haveGenericNo(tags))
      value = 'no';
    else if (widget.field.haveCardYes(tags)) value = 'accepted';

    return RadioField(
      options: const ['accepted', 'no'],
      labels: [vAccepted, vNo],
      value: value,
      onChange: (newValue) {
        if (newValue == 'accepted') {
          // Remove "no" generic values and set commonly used
          genericNo(true);
          paymentYes(false);
        } else if (newValue == 'no') {
          // Remove cards "yes" values and set generic cards=no
          paymentYes(true);
          genericNo(false);
        } else {
          // null
          // Remove cards "yes" and generic "no"
          genericNo(true);
          paymentYes(true);
        }
      },
    );
  }
}
