import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final apiStatusProvider = StateProvider<ApiStatus>((ref) => ApiStatus.idle);

enum ApiStatus {
  idle,
  downloading,
  updatingDatabase,
  uploading,
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
  }
}
