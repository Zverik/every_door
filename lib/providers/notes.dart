import 'dart:convert';
import 'dart:ui';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/draw_style.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/utils/utils.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

final notesProvider = ChangeNotifierProvider((ref) => NotesProvider(ref));
final ownScribblesProvider =
    StateNotifierProvider<OwnScribblesController, bool>(
        (_) => OwnScribblesController());

class NotesProvider extends ChangeNotifier {
  static final _logger = Logger('NotesProvider');

  final Ref _ref;
  int length = 0;
  List<(bool deleted, BaseNote note)> _undoStack = [];
  int _undoStackLast = 0;

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
  Future<List<BaseNote>> fetchAllNotes(
      {LatLngBounds? bounds,
      LatLng? center,
      int radius = 1000,
      bool osmOnly = false}) async {
    final database = await _ref.read(databaseProvider).database;
    List<String> hashes;
    if (bounds != null) {
      // Expand bounding box a little to account for long lines.
      // (We query by geohashes for their centers).
      const kExtendBounds = 0.001; // degrees, ~1100 m
      // TODO: bounds do not work consistently, see modes/nodes.dart
      final box = LatLngBounds.fromPoints([
        LatLng(bounds.south - kExtendBounds, bounds.west - kExtendBounds),
        LatLng(bounds.north + kExtendBounds, bounds.east + kExtendBounds),
      ]);
      hashes = createGeohashesBoundingBox(box.south, box.west, box.north,
          box.east, BaseNote.kNoteGeohashPrecision);
    } else if (center != null) {
      hashes = createGeohashes(center.latitude, center.longitude,
          radius.toDouble(), BaseNote.kNoteGeohashPrecision);
    } else {
      throw ArgumentError('Please specify either box or center');
    }
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final typeClause = osmOnly ? ' and type = ${OsmNote.dbType}' : '';

    final mapNoteData = await database.query(
      BaseNote.kTableName,
      where: 'geohash in ($placeholders)$typeClause',
      whereArgs: hashes,
    );
    return mapNoteData.map((data) => BaseNote.fromJson(data)).toList();
  }

