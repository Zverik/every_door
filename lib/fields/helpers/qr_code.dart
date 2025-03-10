import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeScanner extends StatefulWidget {
  static const kEnabled = true;

  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  static final _logger = Logger('QrCodeScanner');

  String? _scannedLast;

  Future<Uri> _resolveRedirects(Uri uri, [int depth = 0]) async {
    final client = http.Client();
    try {
      final request = http.Request('HEAD', uri);
      request.followRedirects = false;
      final streamed =
          await client.send(request).timeout(Duration(milliseconds: 1000));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 301 && response.statusCode < 400) {
        // This is a redirect.
        final newUrl = response.headers['location'];
        _logger.info('Found redirect: $uri → $newUrl');
        if (newUrl != null) {
          try {
            final newUri = Uri.parse(newUrl);
            return depth < 3
                ? await _resolveRedirects(newUri, depth + 1)
                : newUri;
          } on FormatException {
            // do nothing
          }
        }
      }
    } finally {
      client.close();
    }
    return uri;
  }

  Future<Uri?> _resolveRedirectsStr(String url) async {
    try {
      final uri = await _resolveRedirects(Uri.parse(url));
      return uri;
    } on FormatException {
      _logger.warning('Failed to build an uri from $url');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldWebsiteQR),
      ),
      body: MobileScanner(
        onDetect: (codes) async {
          final code = codes.barcodes.first;
          if (code.rawValue != _scannedLast && mounted && codes.barcodes.isNotEmpty) {
            // we need this because it scans twice sometimes
            _scannedLast = code.rawValue;

            final nav = Navigator.of(context);
            String? stringUrl;
            Uri? url;
            if (code.type == BarcodeType.url) {
              stringUrl = code.url?.url;
              if (stringUrl != null) {
                url = await _resolveRedirectsStr(stringUrl);
              }
            } else if (code.type == BarcodeType.text ||
                code.type == BarcodeType.unknown) {
              final value = code.displayValue;
              if (value != null && value.startsWith("http")) {
                url = await _resolveRedirectsStr(value);
              }
            }

            if (url != null) {
              if (mounted) nav.pop(url);
            }
          }
        },
      ),
    );
  }
}
