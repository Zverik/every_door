// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:ui';

import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/helpers/tags/payment_tags.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:every_door/helpers/tags/tag_emoji.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

@Bind()
class OsmChange extends ChangeNotifier implements Comparable, Located {
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
  Map<String, String>? _fullTagsCache;
  DateTime updated;
  int? newId; // Not stored: used only during uploading.
  String source;

  OsmChange(OsmElement element,
      {Map<String, String?>? newTags,
      this.newLocation,
      bool hardDeleted = false,
      this.error,
      DateTime? updated,
      this.newNodes,
      String? databaseId})
      : newTags = newTags ?? {},
        source = element.source,
        _deleted = hardDeleted,
        updated = updated ?? DateTime.now(),
        // ignore: prefer_initializing_formals
        element = element, // Force non-null initialization
        databaseId = databaseId ?? element.id.toString() {
    _updateMainKey();
  }

  OsmChange.create({
    required Map<String, String> tags,
    required LatLng location,
    required this.source,
    DateTime? updated,
    String? databaseId,
    this.error,
    this.newId,
  })  : newTags = Map<String, String?>.of(tags),
        newLocation = location,
        element = null,
        _deleted = false,
        updated = updated ?? DateTime.now(),
        databaseId = databaseId ?? Uuid().v1() {
    _updateMainKey();
  }

  OsmChange copy() {
    if (element == null) {
      return OsmChange.create(
        tags: Map.of(newTags.cast<String, String>()),
        location: newLocation!,
        source: source,
        error: error,
        updated: updated,
        databaseId: databaseId,
        newId: newId,
      );
    }

    return OsmChange(
      element!,
      newTags: Map.of(newTags),
      newLocation: newLocation,
      hardDeleted: _deleted,
      error: error,
      updated: updated,
      newNodes: newNodes,
      databaseId: databaseId,
    );
  }

  // Location and modification
  @override
  LatLng get location => newLocation ?? element!.center!;

  @override
  String get uniqueId => databaseId;

  set location(LatLng loc) {
    newLocation = loc;
    notifyListeners();
  }

  OsmId get id {
    if (element == null) throw StateError('Trying to get id for a new amenity');
    return element!.id;
  }

  @override
  bool get isDeleted =>
      _deleted ||
      (_mainKey?.startsWith(kDeleted) ?? false) ||
      (_mainKey?.startsWith(kBuildingDeleted) ?? false);

  @override
  bool get isModified =>
      newTags.isNotEmpty ||
      newLocation != null ||
      newNodes != null ||
      isHardDeleted;

  @override
  bool get isNew => element == null;

  bool get isHardDeleted => _deleted;
  bool get isArea => element?.isArea ?? false;
  bool get isPoint => element?.isPoint ?? true;
  bool get canDelete =>
      (element?.isPoint ?? true) &&
      (element == null || element?.isMember == IsMember.no);
  bool get canMove =>
      (element?.isPoint ?? true) && (element?.isMember != IsMember.way);
  bool get isConfirmed =>
      !isDeleted && (newTags.length == 1 && newTags.keys.first == kCheckedKey);
  String? get mainKey => _mainKey;

