// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';
import 'package:every_door/plugins/bindings/widgets/map_button.eval.dart';

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

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter_riverpod/src/consumer.dart',
          'ConsumerStatefulWidget',
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

    methods: {
      'createState': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_riverpod/src/consumer.dart',
                'ConsumerState',
              ),
              [
                BridgeTypeAnnotation(
                  BridgeTypeRef(
                    BridgeTypeSpec(
                      'package:flutter_riverpod/src/consumer.dart',
                      'ConsumerStatefulWidget',
                    ),
                    [],
                  ),
                ),
              ],
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
      'onTap': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
              params: [
                BridgeParameter(
                  '',
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
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
        isStatic: false,
      ),

      'controller': BridgeFieldDef(
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
        isStatic: false,
      ),

      'layers': BridgeFieldDef(
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
        isStatic: false,
      ),

      'buttons': BridgeFieldDef(
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
        isStatic: false,
      ),

      'drawZoomButtons': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'hasFloatingButton': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'drawStandardButtons': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'drawPinMarker': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'faintWalkPath': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'interactive': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'track': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'onlyOSM': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'allowRotation': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'updateState': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'switchToNavigate': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
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
  $CustomMap.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'onTap':
        final _onTap = $value.onTap;
        return _onTap == null
            ? const $null()
            : $Function((runtime, target, args) {
                _onTap(args[0]!.$value, args[1]!.$value);
                return const $null();
              });

      case 'controller':
        final _controller = $value.controller;
        return _controller == null
            ? const $null()
            : $CustomMapController.wrap(_controller);

      case 'layers':
        final _layers = $value.layers;
        return $List.view(_layers, (e) => $Widget.wrap(e));

      case 'buttons':
        final _buttons = $value.buttons;
        return $List.view(_buttons, (e) => $MapButton.wrap(e));

      case 'drawZoomButtons':
        final _drawZoomButtons = $value.drawZoomButtons;
        return $bool(_drawZoomButtons);

      case 'hasFloatingButton':
        final _hasFloatingButton = $value.hasFloatingButton;
        return $bool(_hasFloatingButton);

      case 'drawStandardButtons':
        final _drawStandardButtons = $value.drawStandardButtons;
        return $bool(_drawStandardButtons);

      case 'drawPinMarker':
        final _drawPinMarker = $value.drawPinMarker;
        return $bool(_drawPinMarker);

      case 'faintWalkPath':
        final _faintWalkPath = $value.faintWalkPath;
        return $bool(_faintWalkPath);

      case 'interactive':
        final _interactive = $value.interactive;
        return $bool(_interactive);

      case 'track':
        final _track = $value.track;
        return $bool(_track);

      case 'onlyOSM':
        final _onlyOSM = $value.onlyOSM;
        return $bool(_onlyOSM);

      case 'allowRotation':
        final _allowRotation = $value.allowRotation;
        return $bool(_allowRotation);

      case 'updateState':
        final _updateState = $value.updateState;
        return $bool(_updateState);

      case 'switchToNavigate':
        final _switchToNavigate = $value.switchToNavigate;
        return $bool(_switchToNavigate);
      case 'createState':
        return __createState;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __createState = $Function(_createState);
  static $Value? _createState(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $CustomMap;
    final result = self.$value.createState();
    return runtime.wrapAlways(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
