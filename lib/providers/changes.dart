import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/providers/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final changesProvider = ChangeNotifierProvider((ref) => ChangesProvider(ref));

class ChangesProvider extends ChangeNotifier {
  final Ref _ref;
  final Map<OsmId, OsmChange> _changes = {};
  final Map<String, OsmChange> _new = {};
  bool loaded = false;

  ChangesProvider(this._ref);

  loadChanges() async {
    final database = await _ref.read(databaseProvider).database;
    final rows = await database.rawQuery("""
      select * from ${OsmChange.kTableName} c
      left join ${OsmElement.kTableName} e on c.osmid = e.osmid
    """);
    final broken = <String>[];
    final elements = <OsmChange>[];
    for (final row in rows) {
      try {
        elements.add(OsmChange.fromJson(row));
      } on Error catch (e) {
        print('Failed to load osm change $row: $e');
        broken.add(row['id'] as String);
      } on Exception catch (e) {
        print('Failed to load osm change $row: $e');
        broken.add(row['id'] as String);
      }
    }
    if (broken.isNotEmpty) {
      // Delete these elements, since they are not restorable.
      final q = broken.map((e) => '?').join(',');
      await database.delete(OsmChange.kTableName,
          where: 'id in $q', whereArgs: broken);
    }
    for (final e in elements) {
      if (e.isNew)
        _new[e.databaseId] = e;
      else
        _changes[e.id] = e;
    }
    notifyListeners();
    loaded = true;
  }

  _ensureLoaded() {
    if (!loaded) throw StateError("Changes were not loaded");
  }

  OsmChange changeFor(OsmElement element, [bool storeNew = true]) {
    _ensureLoaded();
    OsmChange? change = _changes[element.id];
    if (change != null) {
      if (element.version > change.element!.version) {
        change = change.mergeNewElement(element);
        if (storeNew) saveChange(change);
      }
    }
    return change ?? OsmChange(element);
  }

  List<OsmChange> getNew() {
    return _new.values.toList();
  }

  int get length => _new.length + _changes.length;
  bool get haveErrors =>
      _new.values.any((e) => e.error != null) ||
      _changes.values.any((e) => e.error != null);

  OsmChange operator [](int index) => index < _new.length
      ? _new.values.elementAt(index)
      : _changes.values.elementAt(index - _new.length);

  List<OsmChange> all([bool includeErrored = true]) {
    if (includeErrored) {
      return _new.values.toList() + _changes.values.toList();
    } else {
      return _new.values.where((e) => e.error == null).toList() +
          _changes.values.where((e) => e.error == null).toList();
    }
  }

  List<OsmChange> fetch(Iterable<String> databaseIds) {
    final ids = Set.of(databaseIds);
    List<OsmChange> result = [];
    for (final el in _new.values) {
      if (ids.contains(el.databaseId)) result.add(el);
    }
    for (final el in _changes.values) {
      if (ids.contains(el.databaseId)) result.add(el);
    }
    return result;
  }

  saveChange(OsmChange change) async {
    print('Saving $change');
    if (change.isModified) {
      await _addChange(change);
    } else {
      await deleteChange(change);
    }
  }

  setError(OsmChange change, String? error) async {
    if (change.error != error) {
      change.error = error;
      await saveChange(change);
    }
  }

  _addChange(OsmChange change) async {
    _ensureLoaded();
    final database = await _ref.read(databaseProvider).database;
    change.updated = DateTime.now();
    if (change.isNew)
      _new[change.databaseId] = change;
    else
      _changes[change.id] = change;
    notifyListeners();
    await database.insert(
      OsmChange.kTableName,
      change.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  deleteChange(OsmChange change) async {
    _ensureLoaded();
    if (change.isNew) {
      if (!_new.containsKey(change.databaseId)) return;
      _new.remove(change.databaseId);
    } else {
      if (!_changes.containsKey(change.id)) return;
      _changes.remove(change.id);
    }
    notifyListeners();

    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      OsmChange.kTableName,
      where: 'id = ?',
      whereArgs: [change.databaseId],
    );
  }

  clearChanges([bool includeErrored = false]) async {
    _ensureLoaded();
    if (includeErrored) {
      _new.clear();
      _changes.clear();
    } else {
      // Keep changes with errors.
      _new.removeWhere((key, value) => value.error == null);
      _changes.removeWhere((key, value) => value.error == null);
    }
    notifyListeners();

    final database = await _ref.read(databaseProvider).database;
    final keepIds = _changes.keys.map((e) => e.toString()).toList();
    if (keepIds.isEmpty) {
      await database.delete(OsmChange.kTableName);
    } else {
      final placeholders =
          List.generate(keepIds.length, (index) => "?").join(",");
      await database.delete(
        OsmChange.kTableName,
        where: 'osmid not in ($placeholders)',
        whereArgs: keepIds,
      );
    }
  }

  bool haveNoErrorChanges() {
    return _new.values.any((element) => element.error == null) ||
        _changes.values.any((element) => element.error == null);
  }
}
