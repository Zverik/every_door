// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/version.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [PluginVersion]
class $PluginVersion implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/version.dart',
      'PluginVersion.',
      $PluginVersion.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/version.dart',
      'PluginVersion.exact',
      $PluginVersion.$exact,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/version.dart',
      'PluginVersion.zero*g',
      $PluginVersion.$zero,
    );
  }

  /// Compile-time type specification of [$PluginVersion]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/version.dart',
    'PluginVersion',
  );

  /// Compile-time type declaration of [$PluginVersion]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginVersion]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'version',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              false,
            ),

            BridgeParameter(
              'flatNumbering',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
        ),
        isFactory: false,
      ),

      'exact': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              '_major',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              false,
            ),

            BridgeParameter(
              '_minor',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      '<': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/version.dart',
                    'PluginVersion',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      '>': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/version.dart',
                    'PluginVersion',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      '<=': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/version.dart',
                    'PluginVersion',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'fresherThan': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'version',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/version.dart',
                    'PluginVersion',
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

      'nextMajor': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/version.dart',
                'PluginVersion',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'zero': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/version.dart',
              'PluginVersion',
            ),
            [],
          ),
        ),
        isStatic: true,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PluginVersion.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PluginVersion.wrap(
      PluginVersion(args[0]!.$value, args[1]?.$value ?? true),
    );
  }

  /// Wrapper for the [PluginVersion.exact] constructor
  static $Value? $exact(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $PluginVersion.wrap(
      PluginVersion.exact(args[0]!.$value, args[1]!.$value),
    );
  }

  /// Wrapper for the [PluginVersion.zero] getter
  static $Value? $zero(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = PluginVersion.zero;
    return $PluginVersion.wrap(value);
  }

  final $Instance _superclass;

  @override
  final PluginVersion $value;

  @override
  PluginVersion get $reified => $value;

  /// Wrap a [PluginVersion] in a [$PluginVersion]
  $PluginVersion.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case '<':
        return __operatorLt;

      case '>':
        return __operatorGt;

      case '<=':
        return __operatorLte;

      case 'fresherThan':
        return __fresherThan;

      case 'nextMajor':
        return __nextMajor;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __operatorLt = $Function(_operatorLt);
  static $Value? _operatorLt(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginVersion;
    final result = (self.$value < args[0]!.$value);
    return $bool(result);
  }

  static const $Function __operatorGt = $Function(_operatorGt);
  static $Value? _operatorGt(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginVersion;
    final result = (self.$value > args[0]!.$value);
    return $bool(result);
  }

  static const $Function __operatorLte = $Function(_operatorLte);
  static $Value? _operatorLte(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginVersion;
    final result = (self.$value <= args[0]!.$value);
    return $bool(result);
  }

  static const $Function __fresherThan = $Function(_fresherThan);
  static $Value? _fresherThan(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginVersion;
    final result = self.$value.fresherThan(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __nextMajor = $Function(_nextMajor);
  static $Value? _nextMajor(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginVersion;
    final result = self.$value.nextMajor();
    return $PluginVersion.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [PluginVersionRange]
class $PluginVersionRange implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/version.dart',
      'PluginVersionRange.',
      $PluginVersionRange.$new,
    );
  }

  /// Compile-time type specification of [$PluginVersionRange]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/version.dart',
    'PluginVersionRange',
  );

  /// Compile-time type declaration of [$PluginVersionRange]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginVersionRange]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'matches': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'version',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/version.dart',
                    'PluginVersion',
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
      'min': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/version.dart',
              'PluginVersion',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'max': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/version.dart',
              'PluginVersion',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PluginVersionRange.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PluginVersionRange.wrap(PluginVersionRange(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final PluginVersionRange $value;

  @override
  PluginVersionRange get $reified => $value;

  /// Wrap a [PluginVersionRange] in a [$PluginVersionRange]
  $PluginVersionRange.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'min':
        final _min = $value.min;
        return $PluginVersion.wrap(_min);

      case 'max':
        final _max = $value.max;
        return $PluginVersion.wrap(_max);
      case 'matches':
        return __matches;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __matches = $Function(_matches);
  static $Value? _matches(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $PluginVersionRange;
    final result = self.$value.matches(args[0]!.$value);
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'min':
        $value.min = value.$value;
        return;

      case 'max':
        $value.max = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
