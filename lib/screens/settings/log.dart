import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter/services.dart';
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
  static const kMaxLogLinesToSend = 20;
  bool sentMessage = true; // TODO: fix sendmail on the server
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  void _copyAllLogsToClipboard() {
    final logText = logStore.lines.join('\n');
    Clipboard.setData(ClipboardData(text: logText));

    // Show a snackbar to provide user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (logStore.isEmpty) {
      body = Center(
        child: Text(
          'No system messages',
          style:
              TextStyle(fontStyle: FontStyle.italic, fontSize: kFieldFontSize),
        ),
      );
    } else {
      body = SingleChildScrollView(
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(logStore.last(30).join('\n')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('System Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: 'Copy All Logs',
            onPressed: logStore.isEmpty ? null : _copyAllLogsToClipboard,
          ),
        ],
      ),
      body: body,
      floatingActionButton: sentMessage || logStore.isEmpty
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
                  platform = 'Android';
                else if (Platform.isIOS)
                  platform = 'iOS';
                else
                  platform = 'unknown';

                http.post(
                  Uri.https('textual.ru', '/everydoor_send.php'),
                  body: <String, String>{
                    'code': 'rfJ7gnvut4%uHY6',
                    'version': '$kAppTitle $platform $kAppVersion',
                    'who': ref.read(authProvider)?.displayName ?? 'unknown',
                    'message': message.first,
                    'log': logStore.last(kMaxLogLinesToSend).join('\n'),
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
