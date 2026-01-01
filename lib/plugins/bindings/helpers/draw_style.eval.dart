import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:flutter_eval/ui.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';

/// dart_eval wrapper binding for [DrawingStyle]
class $DrawingStyle implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/draw_style.dart',
      'DrawingStyle.',
      $DrawingStyle.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/draw_style.dart',
      'DrawingStyle.kDefaultStroke*g',
      $DrawingStyle.$kDefaultStroke,
    );
  }

  /// Compile-time type specification of [$DrawingStyle]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/draw_style.dart',
    'DrawingStyle',
  );

  /// Compile-time type declaration of [$DrawingStyle]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$DrawingStyle]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
              ),
              false,
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
              ),
              false,
            ),

            BridgeParameter(
              'thin',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'dashed',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {
      'stroke': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'casing': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'name': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'color': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
        ),
        isStatic: false,
      ),

      'thin': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'dashed': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
        ),
        isStatic: false,
      ),

      'kDefaultStroke': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
        isStatic: true,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [DrawingStyle.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $DrawingStyle.wrap(
      DrawingStyle(
        args[0]!.$value,
        color: args[1]!.$value,
        icon: args[2]!.$value,
        thin: args[3]?.$value ?? false,
        dashed: args[4]?.$value ?? false,
      ),
    );
  }

  /// Wrapper for the [DrawingStyle.kDefaultStroke] getter
  static $Value? $kDefaultStroke(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = DrawingStyle.kDefaultStroke;
    return $double(value);
  }

  final $Instance _superclass;

  @override
  final DrawingStyle $value;

  @override
  DrawingStyle get $reified => $value;

  /// Wrap a [DrawingStyle] in a [$DrawingStyle]
  $DrawingStyle.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'name':
        return $String($value.name);

      case 'color':
        return $Color.wrap($value.color);

      case 'thin':
        return $bool($value.thin);

      case 'dashed':
        return $bool($value.dashed);

      case 'icon':
        return $MultiIcon.wrap($value.icon);

      case 'stroke':
        return $double($value.stroke);

      case 'casing':
        return $Color.wrap($value.casing);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
