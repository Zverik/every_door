import 'dart:io';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/amenity.dart';

Map<String, String> generateChangesetTags(Iterable<OsmChange> changes) {
  String comment = CommentGenerator().generateComment(changes);
  if (comment.length > 250) {
    comment = CommentGenerator().generateComment(changes, simple: true);
    if (comment.length > 250) {
      comment = 'Surveyed ${changes.length} objects';
    }
  }

  String platform;
  if (Platform.isAndroid)
    platform = 'Android';
  else if (Platform.isIOS)
    platform = 'iOS';
  else
    platform = 'unknown';

  return <String, String>{
    'comment': comment,
    'created_by': '$kAppTitle $platform $kAppVersion',
  };
}

class _TypeCount {
  final Map<String, int> created = {};
  final Map<String, int> updated = {};
  final Map<String, int> deleted = {};
  final Map<String, int> confirmed = {};

  _TypeCount([Iterable<OsmChange>? changes]) {
    if (changes != null) {
      for (final change in changes) {
        // Skip ways we snapped nodes to.
        if (change.newNodes != null && change.newTags.isEmpty) continue;
        add(change);
      }
    }
  }

  add(OsmChange change) {
    String type = _getType(change);
    if (change.isNew)
      created[type] = (created[type] ?? 0) + 1;
    else if (change.deleted)
      deleted[type] = (deleted[type] ?? 0) + 1;
    else if (change.isConfirmed)
      confirmed[type] = (confirmed[type] ?? 0) + 1;
    else if (change.isModified) updated[type] = (updated[type] ?? 0) + 1;
  }

  String _getType(OsmChange change) {
    final key = getMainKey(change.getFullTags());
    if (key == null) return 'unknown object';
    final value = change[key]!;
    if (value == 'yes') return key;
    if ({'shop', 'office', 'building', 'entrance', 'club'}.contains(key))
      return '$value $key'; // school building
    if (value.endsWith('s')) return value.substring(0, value.length - 1);
    return value;
  }
}

class _TypePairCompareError extends Error {
  final String message;

  _TypePairCompareError(this.message);

  @override
  String toString() => 'TypePairCompareError($message)';
}

class _TypePair implements Comparable {
  final String type;
  final int count;

  const _TypePair(this.type, this.count);

  @override
  String toString() {
    const kVowels = {'a', 'e', 'i', 'o', 'u'};
    String countStr;
    if (count == 1) {
      countStr = kVowels.contains(type.substring(0, 1)) ? 'an' : 'a';
    } else {
      countStr = count.toString();
    }
    String typeStr = type;
    if (count > 1) {
      if (type.endsWith('x') ||
          type.endsWith('sh') ||
          type.endsWith('ch') ||
          type.endsWith('ss')) {
        // marsh → marshes, fox → foxes
        typeStr = type + 'es';
      } else if (type.endsWith('y') &&
          !kVowels.contains(type.substring(type.length - 2, type.length - 1))) {
        // cemetery → cemeteries
        typeStr = type.substring(0, type.length - 1) + 'ies';
      } else {
        typeStr = type + 's';
      }
    }
    return '$countStr $typeStr';
  }

  @override

  /// These pairs are sorted in reverse: the most occurent is the first.
  int compareTo(other) {
    if (other is! _TypePair) {
      throw _TypePairCompareError('Got a ${other.runtimeType} "$other"');
    }
    return other.count.compareTo(count);
  }
}

class CommentGenerator {
  static const kMaxItems = 3;

  String _typeCountToString(Map<String, int> typeCount, bool simple) {
    final pairs = typeCount.entries
        .map((entry) => _TypePair(entry.key, entry.value))
        .toList();

    if (simple) {
      // Just return the number of objects.
      if (pairs.length == 1) {
        return pairs.first.toString();
      }
      final int count = typeCount.values.fold(0, (p, i) => p + i);
      return '$count objects'; // By definition more than one
    }

    pairs.sort();
    List<_TypePair> finalPairs;
    if (pairs.length <= kMaxItems) {
      finalPairs = pairs;
    } else {
      int countRest = pairs
          .sublist(kMaxItems - 1)
          .fold(0, (prev, pair) => prev + pair.count);
      finalPairs = pairs.sublist(0, kMaxItems - 1) +
          [_TypePair('other object', countRest)];
    }
    final stringPairs = finalPairs.map((e) => e.toString()).toList();
    if (stringPairs.length >= 2) {
      stringPairs.last = 'and ${stringPairs.last}';
    }
    return stringPairs.join(stringPairs.length <= 2 ? ' ' : ', ');
  }

  String generateComment(Iterable<OsmChange> changes, {bool simple = false}) {
    final typeCount = _TypeCount(changes);
    List<String> results = [];
    if (typeCount.created.isNotEmpty) {
      results.add('Created ${_typeCountToString(typeCount.created, simple)}');
    }
    if (typeCount.updated.isNotEmpty) {
      results.add('Updated ${_typeCountToString(typeCount.updated, simple)}');
    }
    if (typeCount.deleted.isNotEmpty) {
      results.add('Deleted ${_typeCountToString(typeCount.deleted, simple)}');
    }
    if (typeCount.confirmed.isNotEmpty) {
      results
          .add('Confirmed ${_typeCountToString(typeCount.confirmed, simple)}');
    }
    return results.join('; ');
  }
}
