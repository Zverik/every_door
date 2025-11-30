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
