import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_area.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:every_door/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider((_) => DatabaseHelper._());

class DatabaseHelper {
  static final _logger = Logger('DatabaseHelper');

  DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await createDatabase();
    _db = await recreateDatabaseIfBroken(_db!);
    return _db!;
  }

  Future<Database> recreateDatabaseIfBroken(Database db) async {
    try {
      await db.query(OsmChange.kTableName, columns: ['count(*)']);
    } on DatabaseException catch (e) {
      _logger.severe('Database is broken!', e);
      await deleteDatabase(kDatabaseName);
      return await createDatabase();
    }
    return db;
  }

  Future<Database> createDatabase() async {
    if (kEraseDatabase && kDebugMode) {
      _logger.warning('Erasing database! Disable this in constants.dart.');
      await deleteDatabase(kDatabaseName);
    }

    return await openDatabase(
      kDatabaseName,
      version: 4,
      onCreate: initDatabase,
      onUpgrade: upgradeDatabase,
    );
  }

  void initDatabase(Database database, int version) async {
    // Raw osm data
    await database.execute(
        "create table ${OsmElement.kTableName} (${OsmElement.kTableFields.join(', ')})");
    await database.execute(
        "create index ${OsmElement.kTableName}_geohash on ${OsmElement.kTableName} (geohash)");

    // Downloaded regions
    await database.execute(
        "create table ${OsmDownloadedArea.kTableName} (${OsmDownloadedArea.kTableFields.join(', ')})");

    // Amenities
    await database.execute(
        "create table ${OsmChange.kTableName} (${OsmChange.kTableFields.join(', ')})");

    // Road names
    await database.execute(
        "create table ${RoadNameRecord.kTableName} (${RoadNameRecord.kTableFields.join(', ')})");
    await database.execute(
        "create index ${RoadNameRecord.kTableName}_geohash on ${RoadNameRecord.kTableName} (geohash)");
  }

  void upgradeDatabase(
      Database database, int oldVersion, int newVersion) async {
    if (newVersion >= 2 && oldVersion < 2) {
      await database.execute(
          "alter table ${OsmElement.kTableName} add column is_member integer");
    }
    if (newVersion >= 3 && oldVersion < 3) {
      try {
        await database.execute(
            "alter table ${OsmChange.kTableName} add column updated integer");
      } on DatabaseException catch (e) {
        _logger.warning('Looks like column "updated" was already present.', e);
      }
    }
    if (newVersion >= 4 && oldVersion < 4) {
      await database.execute(
          "create table ${RoadNameRecord.kTableName} (${RoadNameRecord.kTableFields.join(', ')})");
      await database.execute(
          "create index ${RoadNameRecord.kTableName}_geohash on ${RoadNameRecord.kTableName} (geohash)");
    }
    // Create new table for terms and preset names?
  }
}
