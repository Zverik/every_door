import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/bindings/screens/modes/definitions/base.eval.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/legend.eval.dart';
import 'package:every_door/plugins/bindings/helpers/poi_describer.eval.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';
import 'package:every_door/plugins/bindings/models/plugin.eval.dart';

/// dart_eval bridge binding for [MicromappingModeDefinition]
class $MicromappingModeDefinition$bridge extends MicromappingModeDefinition
    with $Bridge<MicromappingModeDefinition> {
  /// Forwarded constructor for [MicromappingModeDefinition.fromPlugin]
  $MicromappingModeDefinition$bridge.fromPlugin(super.app);

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

      'getPreset': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/legend.dart',
                    'PresetLabel',
                  ),
                  [],
                ),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'change',
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

            BridgeParameter(
              'locale',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Locale'), []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'updateLegend': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'locale',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Locale'), []),
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
                    'package:every_door/models/located.dart',
                    'Located',
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
    },
    setters: {},
    fields: {
      'kMicroStuffInList': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
        isStatic: true,
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
      case 'enableZoomingIn':
        return $bool(super.enableZoomingIn);

      case 'legend':
        return $LegendController.wrap(super.legend);

      case 'describer':
        return $PoiDescriber.wrap(super.describer);
      case 'getIcon':
        return $Function((runtime, target, args) {
          final result = super.getIcon(args[1]!.$value, args[2]!.$value);
          return $MultiIcon.wrap(result);
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
      case 'getOtherObjectColor':
        return $Function((runtime, target, args) {
          final result = super.getOtherObjectColor(args[1]!.$value);
          return $Color.wrap(result);
        });
      case 'mapLayers':
        return $Function((runtime, target, args) {
          final result = super.mapLayers();
          return $List.view(result, (e) => $Widget.wrap(e));
        });
      case 'getPreset':
        return $Function((runtime, target, args) {
          final result = super.getPreset(args[1]!.$value, args[2]!.$value);
          return $Future.wrap(
            result.then(
              (e) => e == null ? const $null() : $PresetLabel.wrap(e),
            ),
          );
        });
      case 'updateLegend':
        return $Function((runtime, target, args) {
          super.updateLegend(args[1]!.$value);
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
      case 'enableZoomingIn':
        super.enableZoomingIn = value.$value;
        return;

      case 'legend':
        super.legend = value.$value;
        return;
    }
  }

  @override
  String get name => $_get('name');

  @override
  bool get enableZoomingIn => $_get('enableZoomingIn');

  @override
  LegendController get legend => $_get('legend');

  @override
  PoiDescriber get describer => $_get('describer');

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) =>
      $_invoke('getIcon', [$BuildContext.wrap(context), $bool(outlined)]);

  @override
  Future<void> updateNearest(LatLngBounds bounds) =>
      $_invoke('updateNearest', [$LatLngBounds.wrap(bounds)]);

  @override
  Future<void> openEditor({
    required BuildContext context,
    Located? element,
    LatLng? location,
  }) => $_invoke('openEditor', [
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
  Future<PresetLabel?> getPreset(Located change, Locale? locale) =>
      $_invoke('getPreset', [
        $Located.wrap(change),
        locale == null ? const $null() : $Locale.wrap(locale),
      ]);

  @override
  void updateLegend(Locale locale) =>
      $_invoke('updateLegend', [$Locale.wrap(locale)]);

  @override
  Widget buildMarker(int index, Located element, bool isZoomedIn) => $_invoke(
    'buildMarker',
    [$int(index), $Located.wrap(element), $bool(isZoomedIn)],
  );
}
