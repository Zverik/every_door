import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ChangeListPage extends ConsumerWidget {
  const ChangeListPage({Key? key}) : super(key: key);

  String formatTime(String format) {
    final now = DateTime.now();
    final values = {
      'YY': now.year.toString().padLeft(2, '0'),
      'mm': now.month.toString().padLeft(2, '0'),
      'dd': now.day.toString().padLeft(2, '0'),
      'HH': now.hour.toString().padLeft(2, '0'),
      'MM': now.minute.toString().padLeft(2, '0'),
    };
    String result =
        format.replaceFirst('YYYY', now.year.toString().padLeft(4, '0'));
    values.forEach((key, value) {
      result = result.replaceFirst(key, value);
    });
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = ref.watch(changesProvider);
    final login = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${changes.length} changes'),
        actions: [
          IconButton(
            onPressed: () async {
              String changeset = ref.read(osmApiProvider).buildOsmChange(changes.all(true), null);
              final tempDir = await getTemporaryDirectory();
              File tmpFile =
                  File('${tempDir.path}/everydoor-${formatTime("YYmmdd")}.osc');
              await tmpFile.writeAsString(changeset, flush: true);
              await Share.shareFiles(
                [tmpFile.path],
                mimeTypes: ['application/xml'],
                subject:
                    'Changes from $kAppTitle on ${formatTime("YYYY-mm-dd HH:MM")}',
              );
              tmpFile.delete();
            },
            icon: Icon(Icons.share),
          ),
          changes.haveNoErrorChanges()
              ? Container()
              : IconButton(
                  onPressed: () async {
                    final answer = await showOkCancelAlertDialog(
                      context: context,
                      title: 'Purge changes?',
                      message:
                          'Delete all recorded changes and restore the original data?',
                      okLabel: 'Yes',
                      cancelLabel: 'No',
                    );
                    if (answer == OkCancelResult.ok) {
                      ref.read(changesProvider).clearChanges(true);
                    }
                  },
                  icon: Icon(Icons.delete_forever),
                ),
          IconButton(
            onPressed: () async {
              if (login == null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OsmAccountPage()));
                return;
              }
              try {
                int count = await ref.read(osmApiProvider).uploadChanges(true);
                AlertController.show('Uploaded', 'Sent $count changes to API.',
                    TypeAlert.success);
                Navigator.pop(context);
              } on Exception catch (e) {
                // TODO: prettify the message?
                AlertController.show(
                    'Upload failed', e.toString(), TypeAlert.error);
              }
            },
            icon: Icon(Icons.upload),
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final change = changes[index];
          return ListTile(
            title: Text(change.typeAndName),
            subtitle: Text(change.error ?? 'Pending'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PoiEditorPage(amenity: change)),
              );
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: changes.length,
      ),
    );
  }
}
