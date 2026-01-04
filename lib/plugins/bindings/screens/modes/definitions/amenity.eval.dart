// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/bindings/screens/modes/definitions/base.eval.dart';
import 'package:every_door/screens/modes/definitions/amenity.dart';
import 'package:every_door/helpers/amenity_age.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/plugins/bindings/helpers/poi_describer.eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:every_door/plugins/bindings/helpers/amenity_age.eval.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';
import 'package:every_door/plugins/bindings/models/plugin.eval.dart';

/// dart_eval bridge binding for [AmenityModeDefinition]
class $AmenityModeDefinition$bridge extends AmenityModeDefinition
    with $Bridge<AmenityModeDefinition> {
  /// Forwarded constructor for [AmenityModeDefinition.new]
  $AmenityModeDefinition$bridge.fromPlugin(super.app) : super.fromPlugin();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$AmenityModeDefinition$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/modes/definitions/amenity.dart',
    'AmenityModeDefinition',
  );

  /// Compile-time type declaration of [$AmenityModeDefinition$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AmenityModeDefinition]
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
              'active',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
      'openEditor': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
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
              ),
              false,
            ),
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
                nullable: true,
              ),
              true,
            ),
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
          ],
          params: [],
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
      'readKindsFromJson': BridgeMethodDef(
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
          ],
        ),
      ),
      'getOtherObjectColor': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'object',
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
      'getAmenityData': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/amenity_age.dart',
                'AmenityAgeData',
              ),
              [],
            ),
            nullable: true,
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
      'maxTileCount': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'describer': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/poi_describer.dart',
              'PoiDescriber',
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

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'describer':
        final _describer = super.describer;
        return $PoiDescriber.wrap(_describer);

      case 'maxTileCount':
        final _maxTileCount = super.maxTileCount;
        return $int(_maxTileCount);
      case 'getIcon':
        return $Function((runtime, target, args) {
          final result = super.getIcon(args[1]!.$value, args[2]!.$value);
          return $MultiIcon.wrap(result);
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
      case 'openEditor':
        return $Function((runtime, target, args) {
          final result = super.openEditor(
            context: args[1]!.$value,
            element: args[2]?.$value,
            location: args[3]?.$value,
          );
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
      case 'readKindsFromJson':
        return $Function((runtime, target, args) {
          super.readKindsFromJson((args[1]!.$reified as Map).cast());
          return null;
        });
      case 'getOtherObjectColor':
        return $Function((runtime, target, args) {
          final result = super.getOtherObjectColor(args[1]!.$value);
          return $Color.wrap(result);
        });
      case 'otherObjectsLayer':
        return $Function((runtime, target, args) {
          final result = super.otherObjectsLayer();
          return $Widget.wrap(result);
        });
      case 'mapLayers':
        return $Function((runtime, target, args) {
          final result = super.mapLayers();
          return $List.view(result, (e) => $Widget.wrap(e));
        });
      case 'buildMarker':
        return $Function((runtime, target, args) {
          final result = super.buildMarker(args[1]!.$value, args[2]!.$value);
          return $Widget.wrap(result);
        });
      case 'getAmenityData':
        return $Function((runtime, target, args) {
          final result = super.getAmenityData(args[1]!.$value);
          return result == null ? const $null() : $AmenityAgeData.wrap(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  String get name => $_get('name');

  @override
  PoiDescriber get describer => $_get('describer');

  @override
  int get maxTileCount => $_get('maxTileCount');

  @override
  MultiIcon getIcon(BuildContext context, bool active) =>
      $_invoke('getIcon', [$BuildContext.wrap(context), $bool(active)]);

  @override
  Future<void> updateNearest(LatLngBounds bounds) =>
      $_invoke('updateNearest', [$LatLngBounds.wrap(bounds)]);

  @override
  Future<void> openEditor({
    required BuildContext context,
    Located? element,
    LatLng? location,
  }) =>
      $_invoke('openEditor', [
        $BuildContext.wrap(context),
        element == null ? const $null() : $Located.wrap(element),
        location == null ? const $null() : $LatLng.wrap(location),
      ]);

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) =>
      $_invoke('updateFromJson', [$Map.wrap(data), $Plugin.wrap(plugin)]);

  @override
  Color getOtherObjectColor(Located object) =>
      $_invoke('getOtherObjectColor', [$Located.wrap(object)]);

  @override
  List<Widget> mapLayers() => ($_invoke('mapLayers', []) as List).cast();

  @override
  Widget buildMarker(int index, Located element) =>
      $_invoke('buildMarker', [$int(index), $Located.wrap(element)]);

  @override
  AmenityAgeData? getAmenityData(Located element) =>
      $_invoke('getAmenityData', [$Located.wrap(element)]);
}
