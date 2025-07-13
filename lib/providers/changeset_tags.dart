import 'dart:io';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final changesetTagsProvider =
    ChangeNotifierProvider((ref) => ChangesetTagsProvider());

class ChangesetTagsProvider extends ChangeNotifier {
  static const _kHashtagsKey = 'hashtags';
  static final _generator = CommentGenerator();
  String? _hashtags;

  ChangesetTagsProvider() {
    loadHashtags();
  }

  Map<String, String> generateChangesetTags(Iterable<OsmChange> changes) {
    final hashtags = getHashtags();
    final maxCommentLength = 230 - hashtags.length;

    String comment = _generator.generateComment(changes);
    if (comment.length > maxCommentLength) {
      comment = _generator.generateComment(changes, simple: true);
      if (comment.length > maxCommentLength) {
        comment = 'Surveyed ${changes.length} objects';
      }
    }
    if (hashtags.isNotEmpty) comment += ' $hashtags';

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

  Future<void> loadHashtags() async {
    final prefs = await SharedPreferences.getInstance();
    _hashtags = prefs.getString(_kHashtagsKey) ?? '';
    notifyListeners();
  }

  String getHashtags({bool clearHashes = false}) {
    String hashtags = _hashtags ?? '';
    if (clearHashes) {
      hashtags = hashtags.replaceAll('#', '');
    }
    return hashtags;
  }

  Future<void> saveHashtags(String value) async {
    final tags = value
        .split(RegExp(r'\s+|#'))
        .map((s) => s.replaceAll('#', ''))
        .where((s) => s.length > 1)
        .map((s) => '#' + s)
        .join(' ');
    _hashtags = tags;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHashtagsKey, tags);
  }
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

  void add(OsmChange change) {
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
    if (ElementKind.address.matchesChange(change)) return 'address';
    final rawKey = change.mainKey;
    final value = change[rawKey ?? ''];
    if (rawKey == null || value == null) return 'unknown object';
    // No use having "disused:shop" in a comment.
    final key = rawKey.substring(rawKey.indexOf(':') + 1);
    if (value == 'yes') return key;
    if ({'shop', 'office', 'building', 'entrance', 'club'}.contains(key))
      return '$value $key'; // school building
    // Trim "services" and "lights", but not "cross".
    if (value.endsWith('s') && !value.endsWith('ss'))
      return value.substring(0, value.length - 1);
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