  void revert() {
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

  void operator []=(String k, String? v) {
    if (v == null || v.isEmpty) {
      removeTag(k);
    } else if (element == null || element!.tags[k] != v) {
      // Silently cut the value.
      if (v.length > 255) v = v.substring(0, 255);
      newTags[k] = v;
    } else if (newTags.containsKey(k)) {
      newTags.remove(k);
    }
    _updateMainKey();
    notifyListeners();
  }

  void removeTag(String key) {
    if (element != null && element!.tags.containsKey(key)) {
      newTags[key] = null;
    } else if (newTags[key] != null) {
      newTags.remove(key);
    } else {
      return;
    }
    _updateMainKey();
    notifyListeners();
  }

  void undoTagChange(String key) {
    if (newTags.containsKey(key)) {
      newTags.remove(key);
      _updateMainKey();
      notifyListeners();
    }
  }

  bool hasTag(String key) => this[key] != null;
  bool changedTag(String key) => newTags.containsKey(key);

  void _updateMainKey() {
    _fullTagsCache = null;
    _mainKey = getMainKey(getFullTags());
  }

  int calculateAge(String? value) => DateTime.now()
      .difference(
          DateTime.tryParse(value ?? '2020-01-01') ?? DateTime(2020, 1, 1))
      .inDays;

  // Check date management.
  int get age => calculateAge(this[kCheckedKey]);
  int get baseAge => calculateAge(element?.tags[kCheckedKey]);
  bool get isOld => isCountedOld(age);
  bool get wasOld =>
      !isNew && isCountedOld(calculateAge(element?.tags[kCheckedKey]));
  bool get isCheckedToday => age <= 1;

  bool isCountedOld(int age) {
    return age >=
        (ElementKind.structure.matchesChange(this)
            ? kOldStructureDays
            : kOldAmenityDays);
  }

  void check([String? subKey]) {
    final String finalKey = subKey == null || subKey.isEmpty 
        ? kCheckedKey
        : '$kCheckedKey:$subKey';
    this[finalKey] = kDateFormat.format(DateTime.now());
  }

  void uncheck([String? subKey]) {
    final String keyToRemove = subKey == null || subKey.isEmpty 
        ? kCheckedKey 
        : '$kCheckedKey:$subKey';

    newTags.remove(keyToRemove);
    _updateMainKey();
    notifyListeners();
  }

  void toggleCheck([String? subKey]) {
    final String keyToToggle = subKey == null || subKey.isEmpty 
        ? kCheckedKey 
        : '$kCheckedKey:$subKey';
    
    if (newTags.containsKey(keyToToggle)) {
      uncheck(subKey);
    } else {
      check(subKey);
    }
  }

  set isDeleted(bool value) {
    if (value == isDeleted) return;
    if (isNew || !canDelete) {
      // We use this for new because if they are not deleted higher up,
      // they are meant to have this prefix.
      togglePrefix((_mainKey?.endsWith("building") ?? false)
          ? kBuildingDeleted
          : kDeleted);
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
    'updated integer',
    'source text',
  ];

  factory OsmChange.fromJson(Map<String, dynamic> data) {
    final location = data['new_lat'] == null
        ? null
        : LatLng((data['new_lat'] as int).toDouble() / kCoordinatePrecision,
            (data['new_lon'] as int).toDouble() / kCoordinatePrecision);
    final element = data['version'] == null ? null : OsmElement.fromJson(data);
    final tags = (json.decode(data['new_tags']) as Map).cast<String, String?>();
    final updated = data['updated'] == null
        ? DateTime(2022, 1, 1)
        : DateTime.fromMillisecondsSinceEpoch(data['updated']);

    if (element == null) {
      if (location == null) {
        throw Exception(
            'Found a change without both element and location, id=${data["id"]}.');
      }
      tags.removeWhere((key, value) => value == null);
      return OsmChange.create(
        tags: tags.cast<String, String>(),
        location: location,
        error: data['error'],
        updated: updated,
        source: data['source'] ?? 'osm',
        databaseId: data['id'],
      );
    }

    return OsmChange(
      element,
      newTags: tags,
      newLocation: location,
      hardDeleted: data['deleted'] == 1,
      error: data['error'],
      updated: updated,
      databaseId: data['id'],
    );
  }

  Map<String, dynamic> toJson() {
    LatLng? loc = newLocation;
    return {
      'source': source,
      'id': databaseId,
      'osmid': element?.id.toString(),
      'new_tags': json.encode(newTags),
      'new_lat':
          loc == null ? null : (loc.latitude * kCoordinatePrecision).toInt(),
      'new_lon':
          loc == null ? null : (loc.longitude * kCoordinatePrecision).toInt(),
      'deleted': _deleted ? 1 : 0,
      'updated': updated.millisecondsSinceEpoch,
      'error': error,
    };
  }

  /// Constructs a new element from this change after the object has been uploaded.
  /// Or for uploading.
  OsmElement toElement({int? newId, int? newVersion}) {
    if (newId == null && this.newId == null)
      throw ArgumentError('Please specify an id for the new element');
    return OsmElement(
      source: source,
      id: OsmId(element?.type ?? OsmElementType.node, newId ?? this.newId ?? 0),
      version: newVersion ?? 1,
      timestamp: DateTime.now(),
      tags: getFullTags(),
      isMember: element?.isMember ?? IsMember.no,
      // overriding location call for toXML()
      center: newLocation ?? element?.center,
      downloaded: DateTime.now(),
      nodes: newNodes ?? element?.nodes,
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
      newNodes: newElement.nodes, // New data always better
    );
  }

  // Helper methods

  bool get isDisused {
    return _mainKey?.startsWith(kDisused) ?? false;
  }

  void togglePrefix(String prefix) {
    final k = _mainKey;
    if (k == null) return;

    final swap = <String, String>{};
    if (k.startsWith(prefix)) {
      swap[k] = k.substring(prefix.length);
      // Remove this prefix from all other amenity keys.
      for (final kk in kAmenityMainKeys) {
        if (hasTag('$prefix$kk')) {
          swap['$prefix$kk'] = kk;
        }
      }
      // Remove the `disused=yes` tag.
      removeTag(prefix.substring(0, prefix.length - 1));
    } else {
      // Delete another prefix if exists.
      swap[k] = prefix + clearPrefix(k);
      // Add this prefix to all other amenity keys.
      for (final kk in kAmenityMainKeys) {
        if (hasTag(kk)) {
          swap[kk] = '$prefix$kk';
        }
      }
    }

    for (final e in swap.entries) {
      this[e.value] = this[e.key];
      removeTag(e.key);
    }
  }

  void toggleDisused() {
    togglePrefix(kDisused);
  }

  String? get name => getAnyName() ?? this['operator'] ?? this['brand'];

  String? getAnyName() {
    String? result = this['name'] ?? this['name:en'] ?? this['int_name'];
    if (result != null) return result;
    for (final e in getFullTags().entries) {
      if (e.key == 'name:signed' || e.key.contains(':19')) continue;
      if (e.key.startsWith('name:')) return e.value;
    }
    return null;
  }

  String? getLocalName(Locale locale) {
    // TODO: take the country language into account, like in maps.me?
    return this['name:${locale.languageCode}'] ?? this['name'];
  }

  String _getAltContactKey(String key) {
    if (key.startsWith('contact:'))
      return key.replaceFirst('contact:', '');
    else
      return 'contact:$key';
  }

  String? getContact(String key) => this[key] ?? this[_getAltContactKey(key)];

  void setContact(String key, String value) {
    final alternativeKey = _getAltContactKey(key);
    if (this[alternativeKey] != null)
      this[alternativeKey] = value;
    else
      this[key] = value;
  }

  void removeOpeningHoursSigned() {
    const kSigned = 'opening_hours:signed';
    if (this[kSigned] == 'no' &&
        this['opening_hours'] != null &&
        element?.tags['opening_hours'] == null) {
      removeTag(kSigned);
    }
  }

  Map<String, bool> _getPaymentOptions() {
    return Map<String, bool>.fromEntries(getFullTags()
        .entries
        .where((element) => element.key.startsWith('payment:'))
        .map((e) =>
            MapEntry<String, bool>(e.key.substring(8), e.value == 'yes')));
  }

  bool get hasPayment => _getPaymentOptions().isNotEmpty;

  bool get acceptsCards {
    final options = _getPaymentOptions();
    return options.entries
        .where((e) => !kNotCards.contains(e.key) && e.value)
        .isNotEmpty;
  }

  bool get cashOnly {
    if (this['payment:cards'] == 'no') return true;
    final options = _getPaymentOptions();
    return options.entries
        .where((e) => !kNotCards.contains(e.key) && !e.value)
        .isNotEmpty;
  }

  bool get hasWebsite {
    const kWebTags = <String>['website', 'instagram', 'vk', 'facebook'];
    return kWebTags.any((k) => this[k] != null || this['contact:$k'] != null);
  }

  String? get descriptiveTag {
    if (this['amenity'] == 'fixme') return this['fixme:type'];

    final mainKey = _mainKey;
    if (mainKey == null)
      return this['addr:housenumber'] != null ? 'address' : null;
    if (this[mainKey] == 'yes' || {'entrance', 'building'}.contains(mainKey))
      return mainKey;
    return this[mainKey];
  }

  String get typeAndName {
    final name = this.name;
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

  bool isFixmeNote() {
    if (!isNew || this['amenity'] != 'fixme') return false;
    final tags = getFullTags();
    return {'amenity', 'check_date', 'fixme', 'fixme:type', 'name'}
        .containsAll(tags.keys);
  }

  // Helper methods

  /// Returns a map with complete object tags. All changes are applied,
  /// deleted tags are removed. Set `clearDisused` to `true` to remove
  /// the `disused:` prefix from the main tag.
  Map<String, String> getFullTags([bool clearDisused = false]) {
    if (_fullTagsCache != null && !clearDisused) return _fullTagsCache!;

    Map<String, String> result = element == null ? {} : Map.of(element!.tags);
    newTags.forEach((key, value) {
      if (value == null)
        result.remove(key);
      else
        result[key] = value;
    });
    _fullTagsCache = Map.of(result);

    if (clearDisused) {
      final noPrefixKey = clearPrefixNull(_mainKey);
      if (noPrefixKey != null && noPrefixKey != _mainKey) {
        result[noPrefixKey] = result[_mainKey]!;
        result.remove(_mainKey);
      }
    }
    return result;
  }

  @override
  String toString() {
    return 'OsmChange(${_deleted ? "delete " : ""}$element${newId != null ? "[$newId]" : ""}, '
        '$newLocation, ${OsmElement.tagsToString(newTags)}${newNodes == null ? "" : ", nodes:$newNodes"})';
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

  @override
  int compareTo(other) {
    const kTypeOrder = {
      OsmElementType.node: 0,
      OsmElementType.way: 1,
      OsmElementType.relation: 2,
    };

    if (other is! OsmChange)
      throw ArgumentError('OsmChange can be compared only to another change');
    // Order for uploading: create (n), modify (nwr), delete(rwn).
    if (isNew) {
      return other.isNew ? 0 : -1;
    } else if (isModified && !isHardDeleted) {
      if (other.isNew) return 1;
      if (other.isHardDeleted) return -1;
      return kTypeOrder[id.type]!.compareTo(kTypeOrder[other.id.type]!);
    } else {
      // deleted
      if (!other.isHardDeleted) return 1;
      return kTypeOrder[other.id.type]!.compareTo(kTypeOrder[id.type]!);
    }
  }
}
