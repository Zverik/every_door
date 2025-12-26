// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferencesWithCache>(
    (_) async => SharedPreferencesWithCache.create(
        cacheOptions: SharedPreferencesWithCacheOptions()));

Future<void> migrateSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
    legacySharedPreferencesInstance: prefs,
    sharedPreferencesAsyncOptions: SharedPreferencesOptions(),
    migrationCompletedKey: 'spMigrationCompleted',
  );
}
