// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [CustomMapController]
class $CustomMapController implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/map.dart',
      'CustomMapController.',
      $CustomMapController.$new,
    );
  }

  /// Compile-time type specification of [$CustomMapController]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/map.dart',
    'CustomMapController',
  );

  /// Compile-time type declaration of [$CustomMapController]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$CustomMapController]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
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
      'setLocation': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [
            BridgeParameter(
              'location',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'zoom',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.double, []),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [],
        ),
      ),
      'zoomToFit': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'locations',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                      [],
                    ),
                  ),
                ]),
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
      'zoomListener': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              params: [
                BridgeParameter(
                  '',
                  BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.iterable, [
                      BridgeTypeAnnotation(
                        BridgeTypeRef(
                          BridgeTypeSpec(
                            'package:latlong2/latlong.dart',
                            'LatLng',
                          ),
                          [],
                        ),
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
        isStatic: false,
      ),
      'mapController': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:flutter_map/src/map/controller/map_controller.dart',
              'MapController',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [CustomMapController.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $CustomMapController.wrap(CustomMapController());
  }

  final $Instance _superclass;

  @override
  final CustomMapController $value;

  @override
  CustomMapController get $reified => $value;

  /// Wrap a [CustomMapController] in a [$CustomMapController]
  $CustomMapController.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'zoomListener':
        final _zoomListener = $value.zoomListener;
        return _zoomListener == null
            ? const $null()
            : $Function((runtime, target, args) {
                final funcResult = _zoomListener(args[0]!.$value);
                return $Object(funcResult);
              });

      case 'mapController':
        final _mapController = $value.mapController;
        return _mapController == null
            ? const $null()
            : $MapController.wrap(_mapController);

      case 'setLocation':
        return __setLocation;

      case 'zoomToFit':
        return __zoomToFit;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __setLocation = $Function(_setLocation);
  static $Value? _setLocation(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $CustomMapController;
    self.$value.setLocation(location: args[0]?.$value, zoom: args[1]?.$value);
    return null;
  }

  static const $Function __zoomToFit = $Function(_zoomToFit);
  static $Value? _zoomToFit(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $CustomMapController;
    self.$value.zoomToFit(args[0]!.$value);
    return null;
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [CustomMap]
class $CustomMap implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/map.dart',
      'CustomMap.',
      $CustomMap.$new,
    );
  }

  /// Compile-time type specification of [$CustomMap]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/map.dart',
    'CustomMap',
  );

  /// Compile-time type declaration of [$CustomMap]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$CustomMap]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,
      $extends: $StatefulWidget$bridge.$type,
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
              'onTap',
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
                              'package:latlong2/latlong.dart',
                              'LatLng',
                            ),
                            [],
                          ),
                        ),
                        false,
                      ),
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef.genericFunction(
                            BridgeFunctionDef(
                              returns: BridgeTypeAnnotation(
                                BridgeTypeRef(CoreTypes.double, []),
                              ),
                              params: [
                                BridgeParameter(
                                  '',
                                  BridgeTypeAnnotation(
                                    BridgeTypeRef(
                                      BridgeTypeSpec(
                                        'package:latlong2/latlong.dart',
                                        'LatLng',
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
                    ],
                    namedParams: [],
                  ),
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'controller',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/widgets/map.dart',
                    'CustomMapController',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'layers',
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
              ),
              true,
            ),
            BridgeParameter(
              'buttons',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/widgets/map_button.dart',
                        'MapButton',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              true,
            ),
            BridgeParameter(
              'drawZoomButtons',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'hasFloatingButton',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'drawStandardButtons',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'drawPinMarker',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'faintWalkPath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'interactive',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'track',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'onlyOSM',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'allowRotation',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'switchToNavigate',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'updateState',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },
    wrap: true,
  );

  /// Wrapper for the [CustomMap.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $CustomMap.wrap(
      CustomMap(
        key: args[0]?.$value,
        onTap: (LatLng arg0, double Function(LatLng arg0) arg1) {
          (args[1]! as EvalCallable?)?.call(runtime, null, [
            $LatLng.wrap(arg0),
            $Function((runtime, target, args) {
              final funcResult = arg1(args[0]!.$value);
              return $double(funcResult);
            }),
          ]);
        },
        controller: args[2]?.$value,
        layers: (args[3]?.$reified ?? const [] as List?)?.cast(),
        buttons: (args[4]?.$reified ?? const [] as List?)?.cast(),
        drawZoomButtons: args[5]?.$value ?? true,
        hasFloatingButton: args[6]?.$value ?? false,
        drawStandardButtons: args[7]?.$value ?? true,
        drawPinMarker: args[8]?.$value ?? true,
        faintWalkPath: args[9]?.$value ?? true,
        interactive: args[10]?.$value ?? true,
        track: args[11]?.$value ?? true,
        onlyOSM: args[12]?.$value ?? false,
        allowRotation: args[13]?.$value ?? true,
        switchToNavigate: args[14]?.$value ?? true,
        updateState: args[15]?.$value ?? false,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final CustomMap $value;

  @override
  CustomMap get $reified => $value;

  /// Wrap a [CustomMap] in a [$CustomMap]
  $CustomMap.wrap(this.$value) : _superclass = $Widget.wrap($value);

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
