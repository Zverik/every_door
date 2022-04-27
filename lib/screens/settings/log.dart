import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/private.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:every_door/helpers/log_store.dart';
import 'package:flutter/material.dart';

class LogDisplayPage extends ConsumerStatefulWidget {
  const LogDisplayPage();

  @override
  ConsumerState<LogDisplayPage> createState() => _LogDisplayPageState();
}

class _LogDisplayPageState extends ConsumerState<LogDisplayPage> {
  bool sentMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('System Log')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(child: Text(logStore.lines.join('\n'))),
      ),
      floatingActionButton: sentMessage
          ? null
          : FloatingActionButton(
              child: Icon(Icons.send),
              onPressed: () async {
                final message = await showTextInputDialog(
                  context: context,
                  title: 'Send the report',
                  textFields: [
                    DialogTextField(maxLines: 2, hintText: 'Message to Ilya')
                  ],
                );
                if (message == null || message.isEmpty) return;

                String platform;
                if (Platform.isAndroid)
                  platform = 'android';
                else if (Platform.isIOS)
                  platform = 'ios';
                else
                  platform = 'unknown';

                List<String> lines = logStore.lines;
                if (lines.length > 50) lines = lines.sublist(lines.length - 50);
                http.post(
                  Uri.https('textual.ru', '/everydoor_send.php'),
                  body: <String, String>{
                    'code': kSecretKey,
                    'version': '$kAppTitle $platform $kAppVersion',
                    'who': ref.read(authProvider) ?? 'unknown',
                    'message': message.first,
                    'log': lines.join('\n'),
                  },
                );

                setState(() {
                  sentMessage = true;
                });
              },
            ),
    );
  }
}
