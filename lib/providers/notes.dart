import 'package:every_door/constants.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/database.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:riverpod/riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

final notesProvider = Provider((ref) => NotesProvider(ref));

class NotesProvider {
  static final _logger = Logger('NotesProvider');
  static const kNoteGeohashPrecision = 6;

  Ref _ref;
  
  NotesProvider(this._ref);

  /// Returns notes from the database.
  Future<List<BaseNote>> fetchAllNotes(LatLng center) async {
    final database = await _ref.read(databaseProvider).database;
    const radius = 0.1; // degrees
    final hashes = createGeohashes(center.latitude, center.longitude,
        radius.toDouble(), kNoteGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");

    final mapNoteData = await database.query(
      BaseNote.kTableName,
      where: 'geohash in ($placeholders)',
      whereArgs: hashes,
    );
    return mapNoteData.map((data) => MapNote.fromJson(data)).toList();
  }

  /// Downloads OSM notes and drawings from servers.
  Future downloadNotes(LatLng center) async {

  }
}