import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

final apiStatusProvider = StateProvider<ApiStatus>((ref) => ApiStatus.idle);

enum ApiStatus {
  idle,
  downloading,
  updatingDatabase,
  uploading,
  uploadingNotes,
}

String getApiStatusLoc(ApiStatus status, AppLocalizations loc) {
  switch (status) {
    case ApiStatus.idle:
      return 'Idle';
    case ApiStatus.downloading:
      return loc.apiStatusDownloading;
    case ApiStatus.updatingDatabase:
      return loc.apiStatusUpdatingDB;
    case ApiStatus.uploading:
      return loc.apiStatusUploading;
    case ApiStatus.uploadingNotes:
      return loc.apiStatusUploadingNotes;
  }
}
