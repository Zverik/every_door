import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/helpers/combo_page.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/tags/payment_tags.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/payment.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class PaymentSettingsPane extends ConsumerStatefulWidget {
  final LatLng location;

  PaymentSettingsPane({super.key, required this.location});

  @override
  ConsumerState<PaymentSettingsPane> createState() =>
      _PaymentSettingsPaneState();
}

class _PaymentSettingsPaneState extends ConsumerState<PaymentSettingsPane> {
  PaymentOptions options = PaymentOptions.initial;

  @override
  void initState() {
    super.initState();
    loadPayment();
  }

  Future<void> loadPayment() async {
    options =
        await ref.read(paymentProvider).getAllPaymentOptions(widget.location);
    setState(() {});
  }

  Future<Set<String>?> openPaymentCombo(Set<String> current) async {
    final locale = Localizations.localeOf(context);
    final navigator = Navigator.of(context);
    final combo =
        await ref.read(presetProvider).getField('payment_multi', locale);
    if (combo is ComboPresetField) {
      combo.options.removeWhere((element) => kNotCards.contains(element.value));
    }
    final List<String>? newValues = await navigator.push(
      MaterialPageRoute(
        builder: (context) => ComboChooserPage(
          combo as ComboPresetField,
          current.map((k) => k.replaceFirst('payment:', '')).toList(),
        ),
      ),
    );
    return newValues?.map((k) => 'payment:$k').toSet();
  }

  String formatOptions(Set<String> options) => options
      .map((o) => o.replaceFirst('payment:', ''))
      .sorted((a, b) => a.compareTo(b))
      .join(', ');

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool suggestLocal = options.aroundDiffers;
    const distance = DistanceEquirectangular();
    final distanceLocal = options.local == null
        ? 0
        : distance(widget.location, options.local!.center);

    return Scaffold(
      appBar: AppBar(title: Text(loc.fieldPaymentTitle)),
      body: ListView(
        children: [
          if (options.around.isNotEmpty) ...[
            ListTile(
              title: Text(loc.fieldPaymentAround),
              subtitle: Text(formatOptions(options.around)),
              leading: suggestLocal ? Icon(Icons.warning) : null,
            ),
            if (suggestLocal)
              TextButton(
                onPressed: () async {
                  final prov = ref.read(paymentProvider);
                  if (options.local == null || distanceLocal > 500)
                    await prov.saveLocalPayment(
                        options.around, widget.location);
                  else
                    await prov.updateLocalPayment(
                        options.local!.update(options.around));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Text(loc.fieldPaymentUseSame, style: kFieldTextStyle),
              ),
            if (suggestLocal && options.local == null)
              TextButton(
                onPressed: () async {
                  await ref
                      .read(paymentProvider)
                      .saveLocalPayment(options.global, widget.location);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Text(loc.fieldPaymentUseGlobal, style: kFieldTextStyle),
              ),
          ],
          if (options.local != null)
            ListTile(
              title: Text(loc.fieldPaymentLocal),
              subtitle: Text(formatOptions(options.local!.options)),
              trailing: Icon(Icons.edit),
              onTap: () async {
                final newValues =
                    await openPaymentCombo(options.local!.options);
                if (newValues != null) {
                  final prov = ref.read(paymentProvider);
                  if (newValues.isEmpty)
                    await prov.deleteLocalPayment(options.local!);
                  else
                    await prov
                        .updateLocalPayment(options.local!.update(newValues));
                  loadPayment();
                }
              },
            ),
          ListTile(
            title: Text(loc.fieldPaymentGlobal),
            subtitle: Text(formatOptions(options.global)),
            trailing: Icon(Icons.edit),
            onTap: () async {
              final newValues = await openPaymentCombo(options.global);
              if (newValues != null && newValues.isNotEmpty) {
                ref.read(editorSettingsProvider.notifier).setDefaultPayment(
                    newValues
                        .map((v) => v.replaceFirst('payment:', ''))
                        .toList());
                loadPayment();
              }
            },
          ),
          if (options.local == null)
            TextButton(
              onPressed: () async {
                final newValues = await openPaymentCombo({});
                if (newValues != null && newValues.isNotEmpty) {
                  final prov = ref.read(paymentProvider);
                  await prov.saveLocalPayment(newValues, widget.location);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(loc.fieldPaymentChoose, style: kFieldTextStyle),
            ),
        ],
      ),
    );
  }
}

// A small bit of `iterable_extensions.dart` that we use here.
extension SortingIterable<T> on Iterable<T> {
  List<T> sorted([Comparator<T>? compare]) => [...this]..sort(compare);
}
