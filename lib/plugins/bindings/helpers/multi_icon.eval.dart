// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [MultiIcon]
class $MultiIcon implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/multi_icon.dart',
      'MultiIcon.',
      $MultiIcon.$new,
    );
  }

  /// Compile-time type specification of [$MultiIcon]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/multi_icon.dart',
    'MultiIcon',
  );

  /// Compile-time type declaration of [$MultiIcon]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MultiIcon]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'fontIcon',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/icon_data.dart',
                    'IconData',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'emoji',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'imageData',
              BridgeTypeAnnotation(
                BridgeTypeRef(TypedDataTypes.uint8List, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'svgData',
              BridgeTypeAnnotation(
                BridgeTypeRef(TypedDataTypes.uint8List, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'siData',
              BridgeTypeAnnotation(
                BridgeTypeRef(TypedDataTypes.uint8List, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'imageUrl',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'asset',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'tooltip',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
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
      'withTooltip': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/multi_icon.dart',
                'MultiIcon',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'tooltip',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'getWidget': BridgeMethodDef(
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
          namedParams: [
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
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'size',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.double, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'semanticLabel',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'icon',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'fixedSize',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'tooltip': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [MultiIcon.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MultiIcon.wrap(
      MultiIcon(
        fontIcon: args[0]?.$value,
        emoji: args[1]?.$value,
        imageData: args[2]?.$value,
        svgData: args[3]?.$value,
        siData: args[4]?.$value,
        imageUrl: args[5]?.$value,
        asset: args[6]?.$value,
        tooltip: args[7]?.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final MultiIcon $value;

  @override
  MultiIcon get $reified => $value;

  /// Wrap a [MultiIcon] in a [$MultiIcon]
  $MultiIcon.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'tooltip':
        final _tooltip = $value.tooltip;
        return _tooltip == null ? const $null() : $String(_tooltip);
      case 'withTooltip':
        return __withTooltip;

      case 'getWidget':
        return __getWidget;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __withTooltip = $Function(_withTooltip);
  static $Value? _withTooltip(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $MultiIcon;
    final result = self.$value.withTooltip(args[0]!.$value);
    return $MultiIcon.wrap(result);
  }

  static const $Function __getWidget = $Function(_getWidget);
  static $Value? _getWidget(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $MultiIcon;
    final result = self.$value.getWidget(
      context: args[0]?.$value,
      size: args[1]?.$value,
      color: args[2]?.$value,
      semanticLabel: args[3]?.$value,
      icon: args[4]?.$value ?? true,
      fixedSize: args[5]?.$value ?? true,
    );
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
