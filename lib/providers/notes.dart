import 'dart:convert';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/osm_api_converters.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/utils/utils.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

final notesProvider = ChangeNotifierProvider((ref) => NotesProvider(ref));

class NotesProvider extends ChangeNotifier {
  static final _logger = Logger('NotesProvider');

  final Ref _ref;
  int length = 0;

  bool get haveChanges => length > 0;

  NotesProvider(this._ref) {
    _checkHaveChangesAndNotify();
  }

  _checkHaveChangesAndNotify() async {
    final database = await _ref.read(databaseProvider).database;
    final count = firstIntValue(await database.query(
      BaseNote.kTableName,
      columns: ['count(*)'],
      where: 'is_changed = 1',
    ));
    length = count ?? 0;
    notifyListeners();
  }

  Future<List<BaseNote>> fetchChanges() async {
    final database = await _ref.read(databaseProvider).database;
    final result = await database.query(
      BaseNote.kTableName,
      where: 'is_changed = 1',
    );
    return result.map((data) => BaseNote.fromJson(data)).toList();
  }

  /// Returns notes from the database.
  Future<List<BaseNote>> fetchAllNotes(LatLng center, [double? radius]) async {
    final database = await _ref.read(databaseProvider).database;
    radius ??= 1000.0; // meters
    final hashes = createGeohashes(center.latitude, center.longitude, radius,
        BaseNote.kNoteGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");

    final mapNoteData = await database.query(
      BaseNote.kTableName,
      where: 'geohash in ($placeholders)',
      whereArgs: hashes,
    );
    return mapNoteData.map((data) => BaseNote.fromJson(data)).toList();
  }

  /// Returns only OSM notes from the database.
  Future<List<OsmNote>> fetchOsmNotes(LatLng center, [int? radius]) async {
    final database = await _ref.read(databaseProvider).database;
    radius ??= 1000; // meters
    final hashes = createGeohashes(center.latitude, center.longitude,
        radius.toDouble(), BaseNote.kNoteGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");

    final mapNoteData = await database.query(
      BaseNote.kTableName,
      where: 'geohash in ($placeholders) and type = ${OsmNote.dbType}',
      whereArgs: hashes,
    );
    return mapNoteData
        .map((data) => BaseNote.fromJson(data))
        .whereType<OsmNote>()
        .toList();
  }

  /// Downloads OSM notes and drawings from servers.
  downloadNotes(LatLng center) async {
    final bounds = boundsFromRadius(center, kBigRadius);
    await Future.wait([
      _downloadOsmNotes(bounds),
      _downloadMapNotes(bounds),
    ]);
    _checkHaveChangesAndNotify();
  }

  /// Uploads modified OSM notes and drawings to servers.
  Future<int> uploadNotes() async {
    // Check whether we've authorized.
    final auth = _ref.read(authProvider.notifier);
    if (!auth.authorized) throw StateError('Log in first.');

    // Get changed notes from the database.
    final notes = await fetchChanges();
    if (notes.isEmpty) return 0;

    // Upload all notes concurrently.
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.uploadingNotes;
    try {
      await Future.wait([
        _uploadOsmNotes(notes.whereType<OsmNote>()),
        _uploadMapNotes(notes.where((n) => n is MapNote || n is MapDrawing)),
      ]);
      _checkHaveChangesAndNotify();
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
    return notes.length;
  }

  Future<List<BaseNote>> _downloadMapNotes(LatLngBounds bounds) async {
    final notes = <BaseNote>[];
    // TODO: clean the database and add downloaded notes
    return notes;
  }

  Future<void> _uploadMapNotes(Iterable<BaseNote> notes) async {
    if (notes.isEmpty) return;
    // final author = _ref.read(authProvider);
    // TODO: upload notes
    // TODO: mark all uploaded notes not changed
  }

  Future<List<OsmNote>> _downloadOsmNotes(LatLngBounds bounds) async {
    final notes = <OsmNote>[];
    final url = Uri.https(kOsmEndpoint, '/api/0.6/notes', {
      'bbox': '${bounds.west},${bounds.south},${bounds.east},${bounds.north}',
    });
    var client = http.Client();
    var request = http.Request('GET', url);
    try {
      var response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Failed to query OSM API: ${response.statusCode} $url');
      }
      final elements = await response.stream
          .transform(utf8.decoder)
          .toXmlEvents()
          .selectSubtreeEvents((event) => event.localName == 'note')
          .toXmlNodes()
          .transform(XmlToNotesConverter())
          .flatten()
          .toList();
      notes.addAll(elements);
    } finally {
      client.close();
    }

    // Now clean the database and add downloaded notes.
    final database = await _ref.read(databaseProvider).database;
    await database.transaction((txn) async {
      // Clear OSM notes for the area.
      await txn.delete(
        BaseNote.kTableName,
        where: 'type = ? and id >= 0 and lat >= ? and lat <= ? and lon >= ? and lon <= ?',
        whereArgs: [
          OsmNote.dbType,
          bounds.south * kCoordinatePrecision,
          bounds.north * kCoordinatePrecision,
          bounds.west * kCoordinatePrecision,
          bounds.east * kCoordinatePrecision,
        ],
      );

      // Upload new notes.
      final batch = txn.batch();
      for (final note in notes) {
        batch.insert(
          BaseNote.kTableName,
          note.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });

    return notes;
  }

  OsmNote? _parseNoteXML(String body) {
    final doc = XmlDocument.parse(body);
    final nodes = doc.findAllElements('note');
    if (nodes.isEmpty) return null;
    return XmlToNotesConverter.convertNode(nodes.first);
  }

  Future<void> _uploadOsmNotes(Iterable<OsmNote> notes) async {
    if (notes.isEmpty) return;
    final auth = _ref.read(authProvider.notifier);
    final headers = await auth.getAuthHeaders();
    for (final note in notes) {
      int? noteId = note.id;
      if (noteId == null) continue;
      if (note.isNew && note.deleting) continue;
      if (note.isNew) {
        // Create a note and update its id.
        final url = Uri.https(kOsmEndpoint, '/api/0.6/notes', {
          'lat': note.location.latitude.toString(),
          'lon': note.location.longitude.toString(),
          'text': note.message,
        });
        final resp = await http.post(url, headers: headers);
        if (resp.statusCode != 200) {
          _logger
              .severe('Error creating note: ${resp.statusCode} ${resp.body}');
          continue;
        }
        final newNote = _parseNoteXML(resp.body);
        if (newNote != null) await saveNote(newNote, notify: false);
        deleteNote(note, notify: false);
      } else {
        for (final comment in note.comments) {
          if (comment.isNew) {
            // Add a comment.
            final url = Uri.https(kOsmEndpoint,
                '/api/0.6/notes/$noteId/comment', {'text': comment.message});
            final resp = await http.post(url, headers: headers);
            if (resp.statusCode != 200) {
              _logger.severe(
                  'Error adding a note comment: ${resp.statusCode} ${resp.body}');
              continue;
            }
            final newNote = _parseNoteXML(resp.body);
            if (newNote != null) await saveNote(newNote, notify: false);
          }
        }
      }

      if (note.deleting) {
        // Close the note.
        final url = Uri.https(kOsmEndpoint, '/api/0.6/notes/$noteId/close');
        final resp = await http.post(url, headers: headers);
        if (resp.statusCode != 200) {
          _logger
              .severe('Error uploading note: ${resp.statusCode} ${resp.body}');
          continue;
        }
        deleteNote(note, notify: false);
      }
    }
  }

  saveNote(BaseNote note, {bool notify = true}) async {
    _logger.info('Saving $note');
    final database = await _ref.read(databaseProvider).database;
    note.id ??= await getNewNoteId();
    await database.insert(
      BaseNote.kTableName,
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (notify) _checkHaveChangesAndNotify();
  }

  Future<void> deleteNote(BaseNote note, {bool notify = true}) async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      BaseNote.kTableName,
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (notify) _checkHaveChangesAndNotify();
  }

  Future<int> purgeNotes(DateTime before) async {
    final database = await _ref.read(databaseProvider).database;
    int count = await database.delete(
      BaseNote.kTableName,
      where: 'is_changed = 0 and id >= 0',
    );
    _checkHaveChangesAndNotify();
    return count;
  }

  Future<void> clearChangedMapNotes() async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      BaseNote.kTableName,
      where: 'is_changed = 1 and (type = ? or type = ?)',
      whereArgs: [MapNote.dbType, MapDrawing.dbType],
    );
    _checkHaveChangesAndNotify();
  }

  Future<int> getNewNoteId() async {
    final database = await _ref.read(databaseProvider).database;
    final minId = firstIntValue(await database.query(
      BaseNote.kTableName,
      columns: ['min(id)'],
    ));
    return minId == null || minId > 0 ? -1 : minId - 1;
  }
}
