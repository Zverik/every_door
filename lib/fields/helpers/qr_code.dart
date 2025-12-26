// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/tracking_params.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

/// Shows a QR code scanner and returns an [Uri] or a [null] if
/// it's cancelled. Note that it has a built-in tracking parameter
/// filter, and it _always_ sets a non-null (often empty) [Uri.query].
/// Meaning it won't be equal to an uri without a query.
/// Use [Uri.toStringFix] to convert it to a string for comparisons.
class QrCodeScanner extends StatefulWidget {
  static const kEnabled = true;
  final bool resolveRedirects;

  const QrCodeScanner({super.key, this.resolveRedirects = true});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  static final _logger = Logger('QrCodeScanner');

  String? _scannedLast;
  final _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _scannedLast = null;
  }

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
            Uri newUri = Uri.parse(newUrl);
            if (!newUri.hasAuthority) newUri = uri.resolveUri(newUri);
            return depth < 3
                ? await _resolveRedirects(newUri, depth + 1)
                : newUri;
          } on FormatException {
            // do nothing
          }
        }
      }
    } catch (e) {
      _logger.info('Error when checking for redirects: $e');
    } finally {
      client.close();
    }
    return uri;
  }

  Future<Uri?> _resolveRedirectsStr(String url) async {
    try {
      Uri uri = Uri.parse(url);
      if (widget.resolveRedirects) {
        uri = await _resolveRedirects(uri);
      }
      return uri;
    } on FormatException {
      _logger.warning('Failed to build an uri from $url');
    }
    return null;
  }

  Future<void> _parseCode(Barcode code) async {
    if (code.code != _scannedLast && mounted) {
      // We need this because mobile_scanner scanned twice sometimes.
      _scannedLast = code.code;

      final nav = Navigator.of(context);
      Uri? url;
      final value = code.code;
      if (value != null && value.startsWith("http")) {
        url = await _resolveRedirectsStr(value);
      }

      if (url != null) {
        // Remove tracking parameters.
        url = url.replace(
            queryParameters: Map.fromEntries(url.queryParameters.entries
                .where((e) => !kTrackingParams.contains(e.key))));
        if (url.query.isEmpty) {
          // Erase the lone "?" from the tail.
          url = Uri.parse(url.toStringFix());
        }
        if (mounted) nav.pop(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldWebsiteQR),
      ),
      body: QRView(
        key: _qrKey,
        onQRViewCreated: (QRViewController ctrl) {
          ctrl.scannedDataStream.listen((code) {
            if (!mounted) return;
            _parseCode(code);
          });
        },
      ),
    );
  }
}

extension ProperToString on Uri {
  String toStringFix() {
    final value = toString();
    if (value.endsWith('?')) return value.substring(0, value.length - 1);
    return value;
  }
}
