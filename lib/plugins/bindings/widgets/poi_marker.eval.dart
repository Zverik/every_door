// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/poi_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/ui.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [NumberedMarker]
class $NumberedMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/poi_marker.dart',
      'NumberedMarker.',
      $NumberedMarker.$new,
    );
  }

  /// Compile-time type specification of [$NumberedMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/poi_marker.dart',
    'NumberedMarker',
  );

  /// Compile-time type declaration of [$NumberedMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$NumberedMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter/src/widgets/framework.dart',
          'StatelessWidget',
        ),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/foundation/key.dart',
                    'Key',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'index',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
              ),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'build': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/widgets/framework.dart',
                'Widget',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
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
      'index': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, []), nullable: true),
        isStatic: false,
      ),

      'color': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [NumberedMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $NumberedMarker.wrap(
      NumberedMarker(
        key: args[0]?.$value,
        index: args[1]?.$value,
        color: args[2]?.$value ?? Colors.white,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final NumberedMarker $value;

  @override
  NumberedMarker get $reified => $value;

  /// Wrap a [NumberedMarker] in a [$NumberedMarker]
  $NumberedMarker.wrap(this.$value)
    : _superclass = $StatelessWidget.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'index':
        final _index = $value.index;
        return _index == null ? const $null() : $int(_index);

      case 'color':
        final _color = $value.color;
        return $Color.wrap(_color);
      case 'build':
        return __build;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __build = $Function(_build);
  static $Value? _build(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $NumberedMarker;
    final result = self.$value.build(args[0]!.$value);
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [ColoredMarker]
class $ColoredMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/poi_marker.dart',
      'ColoredMarker.',
      $ColoredMarker.$new,
    );
  }

  /// Compile-time type specification of [$ColoredMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/poi_marker.dart',
    'ColoredMarker',
  );

  /// Compile-time type declaration of [$ColoredMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ColoredMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter/src/widgets/framework.dart',
          'StatelessWidget',
        ),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/foundation/key.dart',
                    'Key',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
              ),
              true,
            ),

            BridgeParameter(
              'isIncomplete',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'build': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/widgets/framework.dart',
                'Widget',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
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
      'color': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
        ),
        isStatic: false,
      ),

      'isIncomplete': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ColoredMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ColoredMarker.wrap(
      ColoredMarker(
        key: args[0]?.$value,
        color: args[1]?.$value ?? Colors.black,
        isIncomplete: args[2]?.$value ?? false,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ColoredMarker $value;

  @override
  ColoredMarker get $reified => $value;

  /// Wrap a [ColoredMarker] in a [$ColoredMarker]
  $ColoredMarker.wrap(this.$value)
    : _superclass = $StatelessWidget.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'color':
        final _color = $value.color;
        return $Color.wrap(_color);

      case 'isIncomplete':
        final _isIncomplete = $value.isIncomplete;
        return $bool(_isIncomplete);
      case 'build':
        return __build;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __build = $Function(_build);
  static $Value? _build(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $ColoredMarker;
    final result = self.$value.build(args[0]!.$value);
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
