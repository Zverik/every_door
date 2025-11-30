import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/events.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:latlong2/latlong.dart';

final uploaderProvider = Provider((ref) => UploaderProvider(ref));

class UploaderProvider {
  final Ref _ref;

  UploaderProvider(this._ref);

  Future<void> upload(BuildContext context) async {
    if (_ref.read(authProvider.notifier).osmUser == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AccountPage('osm')));
      return;
    }

    final loc = AppLocalizations.of(context)!;
    try {
      int dataCount = await _ref.read(osmApiProvider).uploadChanges(true);
      int noteCount = await _ref.read(notesProvider).uploadNotes();
      await uploadPluginData();
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

  Future<void> uploadPluginData() async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.uploadingPlugin;
    try {
      await _ref.read(eventsProvider.notifier).callUpload();
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }

  Future<void> downloadPluginData(LatLng location) async {
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.downloadingPlugin;
    try {
      await _ref.read(eventsProvider.notifier).callDownload(location);
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }

  Future<void> download(BuildContext context) async {
    final location = _ref.read(effectiveLocationProvider);
    final provider = _ref.read(osmDataProvider);
    final loc = AppLocalizations.of(context)!;

    try {
      final count = await provider.downloadAround(location);
      AlertController.show(loc.dataDownloadSuccessful,
          loc.dataDownloadedCount(count), TypeAlert.success);
    } on Exception catch (e) {
      AlertController.show(
          loc.dataDownloadFailed, e.toString(), TypeAlert.error);
      return;
    }
    _ref.read(presetProvider).clearFieldCache();
    _ref.read(presetProvider).cacheComboOptions();

    try {
      await _ref.read(notesProvider).downloadNotes(location);
    } on Exception catch (e) {
      // TODO: message about notes
      AlertController.show(
          loc.dataDownloadFailed, e.toString(), TypeAlert.error);
    }

    await downloadPluginData(location);
    // updateAreaStatus();
    _ref.read(needMapUpdateProvider).trigger();
  }
}
