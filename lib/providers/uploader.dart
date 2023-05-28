import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final uploaderProvider = Provider((ref) => UploaderProvider(ref));

class UploaderProvider {
  final Ref _ref;

  UploaderProvider(this._ref);

  Future<void> upload(BuildContext context) async {
    if (_ref.read(authProvider) == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OsmAccountPage()));
      return;
    }

    final loc = AppLocalizations.of(context)!;
    try {
      int dataCount = await _ref.read(osmApiProvider).uploadChanges(true);
      int noteCount = await _ref.read(notesProvider).uploadNotes();
      _ref.read(needMapUpdateProvider).trigger();
      // TODO: separate note count in the message?
      AlertController.show(
          loc.changesUploadedTitle,
          loc.changesUploadedMessage(loc.changesCount(dataCount + noteCount)),
          TypeAlert.success);
    } on Exception catch (e) {
      AlertController.show(
          loc.changesUploadFailedTitle, e.toString(), TypeAlert.error);
    }
  }
}