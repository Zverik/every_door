// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/providers/api_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class ApiStatusPane extends ConsumerWidget {
  const ApiStatusPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiStatus = ref.watch(apiStatusProvider);
    if (apiStatus == ApiStatus.idle) return Container();

    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.0),
        margin: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withValues(alpha: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20.0),
            Text(
              getApiStatusLoc(apiStatus, loc),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
