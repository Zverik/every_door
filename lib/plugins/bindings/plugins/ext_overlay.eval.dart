// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/ext_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:every_door/plugins/bindings/models/imagery.eval.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [ExtOverlay]
class $ExtOverlay implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/plugins/ext_overlay.dart',
      'ExtOverlay.',
      $ExtOverlay.$new,
    );
  }

  /// Compile-time type specification of [$ExtOverlay]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/ext_overlay.dart',
    'ExtOverlay',
  );

  /// Compile-time type declaration of [$ExtOverlay]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ExtOverlay]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec('package:every_door/models/imagery.dart', 'Imagery'),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'attribution',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'updateInMeters',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              true,
            ),

            BridgeParameter(
              'build',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
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

                      BridgeParameter(
                        'data',
                        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
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
              'update',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.future, [
                        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                      ]),
                    ),
                    params: [
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(
                            BridgeTypeSpec(
                              'package:flutter_map/src/geo/latlng_bounds.dart',
                              'LatLngBounds',
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
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'buildLayer': BridgeMethodDef(
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
              'reset',
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
      'build': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
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

                BridgeParameter(
                  'data',
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                  false,
                ),
              ],
              namedParams: [],
            ),
          ),
        ),
        isStatic: false,
      ),

      'updateInMeters': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
        isStatic: false,
      ),

      'update': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.future, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
              ),
              params: [
                BridgeParameter(
                  '',
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:flutter_map/src/geo/latlng_bounds.dart',
                        'LatLngBounds',
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
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ExtOverlay.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ExtOverlay.wrap(
      ExtOverlay(
        id: args[0]!.$value,
        attribution: args[1]?.$value,
        updateInMeters: args[2]?.$value ?? 0,
        build: (BuildContext context, dynamic data) {
          return (args[3]! as EvalCallable)(runtime, null, [
            $BuildContext.wrap(context),
            $Object(data),
          ])?.$value;
        },
        update: (LatLngBounds arg0) {
          return (args[4]! as EvalCallable?)?.call(runtime, null, [
            $LatLngBounds.wrap(arg0),
          ])?.$value;
        },
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ExtOverlay $value;

  @override
  ExtOverlay get $reified => $value;

  /// Wrap a [ExtOverlay] in a [$ExtOverlay]
  $ExtOverlay.wrap(this.$value) : _superclass = $Imagery.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'build':
        final _build = $value.build;
        return $Function((runtime, target, args) {
          final funcResult = _build(args[0]!.$value, args[1]!.$value);
          return $Widget.wrap(funcResult);
        });

      case 'updateInMeters':
        final _updateInMeters = $value.updateInMeters;
        return $int(_updateInMeters);

      case 'update':
        final _update = $value.update;
        return _update == null
            ? const $null()
            : $Function((runtime, target, args) {
                final funcResult = _update(args[0]!.$value);
                return $Future.wrap(funcResult.then((e) => $Object(e)));
              });
      case 'buildLayer':
        return __buildLayer;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __buildLayer = $Function(_buildLayer);
  static $Value? _buildLayer(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ExtOverlay;
    final result = self.$value.buildLayer(reset: args[0]?.$value ?? false);
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
