// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/models/amenity.dart';

/// A class for matching tag lists against a set of rules.
/// Contains rules for individual keys (see [ValueMatcher]),
/// and lists of [good] and [missing] keys to validate.
@Bind()
class TagMatcher {
  /// Empty matcher that matches everything.
  static const empty = TagMatcher({});

  /// Rules for matching values for a key.
  final Map<String, ValueMatcher> rules;

  /// List of keys to be accepted without looking at the rules.
  /// Works only for the "onlyKey" parameter of [matches] and [matchesChange].
  final Set<String> good;

  /// List of keys that should be missing. If it's not empty and
  /// _any_ of the keys here are missing, and all the rules match
  /// or are skipped, then [matches] returns "true".
  /// Unlike for [good], we don't strip prefixes here for matching.
  /// This is used for matching objects that lack some additional tags.
  final Set<String> missing;

  const TagMatcher(this.rules, {this.good = const {}, this.missing = const {}});

  /// Returns "true" only if nothing has been initialized.
  bool get isEmpty => rules.isEmpty && good.isEmpty && missing.isEmpty;

  /// Tests a set of tags for a match. Pass [onlyKey] to test only
  /// rules for this single key, and also use [good] key set.
  /// A prefix in [onlyKey] is stripped, but not in other keys.
  ///
  /// For matching an [OsmChange] object, see [matchesChange].
  bool matches(Map<String, String> tags, [String? onlyKey]) {
    assert(onlyKey == null || tags.containsKey(onlyKey));

    final rawKey = clearPrefixNull(onlyKey);
    if (good.contains(rawKey)) return true;
    if (missing.any((k) => !tags.containsKey(k))) return true;
    if (rules.isEmpty) return missing.isEmpty && good.isEmpty;

    if (onlyKey != null) {
      final rule = rules[rawKey];
      if (rule != null && rule.matches(tags[onlyKey]!, tags)) return true;
    } else {
      for (final kr in rules.entries) {
        final value = tags[kr.key];
        if (value != null && kr.value.matches(value, tags)) return true;
      }
    }

    return false;
  }

  /// Tests an [OsmChange] object for a match. Performs exactly
  /// as [match], but doesn't call [OsmChange.getFullTags].
  bool matchesChange(OsmChange change, [String? onlyKey]) {
    assert(onlyKey == null || change[onlyKey] != null);

    final rawKey = clearPrefixNull(onlyKey);
    if (good.contains(rawKey)) return true;
    if (missing.any((k) => change[k] == null)) return true;
    if (rules.isEmpty) return missing.isEmpty && good.isEmpty;

    if (onlyKey != null) {
      final rule = rules[rawKey];
      if (rule != null && rule.matchesChange(change[onlyKey]!, change))
        return true;
    } else {
      for (final kr in rules.entries) {
        final value = change[kr.key];
        if (value != null && kr.value.matchesChange(value, change)) return true;
      }
    }

    return false;
  }

  /// Merges this tag matcher with another. Used internally.
  /// Rules are merged using [ValueMatcher.mergeWith], [good] keys
  /// are united, [missing] set is replaced.
  TagMatcher mergeWith(TagMatcher? another) {
    if (another == null) return this;

    final newRules = Map.of(rules);
    for (final kv in another.rules.entries) {
      newRules[kv.key] = newRules[kv.key]?.mergeWith(kv.value) ?? kv.value;
    }

    return TagMatcher(
      newRules,
      good: good.union(another.good),
      missing: another.missing,
    );
  }

  /// Builds a class instance from a structure. It expects a plain map
  /// with tag keys for keys, and [ValueMatcher] structures for values.
  /// Two keys are exceptions and should contain lists of strings:
  /// "$good" (see [good]) and "$missing" (see [missing]).
  factory TagMatcher.fromJson(Map<String, dynamic>? data) {
    if (data == null) return empty;

    final rules = data.map((k, v) => MapEntry(k, ValueMatcher.fromJson(v)));
    rules.removeWhere((k, v) => k.startsWith('\$'));

    return TagMatcher(
      rules,
      good: Set.of(data['\$good'] ?? const []),
      missing: Set.of(data['\$missing'] ?? const []),
    );
  }
}

/// This class matches tag values to a set of rules.
@Bind()
class ValueMatcher {
  /// Those values are forbidden, the matcher will return "false".
  final Set<String> except;

  /// If not empty, this list should include every allowed value.
  /// Keys from [when] are also considered, so they can be omitted.
  final Set<String> only;

  /// Conditional rules for some values. They allow to check other
  /// sub-tags, e.g. "recycling_type=*" for "amenity=recycling".
  /// When [only] and [except] are empty, only values in this map
  /// are accepted (it works as "only").
  final Map<String, TagMatcher> when;

  /// When updating a matcher, replace all fields or add values.
  final bool replace;

  const ValueMatcher({
    this.except = const {},
    this.only = const {},
    this.when = const {},
    this.replace = true,
  });

  /// Tests the value to match all the rules.
  bool matches(String value, Map<String, String> tags) {
    if (only.isNotEmpty && !(only.contains(value) || when.containsKey(value)))
      return false;
    if (except.isNotEmpty && except.contains(value)) return false;
    if (!(when[value]?.matches(tags) ?? true)) return false;
    if (when.isNotEmpty &&
        except.isEmpty &&
        only.isEmpty &&
        !when.containsKey(value)) return false;
    return true;
  }

  /// Tests an [OsmChange] object for a match. Performs exactly
  /// as [match], but doesn't call [OsmChange.getFullTags].
  bool matchesChange(String value, OsmChange change) {
    if (only.isNotEmpty && !(only.contains(value) || when.containsKey(value)))
      return false;
    if (except.isNotEmpty && except.contains(value)) return false;
    if (!(when[value]?.matchesChange(change) ?? true)) return false;
    if (when.isNotEmpty &&
        except.isEmpty &&
        only.isEmpty &&
        !when.containsKey(value)) return false;
    return true;
  }

  /// Merge two value matchers. Used internally when updating from
  /// an external source.
  ValueMatcher mergeWith(ValueMatcher another) {
    if (another.replace) return another;

    final newWhen = Map.of(when);
    newWhen.addAll(another.when);

    return ValueMatcher(
      except: except.union(another.except),
      only: only.union(another.only),
      when: newWhen,
    );
  }

  /// Builds a class instance out of a structure. The structure
  /// is straightforward: a map with "except", "only", and "when"
  /// keys that replicated this class fields.
  factory ValueMatcher.fromJson(Map<String, dynamic> data) {
    return ValueMatcher(
      except: Set.of(
          (data['except'] as Iterable<dynamic>?)?.whereType<String>() ??
              const []),
      only: Set.of((data['only'] as Iterable<dynamic>?)?.whereType<String>() ??
          const []),
      when: (data['when'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, TagMatcher.fromJson(data['when']))) ??
          const {},
      replace: data['replace'] ?? true,
    );
  }
}
