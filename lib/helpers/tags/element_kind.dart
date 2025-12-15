import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/tags/element_kind_std.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:every_door/models/amenity.dart';

/// A static factory for [ElementKindImpl], which also contains some
/// pre-defined kinds and supports merging kinds.
@Bind()
class ElementKind {
  /// Matches objects without meaningful tags.
  static ElementKindImpl get empty => _kinds["empty"]!;

  /// Matches everything. Is returned by [match] and [matchChange]
  /// when no other match was found.
  static ElementKindImpl get unknown => _kinds["unknown"]!;

  /// Matches amenities like restaurants.
  static ElementKindImpl get amenity => _kinds['amenity']!;

  /// Matches micromapping-related objects like trees.
  static ElementKindImpl get micro => _kinds["micro"]!;

  /// Matches buildings, even when there are other tags.
  static ElementKindImpl get building => _kinds["building"]!;

  /// Matches entrances, even when there are other tags.
  static ElementKindImpl get entrance => _kinds["entrance"]!;

  /// Matches address points that don't have other more important uses.
  static ElementKindImpl get address => _kinds["address"]!;

  /// Matches long-standing amenities that are not supposed
  /// to disappear overnight.
  static ElementKindImpl get structure => _kinds["structure"]!;

  /// Matches objects that would benefit from "check_date" tag.
  /// Defaults to [amenity].
  static ElementKindImpl get needsCheck => _kinds["needsCheck"]!;

  /// Matches micromapping-related objects that miss some important
  /// secondary tags.
  static ElementKindImpl get needsInfo => _kinds["needsInfo"]!;

  /// Matches everything the editor processes (not everything ever
  /// like [unknown]).
  static ElementKindImpl get everything => _kinds["everything"]!;

  static final Map<String, ElementKindImpl> _kinds = {};

  ElementKind._();

  static ElementKindImpl get(String name) => _kinds[name] ?? unknown;

  static const _kMatchedKinds = [
    'amenity',
    'micro',
    'building',
    'entrance',
    'address',
    'empty',
  ];

  static ElementKindImpl match(Map<String, String> tags,
      [List<ElementKindImpl>? kinds]) {
    for (final k in kinds ?? _kMatchedKinds) {
      final ek = _kinds[k]!;
      if (ek.matchesTags(tags)) return ek;
    }
    return ElementKind.unknown;
  }

  static ElementKindImpl matchChange(OsmChange change,
      [List<ElementKindImpl>? kinds]) {
    kinds ??= _kMatchedKinds.map((k) => _kinds[k]!).toList();
    for (final k in kinds) {
      if (k.matchesChange(change)) return k;
    }
    return ElementKind.unknown;
  }

  static void reset() {
    register(ElementKindImpl(name: 'unknown')); // by default everything matches
    registerStandardKinds();
  }

  static void register(ElementKindImpl kind) {
    final name = kind.name;
    if (!_kinds.containsKey(name)) {
      _kinds[name] = kind;
    } else {
      _kinds[name] = _kinds[name]!.mergeWith(kind);
    }
  }
}

@Bind()
class ElementKindImpl {
  final String name;
  final MultiIcon? icon;
  final TagMatcher? matcher;
  final bool onMainKey;
  final bool replace;

  const ElementKindImpl({
    required this.name,
    this.matcher,
    this.icon,
    this.onMainKey = true,
    this.replace = true,
  });

  bool matchesTags(Map<String, String> tags) {
    String? mainKey;
    if (onMainKey) {
      mainKey = getMainKey(tags);
      if (mainKey == null) return false;
    }
    return matcher?.matches(tags, mainKey) ?? false;
  }

  bool matchesChange(OsmChange change) {
    String? mainKey;
    if (onMainKey) {
      mainKey = change.mainKey;
      if (mainKey == null) return false;
    }

    return matcher?.matchesChange(change, mainKey) ??
        matchesTags(change.getFullTags());
  }

  ElementKindImpl mergeWith(ElementKindImpl other) {
    return ElementKindImpl(
      name: name,
      icon: other.icon ?? icon,
      onMainKey: other.onMainKey,
      matcher: matcher == null || other.replace
          ? other.matcher
          : matcher!.mergeWith(other.matcher),
    );
  }

  factory ElementKindImpl.fromJson(String name, Map<String, dynamic> data) {
    final replace = data.containsKey('matcher');
    return ElementKindImpl(
      name: name,
      onMainKey: data['onMainKey'] as bool? ?? true,
      matcher: TagMatcher.fromJson(data[replace ? 'matcher' : 'update']),
      replace: replace,
    );
  }
}
