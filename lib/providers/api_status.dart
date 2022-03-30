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
  // TODO: localize
  switch (status) {
    case ApiStatus.idle:
      return 'Idle';
    case ApiStatus.downloading:
      return 'Downloading data';
    case ApiStatus.updatingDatabase:
      return 'Saving elements to the database';
    case ApiStatus.uploading:
      return 'Uploading changes';
  }
}
