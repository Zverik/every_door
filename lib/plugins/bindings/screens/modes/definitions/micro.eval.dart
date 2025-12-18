// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/legend.eval.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:every_door/plugins/bindings/helpers/tags/element_kind.eval.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:every_door/plugins/bindings/models/imagery.eval.dart';
import 'package:every_door/plugins/bindings/models/plugin.eval.dart';
import 'package:every_door/plugins/bindings/widgets/map_button.eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

import 'base.eval.dart';

/// dart_eval bridge binding for [MicromappingModeDefinition]
class $MicromappingModeDefinition$bridge extends MicromappingModeDefinition
    with $Bridge<MicromappingModeDefinition> {
  /// Forwarded constructor for [MicromappingModeDefinition.new]
  $MicromappingModeDefinition$bridge.fromPlugin(super.app): super.fromPlugin();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/screens/modes/definitions/micro.dart',
      'MicromappingModeDefinition.kMicroStuffInList*g',
      $MicromappingModeDefinition$bridge.$kMicroStuffInList,
    );
  }

  /// Compile-time type specification of [$MicromappingModeDefinition$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/modes/definitions/micro.dart',
    'MicromappingModeDefinition',
  );

  /// Compile-time type declaration of [$MicromappingModeDefinition$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MicromappingModeDefinition]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type,
        isAbstract: true, $extends: $BaseModeDefinition.$type),
    constructors: {
      'fromPlugin': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'app',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/plugins/interface.dart',
                    'EveryDoorApp',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'getIcon': BridgeMethodDef(
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
              'outlined',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
      ),

      'isOurKind': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'element',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/amenity.dart',
                    'OsmChange',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'addMapButton': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'button',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/widgets/map_button.dart',
                    'MapButton',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'removeMapButton': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'addOverlay': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'imagery',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/imagery.dart',
                    'Imagery',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'getNearestChanges': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/amenity.dart',
                        'OsmChange',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'maxCount',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              true,
            ),

            BridgeParameter(
              'filter',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'bounds',
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
        ),
      ),

      'updateNearest': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'bounds',
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
        ),
      ),

      'updateFromJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'plugin',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/plugin.dart',
                    'Plugin',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'parseKinds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/element_kind.dart',
                    'ElementKindImpl',
                  ),
                  [],
                ),
              ),
            ]),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              false,
            ),
          ],
        ),
      ),

      'mapLayers': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
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
          namedParams: [],
          params: [],
        ),
      ),

      'addListener': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'listener',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.voidType),
                    ),
                    params: [],
                    namedParams: [],
                  ),
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'removeListener': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'listener',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.voidType),
                    ),
                    params: [],
                    namedParams: [],
                  ),
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'dispose': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'notifyListeners': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'updateLegend': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
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

      'openEditor': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
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

            BridgeParameter(
              'location',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'buildMarker': BridgeMethodDef(
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
              'index',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              false,
            ),

            BridgeParameter(
              'element',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/amenity.dart',
                    'OsmChange',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'isZoomedIn',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'name': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'overlays': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.iterable, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/imagery.dart',
                    'Imagery',
                  ),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'buttons': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.iterable, [
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
          namedParams: [],
          params: [],
        ),
      ),

      'hasListeners': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'kMicroStuffInList': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
        isStatic: true,
      ),

      'nearestPOI': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/amenity.dart',
                  'OsmChange',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'otherPOI': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'enableZoomingIn': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'legend': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/legend.dart',
              'LegendController',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: false,
    bridge: true,
  );

  /// Wrapper for the [MicromappingModeDefinition.kMicroStuffInList] getter
  static $Value? $kMicroStuffInList(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = MicromappingModeDefinition.kMicroStuffInList;
    return $int(value);
  }

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'nearestPOI':
        final _nearestPOI = super.nearestPOI;
        return $List.view(_nearestPOI, (e) => $OsmChange.wrap(e));

      case 'otherPOI':
        final _otherPOI = super.otherPOI;
        return $List.view(_otherPOI, (e) => $LatLng.wrap(e));

      case 'enableZoomingIn':
        final _enableZoomingIn = super.enableZoomingIn;
        return $bool(_enableZoomingIn);

      case 'legend':
        final _legend = super.legend;
        return $LegendController.wrap(_legend);
      case 'getIcon':
        return $Function((runtime, target, args) {
          final result = super.getIcon(args[1]!.$value, args[2]!.$value);
          return $MultiIcon.wrap(result);
        });
      case 'isOurKind':
        return $Function((runtime, target, args) {
          final result = super.isOurKind(args[1]!.$value);
          return $bool(result);
        });
      case 'addMapButton':
        return $Function((runtime, target, args) {
          super.addMapButton(args[1]!.$value);
          return null;
        });
      case 'removeMapButton':
        return $Function((runtime, target, args) {
          super.removeMapButton(args[1]!.$value);
          return null;
        });
      case 'addOverlay':
        return $Function((runtime, target, args) {
          super.addOverlay(args[1]!.$value);
          return null;
        });
      case 'getNearestChanges':
        return $Function((runtime, target, args) {
          final result = super.getNearestChanges(
            args[1]!.$value,
            maxCount: args[2]?.$value ?? 200,
            filter: args[3]?.$value ?? true,
          );
          return $Future.wrap(
            result.then((e) => $List.view(e, (e) => $OsmChange.wrap(e))),
          );
        });
      case 'updateNearest':
        return $Function((runtime, target, args) {
          final result = super.updateNearest(args[1]!.$value);
          return $Future.wrap(result.then((e) => null));
        });
      case 'updateFromJson':
        return $Function((runtime, target, args) {
          super.updateFromJson(
            (args[1]!.$reified as Map).cast(),
            args[2]!.$value,
          );
          return null;
        });
      case 'parseKinds':
        return $Function((runtime, target, args) {
          final result = super.parseKinds(args[1]!.$value);
          return result == null
              ? const $null()
              : $List.view(result, (e) => $ElementKindImpl.wrap(e));
        });
      case 'mapLayers':
        return $Function((runtime, target, args) {
          final result = super.mapLayers();
          return $List.view(result, (e) => $Widget.wrap(e));
        });
      case 'addListener':
        return $Function((runtime, target, args) {
          super.addListener(() {
            (args[1]! as EvalCallable)(runtime, null, []);
          });
          return null;
        });
      case 'removeListener':
        return $Function((runtime, target, args) {
          super.removeListener(() {
            (args[1]! as EvalCallable)(runtime, null, []);
          });
          return null;
        });
      case 'notifyListeners':
        return $Function((runtime, target, args) {
          super.notifyListeners();
          return null;
        });
      case 'updateLegend':
        return $Function((runtime, target, args) {
          super.updateLegend(args[1]!.$value);
          return null;
        });
      case 'openEditor':
        return $Function((runtime, target, args) {
          super.openEditor(args[1]!.$value, args[2]!.$value);
          return null;
        });
      case 'buildMarker':
        return $Function((runtime, target, args) {
          final result = super.buildMarker(
            args[1]!.$value,
            args[2]!.$value,
            args[3]!.$value,
          );
          return $Widget.wrap(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {
    switch (identifier) {
      case 'nearestPOI':
        final list = (value as $List).$reified;
        super.nearestPOI = list.cast();
        return;

      case 'otherPOI':
        final list = (value as $List).$reified;
        super.otherPOI = list.cast();
        return;

      case 'enableZoomingIn':
        super.enableZoomingIn = value.$reified;
        return;
    }
  }

  @override
  String get name => $_get('name');

  @override
  Iterable<Imagery> get overlays => $_get('overlays');

  @override
  Iterable<MapButton> get buttons => $_get('buttons');

  @override
  bool get hasListeners => $_get('hasListeners');

  @override
  Type get runtimeType => $_get('runtimeType');

  @override
  List<OsmChange> get nearestPOI => $_get('nearestPOI');

  @override
  List<LatLng> get otherPOI => $_get('otherPOI');

  @override
  bool get enableZoomingIn => $_get('enableZoomingIn');

  @override
  LegendController get legend => $_get('legend');

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) =>
      $_invoke('getIcon', [$BuildContext.wrap(context), $bool(outlined)]);

  @override
  bool isOurKind(OsmChange element) =>
      $_invoke('isOurKind', [$OsmChange.wrap(element)]);

  @override
  void addMapButton(MapButton button) =>
      $_invoke('addMapButton', [$MapButton.wrap(button)]);

  @override
  void removeMapButton(String id) => $_invoke('removeMapButton', [$String(id)]);

  @override
  void addOverlay(Imagery imagery) =>
      $_invoke('addOverlay', [$Imagery.wrap(imagery)]);

  @override
  Future<List<OsmChange>> getNearestChanges(
    LatLngBounds bounds, {
    int maxCount = 200,
    bool filter = true,
  }) => $_invoke('getNearestChanges', [
    $LatLngBounds.wrap(bounds),
    $int(maxCount),
    $bool(filter),
  ]);

  @override
  Future<void> updateNearest(LatLngBounds bounds) =>
      $_invoke('updateNearest', [$LatLngBounds.wrap(bounds)]);

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) =>
      $_invoke('updateFromJson', [$Map.wrap(data), $Plugin.wrap(plugin)]);

  @override
  List<ElementKindImpl>? parseKinds(dynamic data) =>
      ($_invoke('parseKinds', [$Object(data)]) as List?)?.cast();

  @override
  List<Widget> mapLayers() => ($_invoke('mapLayers', []) as List).cast();

  @override
  void addListener(void Function() listener) => $_invoke('addListener', [
    $Function((runtime, target, args) {
      listener();
      return const $null();
    }),
  ]);

  @override
  void removeListener(void Function() listener) => $_invoke('removeListener', [
    $Function((runtime, target, args) {
      listener();
      return const $null();
    }),
  ]);

  @override
  void notifyListeners() => $_invoke('notifyListeners', []);

  @override
  void updateLegend(BuildContext context) =>
      $_invoke('updateLegend', [$BuildContext.wrap(context)]);

  @override
  void openEditor(BuildContext context, LatLng location) => $_invoke(
    'openEditor',
    [$BuildContext.wrap(context), $LatLng.wrap(location)],
  );

  @override
  Widget buildMarker(int index, OsmChange element, bool isZoomedIn) => $_invoke(
    'buildMarker',
    [$int(index), $OsmChange.wrap(element), $bool(isZoomedIn)],
  );
}
