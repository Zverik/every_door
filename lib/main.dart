import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/screens/loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';

void main() {
  runApp(ProviderScope(child: const EveryDoorApp()));
}

class EveryDoorApp extends StatelessWidget {
  const EveryDoorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoadingPage(),
      builder: (context, child) => Stack(children: [
        if (child != null) child,
        DropdownAlert(),
      ]),
    );
  }
}
