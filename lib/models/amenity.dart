import 'dart:ui';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:every_door/helpers/tag_emoji.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class OsmChange extends ChangeNotifier {
  static final kDateFormat = DateFormat('yyyy-MM-dd');
  static const kCheckedKey = 'check_date';

  final OsmElement? element;

  Map<String, String?> newTags;
  LatLng? newLocation;
  List<int>? newNodes; // WARNING: Not stored to the database!
  bool _deleted;
  String? error;
  final String databaseId;
  String? _mainKey;
  bool snapToBuilding;
  DateTime updated;

  OsmChange(this.element,
      {Map<String, String?>? newTags,
      this.newLocation,
      bool hardDeleted = false,
      this.error,
      this.snapToBuilding = false,
      DateTime? updated,
      this.newNodes,
      String? databaseId})
      : newTags = newTags ?? {},
        _deleted = hardDeleted,
        updated = updated ?? DateTime.now(),
        databaseId = databaseId ?? element?.id.toString() ?? Uuid().v1() {
    _updateMainKey();
    // For just created elements, set checked flag.
    if (element == null && databaseId == null) check();
  }

  OsmChange.create(
      {required Map<String, String> tags, required LatLng location})
      : newTags = Map<String, String?>.of(tags),
        newLocation = location,
        element = null,
        _deleted = false,
        snapToBuilding = false,
        updated = DateTime.now(),
        databaseId = Uuid().v1() {
    _updateMainKey();
    check();
  }

  OsmChange copy() => OsmChange(
        element,
        newTags: Map.of(newTags),
        newLocation: newLocation,
        hardDeleted: _deleted,
        error: error,
        snapToBuilding: snapToBuilding,
        updated: updated,
        newNodes: newNodes,
        databaseId: databaseId,
      );

  // Location and modification
  LatLng get location => newLocation ?? element!.center!;
  set location(LatLng loc) {
    newLocation = loc;
    notifyListeners();
  }

  OsmId get id {
    if (element == null) throw StateError('Trying to get id for a new amenity');
    return element!.id;
  }

  bool get deleted => _deleted || (_mainKey?.startsWith(kDeleted) ?? false);
  bool get hardDeleted => _deleted;
  bool get isModified => newTags.isNotEmpty || newLocation != null || deleted;
  bool get isConfirmed =>
      !deleted && (newTags.length == 1 && newTags.keys.first == kCheckedKey);
  bool get isNew => element == null;
  bool get isArea => element?.isArea ?? false;
  bool get isPoint => element?.isPoint ?? true;
  bool get canDelete =>
      (element?.isPoint ?? true) && !(element?.isMember ?? false);
  ElementKind get kind => detectKind(getFullTags());

  revert() {
    // Cannot revert a new object
    if (isNew) return;

    newTags.clear();
    newLocation = null;
    _updateMainKey();
    notifyListeners();
  }

  // Tags management
  String? operator [](String k) =>
      newTags.containsKey(k) ? newTags[k] : element?.tags[k];

  operator []=(String k, String? v) {
    if (v == null || v.isEmpty) {
      removeTag(k);
    } else if (element == null || element!.tags[k] != v) {
      newTags[k] = v;
    } else if (newTags.containsKey(k)) {
      newTags.remove(k);
    }
    _updateMainKey();
    notifyListeners();
  }

  removeTag(String key) {
    if (element != null && element!.tags.containsKey(key)) {
      newTags[key] = null;
    } else if (newTags[key] != null) {
      newTags.remove(key);
    }
    _updateMainKey();
    notifyListeners();
  }

  undoTagChange(String key) {
    if (newTags.containsKey(key)) {
      newTags.remove(key);
      _updateMainKey();
      notifyListeners();
    }
  }

  bool hasTag(String key) => this[key] != null;

  _updateMainKey() {
    _mainKey = getMainKey(getFullTags());
  }

  // Check date management.
  int get ageDays => DateTime.now()
      .difference(DateTime.tryParse(this[kCheckedKey] ?? '2020-01-01') ??
          DateTime(2020, 1, 1))
      .inDays;

  bool get isOld => ageDays >= kOldAmenityDays;
  bool get isCheckedToday => ageDays <= 1;

  check() {
    this[kCheckedKey] = kDateFormat.format(DateTime.now());
  }

  uncheck() {
    newTags.remove(kCheckedKey);
  }

  toggleCheck() {
    if (newTags.containsKey(kCheckedKey))
      uncheck();
    else
      check();
  }

  set deleted(bool value) {
    if (value == deleted) return;
    if (isNew || !canDelete) {
      togglePrefix(kDeleted);
    } else {
      _deleted = value;
    }
  }

  // Database export-import and converters

  static const kTableName = 'changes';
  static const kTableFields = <String>[
    'id text primary key',
    'osmid text',
    'new_lat integer',
    'new_lon integer',
    'new_tags text',
    'deleted integer',
    'error text',
    'snap integer',
    'updated integer',
  ];

  factory OsmChange.fromJson(Map<String, dynamic> data) {
    final location = data['new_lat'] == null
        ? null
        : LatLng((data['new_lat'] as int).toDouble() / kCoordinatePrecision,
            (data['new_lon'] as int).toDouble() / kCoordinatePrecision);
    final element = data['version'] == null ? null : OsmElement.fromJson(data);
    final kDefaultUpdated = DateTime(2022, 1, 1);
    return OsmChange(
      element,
      newTags: (json.decode(data['new_tags']) as Map).cast<String, String?>(),
      newLocation: location,
      hardDeleted: data['deleted'] == 1,
      error: data['error'],
      snapToBuilding: data['snap'] == 1,
      updated: data['updated'] == null
          ? kDefaultUpdated
          : DateTime.fromMillisecondsSinceEpoch(data['updated']),
      databaseId: data['id'],
    );
  }

  Map<String, dynamic> toJson() {
    LatLng? loc = newLocation;
    return {
      'id': databaseId,
      'osmid': element?.id.toString(),
      'new_tags': json.encode(newTags),
      'new_lat':
          loc == null ? null : (loc.latitude * kCoordinatePrecision).toInt(),
      'new_lon':
          loc == null ? null : (loc.longitude * kCoordinatePrecision).toInt(),
      'deleted': _deleted ? 1 : 0,
      // 'snap': snapToBuilding ? 1 : 0,
      // 'updated': updated.millisecondsSinceEpoch,
      'error': error,
    };
  }

  /// Constructs a new element from this change after the object has been uploaded.
  /// Or for uploading.
  OsmElement toElement(int newId, int newVersion) {
    return OsmElement(
      id: OsmId(element?.type ?? OsmElementType.node, newId),
      version: newVersion,
      timestamp: DateTime.now(),
      tags: getFullTags(),
      isMember: element?.isMember ?? false,
      // overriding location call for toXML()
      center: newLocation ?? element?.center,
      downloaded: DateTime.now(),
      nodes: element?.nodes,
      members: element?.members,
    );
  }

  /// Updates the underlying [OsmElement].
  OsmChange mergeNewElement(OsmElement newElement) {
    if (element != null && element!.id != newElement.id)
      throw StateError('New element differs from the one we have');
    // Keeping moved location as-is.
    final Map<String, String?> newTags = Map.of(this.newTags);
    for (final k in List.of(newTags.keys)) {
      final v = newTags[k];
      if (v == null) {
        if (!newElement.tags.containsKey(k)) newTags.remove(k);
      } else {
        final newV = newElement.tags[k];
        if (newV == v) newTags.remove(k);
        // Not doing a three-way merge with timestamps, since
        // this editor is for on-the-ground updates, so anything
        // entered here has higher priority.
      }
    }

    // Reset `newLocation` if the point was moved less than 1 meter away.
    LatLng? location = newLocation;
    if (location != null && newElement.center != null) {
      final distance = DistanceEquirectangular();
      if (distance(newElement.center!, location) < 1.0) {
        location = null;
      }
    }

    return OsmChange(
      newElement,
      newLocation: location,
      newTags: newTags,
      hardDeleted: _deleted,
      error: error,
      databaseId: databaseId,
    );
  }

  // Helper methods

  bool get isDisused {
    return _mainKey?.startsWith(kDisused) ?? false;
  }

  togglePrefix(String prefix) {
    final k = _mainKey;
    if (k == null) return null;

    String newK;
    if (k.startsWith(prefix)) {
      newK = k.substring(prefix.length);
    } else {
      // Delete another prefix if exists.
      newK = prefix + k.substring(k.indexOf(':') + 1);
    }

    this[newK] = this[k];
    removeTag(k);
  }

  toggleDisused() {
    togglePrefix(kDisused);
  }

  String? get name => this['name'] ?? this['operator'] ?? this['brand'];

  String? getLocalName(Locale locale) {
    // TODO: take the country language into account, like in maps.me?
    return this['name:${locale.languageCode}'] ?? this['name'];
  }

  String? getContact(String key) => this[key] ?? this['contact:$key'];

  setContact(String key, String value) {
    String alternativeKey;
    if (key.startsWith('contact:'))
      alternativeKey = key.replaceFirst('contact:', '');
    else
      alternativeKey = 'contact:$key';

    if (this[alternativeKey] != null)
      this[alternativeKey] = value;
    else
      this[key] = value;
  }

  bool? get acceptsCards =>
      this['payment:visa'] == 'yes' || this['payment:mastercard'] == 'yes';

  bool get hasWebsite {
    const kWebTags = <String>['website', 'instagram', 'vk'];
    return kWebTags.any((k) => this[k] != null || this['contact:$k'] != null);
  }

  String? get descriptiveTag {
    if (this['amenity'] == 'fixme') return this['fixme:type'];
    return _mainKey == null ? null : this[_mainKey!];
  }

  String get typeAndName {
    if (name == null) return descriptiveTag ?? '?';
    final emoji = getEmojiForTags(getFullTags(true));
    return '${emoji ?? descriptiveTag ?? ""} «$name»'.trimLeft();
  }

  String? get address {
    final num = this['addr:housenumber'] ?? this['addr:housename'];
    if (num == null) return null;
    final street = this['addr:street'] ?? this['addr:place'];
    if (street == null) return null;
    return '$num, $street';
  }

  // Helper methods

  /// Returns a map with complete object tags. All changes are applied,
  /// deleted tags are removed. Set `clearDisused` to `true` to remove
  /// the `disused:` prefix from the main tag.
  Map<String, String> getFullTags([bool clearDisused = false]) {
    final Map<String, String> result =
        element == null ? {} : Map.of(element!.tags);
    newTags.forEach((key, value) {
      if (value == null)
        result.remove(key);
      else
        result[key] = value;
    });

    if (clearDisused) {
      final mainKey = _mainKey;
      final pos = mainKey?.indexOf(':');
      if (mainKey != null && pos != null && pos > 0) {
        result[mainKey.substring(pos + 1)] = result[mainKey]!;
        result.remove(mainKey);
      }
    }
    return result;
  }

  @override
  String toString() {
    return 'OsmChange(${_deleted ? "delete " : ""}$element, $newLocation, ${OsmElement.tagsToString(newTags)})';
  }

  @override
  bool operator ==(other) {
    if (other is! OsmChange) return false;
    if (element != other.element) return false;
    if (databaseId != other.databaseId) return false;
    if (_deleted != other._deleted) return false;
    if (newLocation != other.newLocation) return false;
    if (!mapEquals(newTags, other.newTags)) return false;
    return true;
  }

  @override
  int get hashCode => databaseId.hashCode;
}
