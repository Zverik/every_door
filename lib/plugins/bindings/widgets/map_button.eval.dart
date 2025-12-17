// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';

/// dart_eval wrapper binding for [MapButton]
class $MapButton implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/map_button.dart',
      'MapButton.',
      $MapButton.$new,
    );
  }

  /// Compile-time type specification of [$MapButton]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/map_button.dart',
    'MapButton',
  );

  /// Compile-time type declaration of [$MapButton]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MapButton]
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
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'onPressed',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.voidType),
                    ),
                    params: [
                      BridgeParameter(
                        '',
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
                    namedParams: [],
                  ),
                ),
              ),
              false,
            ),

            BridgeParameter(
              'onLongPressed',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.voidType),
                    ),
                    params: [
                      BridgeParameter(
                        '',
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
                    namedParams: [],
                  ),
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
              'child',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'Widget',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'enabled',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'onPressed': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
              params: [
                BridgeParameter(
                  '',
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
              namedParams: [],
            ),
          ),
        ),
        isStatic: false,
      ),

      'onLongPressed': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
              params: [
                BridgeParameter(
                  '',
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
              namedParams: [],
            ),
          ),
          nullable: true,
        ),
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

      'child': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:flutter/src/widgets/framework.dart',
              'Widget',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'enabled': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

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

  /// Wrapper for the [MapButton.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MapButton.wrap(
      MapButton(
        key: args[0]?.$value,
        id: args[1]?.$value,
        onPressed: (BuildContext arg0) {
          (args[2]! as EvalCallable)(runtime, null, [$BuildContext.wrap(arg0)]);
        },
        onLongPressed: (BuildContext arg0) {
          (args[3]! as EvalCallable?)?.call(runtime, null, [
            $BuildContext.wrap(arg0),
          ]);
        },
        icon: args[4]?.$value,
        child: args[5]?.$value,
        enabled: args[6]?.$value ?? true,
        tooltip: args[7]?.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final MapButton $value;

  @override
  MapButton get $reified => $value;

  /// Wrap a [MapButton] in a [$MapButton]
  $MapButton.wrap(this.$value) : _superclass = $StatelessWidget.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return _id == null ? const $null() : $String(_id);

      case 'onPressed':
        final _onPressed = $value.onPressed;
        return $Function((runtime, target, args) {
          _onPressed(args[0]!.$value);
          return const $null();
        });

      case 'onLongPressed':
        final _onLongPressed = $value.onLongPressed;
        return _onLongPressed == null
            ? const $null()
            : $Function((runtime, target, args) {
                _onLongPressed(args[0]!.$value);
                return const $null();
              });

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'child':
        final _child = $value.child;
        return _child == null ? const $null() : $Widget.wrap(_child);

      case 'enabled':
        final _enabled = $value.enabled;
        return $bool(_enabled);

      case 'tooltip':
        final _tooltip = $value.tooltip;
        return _tooltip == null ? const $null() : $String(_tooltip);
      case 'build':
        return __build;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __build = $Function(_build);
  static $Value? _build(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $MapButton;
    final result = self.$value.build(args[0]!.$value);
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
