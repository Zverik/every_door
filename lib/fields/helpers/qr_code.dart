import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeScanner extends StatefulWidget {
  static const kEnabled = true;

  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldWebsiteQR),
      ),
      body: MobileScanner(
        onDetect: (codes) {
          if (!done && mounted && codes.barcodes.isNotEmpty) {
            final code = codes.barcodes.first;
            String? url;
            if (code.type == BarcodeType.url) {
              url = code.url?.url;
            } else if (code.type == BarcodeType.text ||
                code.type == BarcodeType.unknown) {
              final value = code.displayValue;
              if (value != null && value.startsWith("http")) {
                url = value;
              }
            }

            if (url != null) {
              done = true; // we need this because it scans twice sometimes
              Navigator.pop(context, url);
            }
          }
        },
      ),
    );
  }
}
