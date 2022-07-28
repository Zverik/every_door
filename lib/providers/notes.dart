import 'package:every_door/models/note.dart';
import 'package:every_door/providers/database.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final notesProvider = Provider((ref) => NotesProvider(ref));

class NotesProvider {
  static final _logger = Logger('NotesProvider');
  static const kNoteGeohashPrecision = 6;

  final Ref _ref;

  NotesProvider(this._ref);

  /// Returns notes from the database.
  Future<List<BaseNote>> fetchAllNotes(LatLng center, [double? radius]) async {
    final database = await _ref.read(databaseProvider).database;
    radius ??= 1000.0; // meters
    final hashes = createGeohashes(
        center.latitude, center.longitude, radius, kNoteGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");

    final mapNoteData = await database.query(
      BaseNote.kTableName,
      where: 'geohash in ($placeholders)',
      whereArgs: hashes,
    );
    return mapNoteData.map((data) => MapNote.fromJson(data)).toList();
  }

  /// Downloads OSM notes and drawings from servers.
  downloadNotes(LatLng center) async {
    // TODO
  }

  uploadNotes() async {
    // TODO
  }

  saveNote(BaseNote note) async {
    _logger.info('Saving $note');
    final database = await _ref.read(databaseProvider).database;
    await database.insert(
      BaseNote.kTableName,
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  deleteNote(BaseNote note) async {
    if (!note.deleting) {
      note.deleting = true;
      await saveNote(note);
    }
  }
}
