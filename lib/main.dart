// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:async';
import 'dart:io';

import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/log_store.dart';
import 'package:every_door/providers/app_links_provider.dart';
import 'package:every_door/providers/language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/screens/loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = kDebugMode ? Level.INFO : Level.WARNING;
  Logger.root.onRecord.listen((event) {
    logStore.addFromLogger(event);
  });
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    installCertificate();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logStore.addFromFlutter(details);
    };
    ElementKind.reset();
    runApp(ProviderScope(child: const EveryDoorMainApp()));
  }, (error, stack) {
    logStore.addFromZone(error, stack);
  });
}

Future<void> installCertificate() async {
  ByteData data =
      await PlatformAssetBundle().load('assets/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
}

class EveryDoorMainApp extends ConsumerWidget {
  const EveryDoorMainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Portal(
      child: MaterialApp(
        title: kAppTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          hintColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          useMaterial3: false,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // Adding "en" to the front so it's used by default.
        supportedLocales: [Locale('en')] + AppLocalizations.supportedLocales,
        locale: ref.watch(languageProvider),
        navigatorKey: ref.read(geoIntentProvider).navigatorKey,
        home: LoadingPage(),
        builder: (context, child) => Stack(children: [
          if (child != null) child,
          DropdownAlert(delayDismiss: 5000),
        ]),
      ),
    );
  }
}
