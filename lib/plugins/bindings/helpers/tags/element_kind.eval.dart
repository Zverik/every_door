// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/element_kind_std.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/plugins/bindings/helpers/tags/element_kind.eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:every_door/plugins/bindings/helpers/tags/tag_matcher.eval.dart';

/// dart_eval wrapper binding for [ElementKind]
class $ElementKind implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.get',
      $ElementKind.$get,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.match',
      $ElementKind.$match,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.matchChange',
      $ElementKind.$matchChange,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.reset',
      $ElementKind.$reset,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.register',
      $ElementKind.$register,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.empty*g',
      $ElementKind.$empty,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.unknown*g',
      $ElementKind.$unknown,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.amenity*g',
      $ElementKind.$amenity,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.micro*g',
      $ElementKind.$micro,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.building*g',
      $ElementKind.$building,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.entrance*g',
      $ElementKind.$entrance,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.address*g',
      $ElementKind.$address,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.structure*g',
      $ElementKind.$structure,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.needsCheck*g',
      $ElementKind.$needsCheck,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.needsInfo*g',
      $ElementKind.$needsInfo,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKind.everything*g',
      $ElementKind.$everything,
    );
  }

  /// Compile-time type specification of [$ElementKind]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/tags/element_kind.dart',
    'ElementKind',
  );

  /// Compile-time type declaration of [$ElementKind]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ElementKind]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},

    methods: {
      'get': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isStatic: true,
      ),

      'match': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
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
              'kinds',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/tags/element_kind.dart',
                        'ElementKindImpl',
                      ),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
        isStatic: true,
      ),

      'matchChange': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
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
              'kinds',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/tags/element_kind.dart',
                        'ElementKindImpl',
                      ),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
        isStatic: true,
      ),

      'reset': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'register': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'kind',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/element_kind.dart',
                    'ElementKindImpl',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
        isStatic: true,
      ),
    },
    getters: {
      'empty': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'unknown': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'amenity': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'micro': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'building': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'entrance': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'address': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'structure': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'needsCheck': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'needsInfo': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),

      'everything': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
        isStatic: true,
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ElementKind.get] method
  static $Value? $get(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.get(args[0]!.$value);
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.match] method
  static $Value? $match(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.match(
      (args[0]!.$reified as Map).cast(),
      (args[1]?.$reified as List?)?.cast(),
    );
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.matchChange] method
  static $Value? $matchChange(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.matchChange(
      args[0]!.$value,
      (args[1]?.$reified as List?)?.cast(),
    );
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.reset] method
  static $Value? $reset(Runtime runtime, $Value? target, List<$Value?> args) {
    ElementKind.reset();
    return $null();
  }

  /// Wrapper for the [ElementKind.register] method
  static $Value? $register(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    ElementKind.register(args[0]!.$value);
    return $null();
  }

  /// Wrapper for the [ElementKind.empty] getter
  static $Value? $empty(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.empty;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.unknown] getter
  static $Value? $unknown(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.unknown;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.amenity] getter
  static $Value? $amenity(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.amenity;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.micro] getter
  static $Value? $micro(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.micro;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.building] getter
  static $Value? $building(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.building;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.entrance] getter
  static $Value? $entrance(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.entrance;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.address] getter
  static $Value? $address(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ElementKind.address;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.structure] getter
  static $Value? $structure(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.structure;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.needsCheck] getter
  static $Value? $needsCheck(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.needsCheck;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.needsInfo] getter
  static $Value? $needsInfo(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.needsInfo;
    return $ElementKindImpl.wrap(value);
  }

  /// Wrapper for the [ElementKind.everything] getter
  static $Value? $everything(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = ElementKind.everything;
    return $ElementKindImpl.wrap(value);
  }

  final $Instance _superclass;

  @override
  final ElementKind $value;

  @override
  ElementKind get $reified => $value;

  /// Wrap a [ElementKind] in a [$ElementKind]
  $ElementKind.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [ElementKindImpl]
class $ElementKindImpl implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKindImpl.',
      $ElementKindImpl.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/tags/element_kind.dart',
      'ElementKindImpl.fromJson',
      $ElementKindImpl.$fromJson,
    );
  }

  /// Compile-time type specification of [$ElementKindImpl]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/tags/element_kind.dart',
    'ElementKindImpl',
  );

  /// Compile-time type declaration of [$ElementKindImpl]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ElementKindImpl]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'matcher',
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
              true,
            ),

            BridgeParameter(
              'icon',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/multi_icon.dart',
                    'MultiIcon',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'onMainKey',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

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
      'matchesTags': BridgeMethodDef(
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
          ],
        ),
      ),

      'mergeWith': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/tags/element_kind.dart',
                'ElementKindImpl',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/element_kind.dart',
                    'ElementKindImpl',
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
      'name': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'icon': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/multi_icon.dart',
              'MultiIcon',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'matcher': BridgeFieldDef(
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
        isStatic: false,
      ),

      'onMainKey': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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

  /// Wrapper for the [ElementKindImpl.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ElementKindImpl.wrap(
      ElementKindImpl(
        name: args[0]!.$value,
        matcher: args[1]?.$value,
        icon: args[2]?.$value,
        onMainKey: args[3]?.$value ?? true,
        replace: args[4]?.$value ?? true,
      ),
    );
  }

  /// Wrapper for the [ElementKindImpl.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $ElementKindImpl.wrap(
      ElementKindImpl.fromJson(
        args[0]!.$value,
        (args[1]!.$reified as Map).cast(),
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ElementKindImpl $value;

  @override
  ElementKindImpl get $reified => $value;

  /// Wrap a [ElementKindImpl] in a [$ElementKindImpl]
  $ElementKindImpl.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'matcher':
        final _matcher = $value.matcher;
        return _matcher == null ? const $null() : $TagMatcher.wrap(_matcher);

      case 'onMainKey':
        final _onMainKey = $value.onMainKey;
        return $bool(_onMainKey);

      case 'replace':
        final _replace = $value.replace;
        return $bool(_replace);
      case 'matchesTags':
        return __matchesTags;

      case 'matchesChange':
        return __matchesChange;

      case 'mergeWith':
        return __mergeWith;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __matchesTags = $Function(_matchesTags);
  static $Value? _matchesTags(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ElementKindImpl;
    final result = self.$value.matchesTags((args[0]!.$reified as Map).cast());
    return $bool(result);
  }

  static const $Function __matchesChange = $Function(_matchesChange);
  static $Value? _matchesChange(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ElementKindImpl;
    final result = self.$value.matchesChange(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __mergeWith = $Function(_mergeWith);
  static $Value? _mergeWith(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ElementKindImpl;
    final result = self.$value.mergeWith(args[0]!.$value);
    return $ElementKindImpl.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
