import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [TagMatcher]
class $TagMatcher implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'TagMatcher.',
      $TagMatcher.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'TagMatcher.fromJson',
      $TagMatcher.$fromJson,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'TagMatcher.fromList',
      $TagMatcher.$fromList,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'TagMatcher.empty*g',
      $TagMatcher.$empty,
    );
  }

  /// Compile-time type specification of [$TagMatcher]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/tags/tag_matcher.dart',
    'TagMatcher',
  );

  /// Compile-time type declaration of [$TagMatcher]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$TagMatcher]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'good',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'missing',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'removeFromGood',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'replace',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'rules',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/tags/tag_matcher.dart',
                        'ValueMatcher',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),

      'fromJson': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),

      'fromList': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              false,
            ),

            BridgeParameter(
              'update',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),
    },

    methods: {
      'matches': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'onlyKey',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),

      'matchesChange': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'change',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/amenity.dart',
                    'OsmChange',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'onlyKey',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),

      'mergeWith': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/tag_matcher.dart',
                'TagMatcher',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'another',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/tag_matcher.dart',
                    'TagMatcher',
                  ),
                  [],
                ),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'isEmpty': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'empty': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/tags/tag_matcher.dart',
              'TagMatcher',
            ),
            [],
          ),
        ),
        isStatic: true,
      ),

      'rules': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/tags/tag_matcher.dart',
                  'ValueMatcher',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'good': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'removeFromGood': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'missing': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'replace': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [TagMatcher.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $TagMatcher.wrap(
      TagMatcher(
        (args[0]!.$reified as Map).cast(),
        good: (args[1]?.$reified ?? const {} as Set?)?.cast(),
        missing: (args[2]?.$reified ?? const {} as Set?)?.cast(),
        removeFromGood: (args[3]?.$reified ?? const {} as Set?)?.cast(),
        replace: args[4]?.$value ?? false,
      ),
    );
  }

  /// Wrapper for the [TagMatcher.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $TagMatcher.wrap(
      TagMatcher.fromJson((args[0]!.$reified as Map).cast()),
    );
  }

  /// Wrapper for the [TagMatcher.fromList] constructor
  static $Value? $fromList(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $TagMatcher.wrap(
      TagMatcher.fromList((args[0]!.$reified as List).cast(), args[1]!.$value),
    );
  }

  /// Wrapper for the [TagMatcher.empty] getter
  static $Value? $empty(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = TagMatcher.empty;
    return $TagMatcher.wrap(value);
  }

  final $Instance _superclass;

  @override
  final TagMatcher $value;

  @override
  TagMatcher get $reified => $value;

  /// Wrap a [TagMatcher] in a [$TagMatcher]
  $TagMatcher.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rules':
        final _rules = $value.rules;
        return $Map.wrap(_rules);

      case 'good':
        final _good = $value.good;
        return $Set.wrap(_good);

      case 'removeFromGood':
        final _removeFromGood = $value.removeFromGood;
        return $Set.wrap(_removeFromGood);

      case 'missing':
        final _missing = $value.missing;
        return $Set.wrap(_missing);

      case 'replace':
        final _replace = $value.replace;
        return $bool(_replace);

      case 'isEmpty':
        final _isEmpty = $value.isEmpty;
        return $bool(_isEmpty);
      case 'matches':
        return __matches;

      case 'matchesChange':
        return __matchesChange;

      case 'mergeWith':
        return __mergeWith;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __matches = $Function(_matches);
  static $Value? _matches(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $TagMatcher;
    final result = self.$value.matches(
      (args[0]!.$reified as Map).cast(),
      args[1]?.$value,
    );
    return $bool(result);
  }

  static const $Function __matchesChange = $Function(_matchesChange);
  static $Value? _matchesChange(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $TagMatcher;
    final result = self.$value.matchesChange(args[0]!.$value, args[1]?.$value);
    return $bool(result);
  }

  static const $Function __mergeWith = $Function(_mergeWith);
  static $Value? _mergeWith(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $TagMatcher;
    final result = self.$value.mergeWith(args[0]!.$value);
    return $TagMatcher.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [ValueMatcher]
class $ValueMatcher implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'ValueMatcher.',
      $ValueMatcher.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/tag_matcher.dart',
      'ValueMatcher.fromJson',
      $ValueMatcher.$fromJson,
    );
  }

  /// Compile-time type specification of [$ValueMatcher]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/tags/tag_matcher.dart',
    'ValueMatcher',
  );

  /// Compile-time type declaration of [$ValueMatcher]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ValueMatcher]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'except',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'only',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'when',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/tags/tag_matcher.dart',
                        'TagMatcher',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'replace',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),

      'fromJson': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),
    },

    methods: {
      'matches': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),
          ],
        ),
      ),

      'matchesChange': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'change',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/amenity.dart',
                    'OsmChange',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'mergeWith': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/tag_matcher.dart',
                'ValueMatcher',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'another',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/tag_matcher.dart',
                    'ValueMatcher',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'except': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'only': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'when': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/tags/tag_matcher.dart',
                  'TagMatcher',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'replace': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ValueMatcher.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ValueMatcher.wrap(
      ValueMatcher(
        except: (args[0]?.$reified ?? const {} as Set?)?.cast(),
        only: (args[1]?.$reified ?? const {} as Set?)?.cast(),
        when: (args[2]?.$reified ?? const {} as Map?)?.cast(),
        replace: args[3]?.$value ?? true,
      ),
    );
  }

  /// Wrapper for the [ValueMatcher.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $ValueMatcher.wrap(
      ValueMatcher.fromJson((args[0]!.$reified as Map).cast()),
    );
  }

  final $Instance _superclass;

  @override
  final ValueMatcher $value;

  @override
  ValueMatcher get $reified => $value;

  /// Wrap a [ValueMatcher] in a [$ValueMatcher]
  $ValueMatcher.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'except':
        final _except = $value.except;
        return $Set.wrap(_except);

      case 'only':
        final _only = $value.only;
        return $Set.wrap(_only);

      case 'when':
        final _when = $value.when;
        return $Map.wrap(_when);

      case 'replace':
        final _replace = $value.replace;
        return $bool(_replace);
      case 'matches':
        return __matches;

      case 'matchesChange':
        return __matchesChange;

      case 'mergeWith':
        return __mergeWith;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __matches = $Function(_matches);
  static $Value? _matches(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $ValueMatcher;
    final result = self.$value.matches(
      args[0]!.$value,
      (args[1]!.$reified as Map).cast(),
    );
    return $bool(result);
  }

  static const $Function __matchesChange = $Function(_matchesChange);
  static $Value? _matchesChange(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ValueMatcher;
    final result = self.$value.matchesChange(args[0]!.$value, args[1]!.$value);
    return $bool(result);
  }

  static const $Function __mergeWith = $Function(_mergeWith);
  static $Value? _mergeWith(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ValueMatcher;
    final result = self.$value.mergeWith(args[0]!.$value);
    return $ValueMatcher.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