  /// Returns only OSM notes from the database.
  Future<List<OsmNote>> fetchOsmNotes(LatLng center, [int? radius]) async {
    return (await fetchAllNotes(center: center, radius: radius ?? 1000))
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

  Future _cleanAndInsertNotes(
      LatLngBounds bounds, List<BaseNote> notes, List<int> dbTypes) async {
    final database = await _ref.read(databaseProvider).database;
    await database.transaction((txn) async {
      // Clear OSM notes for the area.
      final placeholders =
          List.generate(dbTypes.length, (index) => "?").join(",");
      await txn.delete(
        BaseNote.kTableName,
        where:
            'type in ($placeholders) and id >= 0 and lat >= ? and lat <= ? and lon >= ? and lon <= ?',
        whereArgs: [
          ...dbTypes,
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
  }

  Future<List<BaseNote>> _downloadMapNotes(LatLngBounds bounds) async {
    final ownNotesOnly = _ref.read(ownScribblesProvider);
    final author = _ref.read(authProvider);
    final url = Uri.https(kScribblesEndpoint, '/scribbles', {
      if (ownNotesOnly && author != null) 'user_id': author.id,
      'bbox': '${bounds.west},${bounds.south},${bounds.east},${bounds.north}',
    });
    var response = await http.get(url);
    if (response.statusCode != 200) {
      String msg = _extractError(response);
      throw Exception('Failed to query scribbles: ${response.statusCode} $msg');
    }

    final data = json.decode(response.body);
    final notes = <BaseNote>[];
    for (final noteData in data) {
      if (noteData.containsKey('points')) {
        final points = noteData['points'] as List<dynamic>;
        notes.add(MapDrawing(
          id: noteData['id'],
          author: noteData['username'],
          coordinates: points.map((ll) => LatLng(ll[1], ll[0])).toList(),
          pathType: noteData['style'],
        ));
      } else if (noteData.containsKey('location')) {
        final pt = noteData['location'] as List<dynamic>;
        notes.add(MapNote(
          id: noteData['id'],
          location: LatLng(pt[1], pt[0]),
          message: noteData['text'],
        ));
      }
    }

    await _cleanAndInsertNotes(
        bounds, notes, [MapDrawing.dbType, MapNote.dbType]);
    return notes;
  }

  String _colorToHex(Color c) =>
      c.value.toRadixString(16).padLeft(8, '0').substring(2);

  String _extractError(http.Response response) {
    String msg = response.request?.url.toString() ?? '';
    try {
      final errorData = json.decode(response.body) as Map<String, dynamic>;
      if (errorData.containsKey('detail')) {
        final detail = errorData['detail'] as List<dynamic>;
        if (detail.isNotEmpty && detail[0].containsKey('msg')) {
          msg = detail[0]['msg'];
        }
      }
    } on Exception {
      // nothing
    }
    return msg;
  }

  Future<void> _uploadMapNotes(Iterable<BaseNote> notes) async {
    if (notes.isEmpty) return;
    final author = _ref.read(authProvider);
    if (author == null) throw StateError('Please login to upload scribbles.');

    final data = <Map<String, dynamic>>[];
    final ident = {
      'username': author.displayName,
      'user_id': author.id,
      'editor': '$kAppTitle $kAppVersion',
    };
    for (final note in notes) {
      if (note.deleting && note.id == null) continue;
      if (note is MapDrawing) {
        if (note.deleting) {
          data.add({...ident, 'id': note.id, 'deleted': true});
        } else {
          data.add({
            ...ident,
            'style': kTypeStylesReversed[note.style] ?? 'unknown',
            'color': _colorToHex(note.style.color),
            'dashed': note.style.dashed,
            'thin': note.style.stroke < DrawingStyle.kDefaultStroke,
            'points': note.coordinates
                .map((ll) => [ll.longitude, ll.latitude])
                .toList(),
          });
        }
      } else if (note is MapNote) {
        if (note.deleting) {
          data.add({...ident, 'id': note.id, 'deleted': true});
        } else {
          data.add({
            ...ident,
            'text': note.message,
            'location': [note.location.longitude, note.location.latitude],
          });
        }
      }
    }

    final url = Uri.https(kScribblesEndpoint, '/upload');
    final body = json.encode(data);
    final response = await http
        .post(url, body: body, headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      String msg = _extractError(response);
      throw Exception('Failed to upload notes: ${response.statusCode} $msg');
    }

    final ids = json.decode(response.body) as List<dynamic>;
    if (ids.length != notes.length) {
      _logger.warning(
          'API returned ${ids.length} ids for ${notes.length} uploaded elements!');
    }

    // Mark all uploaded notes not changed and set ids.
    // Skip new notes with "deleting", but delete old deleted notes.
    int i = 0;
    for (final note in notes) {
      if (note.deleting && note.id == null) continue;
      if (i < ids.length) {
        if (note.deleting) {
          await deleteNote(note, notify: false);
        } else {
          await saveNote(note, notify: false, newId: ids[i]);
        }
      }
      i += 1;
    }

    // Clear undo buffer.
    _undoStack.clear();
    _undoStackLast = 0;
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
    await _cleanAndInsertNotes(bounds, notes, [OsmNote.dbType]);
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
          'text': (note.message ?? "") + "\n\n#EveryDoor",
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

  Future<void> saveNote(BaseNote note,
      {bool notify = true, bool addUndo = true, int? newId}) async {
    _logger.info('Saving $note');
    final database = await _ref.read(databaseProvider).database;
    if (note.id != null && newId != null) {
      // Instead of creating, replace note id in the database.
      final oldId = note.id;
      note.id = newId;
      await database.update(
        BaseNote.kTableName,
        note.toJson(),
        where: 'id = ?',
        whereArgs: [oldId],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      note.id ??= await getNewNoteId();
      await database.insert(
        BaseNote.kTableName,
        note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (addUndo) _addToUndoStack(note, false);
    }
    if (notify) _checkHaveChangesAndNotify();
  }

  Future<void> deleteNote(BaseNote note,
      {bool notify = true, bool addUndo = true}) async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      BaseNote.kTableName,
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (addUndo) _addToUndoStack(note, true);
    if (notify) _checkHaveChangesAndNotify();
  }

  bool get undoIsEmpty => _undoStackLast <= 0;
  bool get redoIsEmpty => _undoStackLast >= _undoStack.length;

  _addToUndoStack(BaseNote note, bool deleted) {
    if (note is OsmNote) return;
    // Add it to undo stack, discarding the top if needed.
    if (_undoStackLast < _undoStack.length)
      _undoStack.removeRange(_undoStackLast, _undoStack.length);
    _undoStack.add((deleted, note));
    _undoStackLast += 1;
  }

  Future<void> undoChange() async {
    if (_undoStackLast <= 0) return;
    _undoStackLast -= 1;
    final deleted = _undoStack[_undoStackLast].$1;
    final note = _undoStack[_undoStackLast].$2;
    if (deleted) {
      // restore with a new note id
      note.id = null;
      await saveNote(note, addUndo: false);
      // At this point, note id was updated.
    } else {
      // delete
      await deleteNote(note, addUndo: false);
    }
  }

  Future<void> redoChange() async {
    if (_undoStackLast >= _undoStack.length) return;
    final deleted = _undoStack[_undoStackLast].$1;
    final note = _undoStack[_undoStackLast].$2;
    _undoStackLast += 1;
    if (deleted) {
      // delete again
      await deleteNote(note, addUndo: false);
    } else {
      // restore with a new note id
      note.id = null;
      await saveNote(note, addUndo: false);
      // At this point, note id was updated.
    }
  }

  // Useful for undoing notes.
  Future<MapDrawing?> getLastNewDrawing() async {
    final database = await _ref.read(databaseProvider).database;
    final drawing = await database.query(
      BaseNote.kTableName,
      where: 'type == ? and id < 0',
      whereArgs: [MapDrawing.dbType],
      orderBy: 'id',
      limit: 1,
    );
    return drawing.isEmpty ? null : MapDrawing.fromJson(drawing.first);
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

class OwnScribblesController extends StateNotifier<bool> {
  static const kSettingKey = "own_scribbles";

  OwnScribblesController() : super(false) {
    loadState();
  }

  loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getBool(kSettingKey);
    if (savedState != null) state = savedState;
  }

  set(bool newValue) async {
    if (state != newValue) {
      state = newValue;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kSettingKey, state);
    }
  }
}
