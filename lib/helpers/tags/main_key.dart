// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
/// List of keys to consider when looking for a single main tag, in order of preference.
const kMainKeys = <String>[
  'amenity', 'shop', 'craft', 'tourism', 'historic', 'club',
  'office', 'healthcare', 'leisure', 'emergency', 'attraction',
  'xmas:feature',
  // non-amenity keys:
  'highway', 'railway', 'natural',
  'waterway', 'man_made', 'power', 'aeroway', 'aerialway',
  'marker', 'public_transport', 'traffic_sign', 'hazard', 'telecom',
  'advertising', 'playground', 'traffic_calming', 'cemetery',
  'military', 'barrier',
  // structure tags should be last:
  'building', 'entrance', 'building:part', 'indoor', 'boundary', 'landuse',
];

const kAmenityMainKeys = <String>{
  'amenity',
  'shop',
  'craft',
  'tourism',
  'historic',
  'club',
  'office',
  'healthcare',
  'leisure',
  'emergency',
  'attraction',
};

const kDisused = 'disused:';
const kDeleted = 'was:';
const kBuildingDeleted = 'demolished:';

const _kLifecyclePrefixes = <String>{
  'proposed',
  'planned',
  'construction',
  'disused',
  'abandoned',
  'ruins',
  'demolished',
  'removed',
  'razed',
  'destroyed',
  'was',
  'closed',
  'historic',
};

/// Find the single main key for an object. Also considers lifecycle prefixes.
String? getMainKey(Map<String, String> tags) {
  String? prefixed;
  bool isPrefixedAmenity = false;
  final prefixedKeys = Map.fromEntries(tags.keys
      .where((k) => k.contains(':'))
      .map((k) => MapEntry(clearPrefix(k), k)));
  for (final k in kMainKeys) {
    if (tags[k] == 'no') continue;
    if (tags.containsKey(k)) {
      // If we have seen a prefixed amenity, return that amenity instead of this non-amenity.
      if (!kAmenityMainKeys.contains(k) && isPrefixedAmenity) return prefixed;
      // Otherwise this amenity key takes precedence.
      return k;
    }
    if (prefixed == null && prefixedKeys.containsKey(k)) {
      prefixed = prefixedKeys[k];
      if (tags[prefixed] == 'no') continue;
      isPrefixedAmenity = kAmenityMainKeys.contains(k);
    }
  }
  return prefixed;
}

/// Remove a lifecycle prefix for the key, which is before the first `:` character.
String clearPrefix(String key) {
  final int pos = key.indexOf(':');
  if (pos < 0) return key;
  return _kLifecyclePrefixes.contains(key.substring(0, pos))
      ? key.substring(pos + 1)
      : key;
}

/// Remove a lifecycle prefix for the key, allowing for null input. See [clearPrefix].
String? clearPrefixNull(String? key) => key == null ? null : clearPrefix(key);
