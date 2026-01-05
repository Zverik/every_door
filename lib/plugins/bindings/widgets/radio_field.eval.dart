import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/radio_field.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [RadioField]
class $RadioField implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/radio_field.dart',
      'RadioField.',
      $RadioField.$new,
    );
  }

  /// Compile-time type specification of [$RadioField]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/radio_field.dart',
    'RadioField',
  );

  /// Compile-time type declaration of [$RadioField]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$RadioField]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, $extends: $StatefulWidget$bridge.$type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'options',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),
            BridgeParameter(
              'labels',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'widgetLabels',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:flutter/src/widgets/framework.dart',
                        'Widget',
                      ),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'values',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'wrap',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'multi',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'keepFirst',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'keepOrder',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'onChange',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.dynamic),
                    ),
                    params: [
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(CoreTypes.string, []),
                          nullable: true,
                        ),
                        false,
                      ),
                    ],
                    namedParams: [],
                  ),
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'onMultiChange',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.dynamic),
                    ),
                    params: [
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(CoreTypes.list, [
                            BridgeTypeAnnotation(
                              BridgeTypeRef(CoreTypes.string, []),
                            ),
                          ]),
                        ),
                        false,
                      ),
                    ],
                    namedParams: [],
                  ),
                ),
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
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [RadioField.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $RadioField.wrap(
      RadioField(
        options: (args[0]!.$reified as List).cast(),
        labels: (args[1]?.$reified as List?)?.cast(),
        widgetLabels: (args[2]?.$reified as List?)?.cast(),
        value: args[3]?.$value,
        values: (args[4]?.$reified as List?)?.cast(),
        wrap: args[5]?.$value ?? false,
        multi: args[6]?.$value ?? false,
        keepFirst: args[7]?.$value ?? false,
        keepOrder: args[8]?.$value ?? false,
        onChange: (String? arg0) {
          return (args[9]! as EvalCallable?)?.call(runtime, null, [
            if (arg0 == null) const $null() else $String(arg0),
          ])?.$value;
        },
        onMultiChange: (List<String> arg0) {
          return (args[10]! as EvalCallable?)?.call(runtime, null, [
            $List.view(arg0, (e) => $String(e)),
          ])?.$value;
        },
      ),
    );
  }

  @override
  final RadioField $value;

  @override
  RadioField get $reified => $value;

  /// Wrap a [RadioField] in a [$RadioField]
  $RadioField.wrap(this.$value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    throw UnimplementedError();
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    throw UnimplementedError();
  }
}
