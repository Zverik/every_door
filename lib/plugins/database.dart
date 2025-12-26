// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
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