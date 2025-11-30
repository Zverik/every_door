import 'package:every_door/constants.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final pluginDatabaseProvider = Provider((_) => PluginDatabaseHelper._());

class PluginDatabaseHelper {
  static const _kDatabaseName = 'every_door_plugins.db';

  PluginDatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await createDatabase();
    return _db!;
  }

  Future<Database> createDatabase() async {
    if (kEraseDatabase && kDebugMode) {
      await deleteDatabase(_kDatabaseName);
    }

    return await openDatabase(_kDatabaseName);
  }
}