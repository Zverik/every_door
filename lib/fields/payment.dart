import 'package:every_door/fields/helpers/payment_config.dart';
import 'package:every_door/providers/payment.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:every_door/helpers/payment_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const kGenericKeys = ['cards', 'debit_cards', 'credit_cards'];

class PaymentPresetField extends PresetField {
  PaymentPresetField({
    required super.label,
  }) : super(key: 'payment', icon: Icons.credit_card);

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
  ConsumerState createState() => _PaymentCheckboxInputFieldState();
}

class _Value {
  static const String yes = 'yes';
  static const String no = 'no';
  static const String? clear = null;
}

class _PaymentCheckboxInputFieldState
    extends ConsumerState<PaymentCheckboxInputField> {
  PaymentOptions options = PaymentOptions.initial;

  @override
  initState() {
    super.initState();
    updateCommonPayment();
  }

  updateCommonPayment() async {
    options = await ref
        .read(paymentProvider)
        .getAllPaymentOptions(widget.element.location);
    setState(() {});
  }

  cardsGeneric(String? value) {
    for (final key in kGenericKeys) widget.element['payment:$key'] = value;
  }

  cash(String? value) {
    widget.element['payment:cash'] = value;
  }

  cards(String? value) {
    assert(value != 'no');
    if (value == null) {
      for (final key in kCardPaymentOptions) {
        widget.element.removeTag('payment:$key');
      }
    } else {
      for (var key in options.merged) {
        widget.element[key] = value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final vAccepted = loc.fieldCardsAccepted;
    final vNo = loc.fieldCardsNo;
    final vOnly = loc.fieldCardsOnly;

    String? value;
    final tags = widget.element.getFullTags();
    if (widget.field.haveGenericNo(tags)) {
      value = 'no';
    } else if (widget.field.haveCardYes(tags)) {
      value = tags['payment:cash'] == 'no' ? 'only' : 'accepted';
    }

    String configIcon = options.aroundDiffers ? '⚠️' : '⚙️';
    bool configFirst = options.aroundDiffers &&
        options.around.isNotEmpty &&
        options.local == null;

    return RadioField(
      options: [
        if (configFirst) 'defaults',
        'accepted',
        'no',
        'only',
        if (!configFirst) 'defaults'
      ],
      labels: [
        if (configFirst) configIcon,
        vAccepted,
        vNo,
        vOnly,
        if (!configFirst) configIcon
      ],
      keepFirst: configFirst,
      keepOrder: true,
      value: value,
      onChange: (newValue) async {
        if (newValue == 'defaults') {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PaymentSettingsPane(location: widget.element.location)),
          );
          updateCommonPayment();
        } else if (newValue == 'accepted') {
          // Remove "no" generic values and set commonly used
          cardsGeneric(_Value.clear);
          cards(_Value.yes);
          cash(_Value.yes);
        } else if (newValue == 'no') {
          // Remove cards "yes" values and set generic cards=no
          cards(_Value.clear);
          cardsGeneric(_Value.no);
          cash(_Value.yes);
        } else if (newValue == 'only') {
          cardsGeneric(_Value.clear);
          cards(_Value.yes);
          cash(_Value.no);
        } else {
          // null
          // Remove cards "yes" and generic "no"
          cardsGeneric(_Value.clear);
          cards(_Value.clear);
          cash(_Value.clear);
        }
      },
    );
  }
}
