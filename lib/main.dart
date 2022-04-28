import 'dart:async';
import 'dart:io';

import 'package:every_door/helpers/log_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/screens/loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    runApp(const EveryDoorApp());
  }, (error, stack) {
    logStore.addFromZone(error, stack);
  });
}

installCertificate() async {
  ByteData data =
      await PlatformAssetBundle().load('assets/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
}

class EveryDoorApp extends StatelessWidget {
  const EveryDoorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: kAppTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          hintColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoadingPage(),
        builder: (context, child) => Stack(children: [
          if (child != null) child,
          DropdownAlert(),
        ]),
      ),
    );
  }
}
