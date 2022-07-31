import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  uploadChanges(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    if (ref.read(authProvider) == null) {
      navigator.push(MaterialPageRoute(builder: (context) => OsmAccountPage()));
      return;
    }

    final loc = AppLocalizations.of(context)!;
    try {
      int count = await ref.read(osmApiProvider).uploadChanges(true);
      AlertController.show(
          loc.changesUploadedTitle,
          loc.changesUploadedMessage(loc.changesCount(count)),
          TypeAlert.success);
      navigator.pop();
    } on Exception catch (e) {
      AlertController.show(
          loc.changesUploadFailedTitle, e.toString(), TypeAlert.error);
    }
  }

  downloadChanges(WidgetRef ref) async {
    final changes = ref.watch(changesProvider);
    final changeList = changes.all();
    String changeset =
        ref.read(osmApiProvider).buildOsmChange(changeList, null);
    final tempDir = await getTemporaryDirectory();
    File tmpFile =
        File('${tempDir.path}/everydoor-${formatTime("YYmmdd")}.osc');
    await tmpFile.writeAsString(changeset, flush: true);
    await Share.shareFiles(
      [tmpFile.path],
      mimeTypes: ['application/xml'],
      subject:
          '${changeList.length} changes from $kAppTitle on ${formatTime("YYYY-mm-dd HH:MM")}',
    );
    tmpFile.delete();
  }

  IconData getTypeIcon(ElementKind kind) {
    switch (kind) {
      case ElementKind.amenity:
        return Icons.shopping_cart;
      case ElementKind.micro:
        return Icons.park;
      case ElementKind.building:
        return Icons.home;
      case ElementKind.entrance:
        return Icons.door_front_door;
      default:
        return Icons.question_mark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changes = ref.watch(changesProvider);
    final changeList = changes.all();
    changeList.sort((a, b) => b.updated.compareTo(a.updated));
    final hasManyTypes = changeList.map((e) => e.kind).toSet().length > 1;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.changesCount(changes.length)),
        actions: [
          IconButton(
            onPressed: () {
              downloadChanges(ref);
            },
            icon: Icon(Icons.share),
          ),
          changes.length == 0 || changes.haveNoErrorChanges()
              ? Container()
              : IconButton(
                  onPressed: () async {
                    final answer = await showOkCancelAlertDialog(
                      context: context,
                      title: loc.changesPurgeTitle,
                      message: loc.changesPurgeMessage,
                      okLabel: loc.buttonYes,
                      cancelLabel: loc.buttonNo,
                    );
                    if (answer == OkCancelResult.ok) {
                      ref
                          .read(changesProvider)
                          .clearChanges(includeErrored: true);
                      ref.read(needMapUpdateProvider).trigger();
                    }
                  },
                  icon: Icon(Icons.delete_forever),
                ),
          IconButton(
            onPressed: ref.watch(apiStatusProvider) != ApiStatus.idle
                ? null
                : () {
                    uploadChanges(context, ref);
                  },
            icon: Icon(Icons.upload),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final change = changeList[index];
                return Dismissible(
                  key: Key(change.databaseId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    changes.deleteChange(change);
                    ref.read(needMapUpdateProvider).trigger();

                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(loc.changesDeletedChange(change.typeAndName)),
                      action: SnackBarAction(
                        label: loc.changesDeletedUndo.toUpperCase(),
                        onPressed: () {
                          changes.saveChange(change);
                        },
                      ),
                    ));
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.only(right: 15.0),
                    child: Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                  ),
                  child: ListTile(
                    title: Text(change.typeAndName),
                    subtitle: Text(change.error ?? loc.changesPending),
                    trailing:
                        !hasManyTypes ? null : Icon(getTypeIcon(change.kind)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PoiEditorPage(amenity: change)),
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: changeList.length,
            ),
          ),
          if (changeList.length <= 5)
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Center(
                child: Text(
                  loc.changesSwipeLeft,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
