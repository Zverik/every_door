import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/models/located.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/painting.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval bridge binding for [PoiDescriber]
class $PoiDescriber$bridge extends PoiDescriber with $Bridge<PoiDescriber> {
  /// Forwarded constructor for [PoiDescriber.new]
  $PoiDescriber$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$PoiDescriber$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/poi_describer.dart',
    'PoiDescriber',
  );

  /// Compile-time type declaration of [$PoiDescriber$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PoiDescriber]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'describe': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/painting/text_span.dart',
                'TextSpan',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'element',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/located.dart',
                    'Located',
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
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  TextSpan describe(Located element) =>
      $_invoke('describe', [$Located.wrap(element)]);
}

/// dart_eval wrapper binding for [PoiDescriber]
class $PoiDescriber implements $Instance {
  /// Compile-time type specification of [$PoiDescriber]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/poi_describer.dart',
    'PoiDescriber',
  );

  final $Instance _superclass;

  @override
  final PoiDescriber $value;

  @override
  PoiDescriber get $reified => $value;

  /// Wrap a [PoiDescriber] in a [$PoiDescriber]
  $PoiDescriber.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'describe':
        return __describe;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __describe = $Function(_describe);
  static $Value? _describe(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PoiDescriber;
    final result = self.$value.describe(args[0]!.$value);
    return $TextSpan.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [SimpleDescriber]
class $SimpleDescriber implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/poi_describer.dart',
      'SimpleDescriber.',
      $SimpleDescriber.$new,
    );
  }

  /// Compile-time type specification of [$SimpleDescriber]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/poi_describer.dart',
    'SimpleDescriber',
  );

  /// Compile-time type declaration of [$SimpleDescriber]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SimpleDescriber]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $implements: [
        BridgeTypeRef(
          BridgeTypeSpec(
            'package:every_door/helpers/poi_describer.dart',
            'PoiDescriber',
          ),
          [],
        ),
      ],
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'describe': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/painting/text_span.dart',
                'TextSpan',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'element',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/located.dart',
                    'Located',
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
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [SimpleDescriber.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $SimpleDescriber.wrap(SimpleDescriber());
  }

  final $Instance _superclass;

  @override
  final SimpleDescriber $value;

  @override
  SimpleDescriber get $reified => $value;

  /// Wrap a [SimpleDescriber] in a [$SimpleDescriber]
  $SimpleDescriber.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'describe':
        return __describe;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __describe = $Function(_describe);
  static $Value? _describe(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $SimpleDescriber;
    final result = self.$value.describe(args[0]!.$value);
    return $TextSpan.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
