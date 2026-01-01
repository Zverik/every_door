// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_eval/foundation.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:every_door/plugins/bindings/helpers/tags/element_kind.eval.dart';
import 'package:flutter_eval/ui.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [BaseModeDefinition]
class $BaseModeDefinition implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$BaseModeDefinition]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/modes/definitions/base.dart',
    'BaseModeDefinition',
  );

  /// Compile-time type declaration of [$BaseModeDefinition]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$BaseModeDefinition]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,
      isAbstract: true,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter/src/foundation/change_notifier.dart',
          'ChangeNotifier',
        ),
        [],
      ),
    ),
    constructors: {
      'fromPlugin': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'plugin',
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

      'otherObjectsLayer': BridgeMethodDef(
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
          params: [],
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
    },
    setters: {},
    fields: {
      'nearest': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/located.dart',
                  'Located',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'other': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/located.dart',
                  'Located',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'ourKinds': BridgeFieldDef(
        BridgeTypeAnnotation(
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
        ),
        isStatic: false,
      ),

      'otherKinds': BridgeFieldDef(
        BridgeTypeAnnotation(
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
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final BaseModeDefinition $value;

  @override
  BaseModeDefinition get $reified => $value;

  /// Wrap a [BaseModeDefinition] in a [$BaseModeDefinition]
  $BaseModeDefinition.wrap(this.$value)
    : _superclass = $ChangeNotifier.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'nearest':
        final _nearest = $value.nearest;
        return $List.view(_nearest, (e) => $Located.wrap(e));

      case 'other':
        final _other = $value.other;
        return $List.view(_other, (e) => $Located.wrap(e));

      case 'ourKinds':
        final _ourKinds = $value.ourKinds;
        return $List.view(_ourKinds, (e) => $ElementKindImpl.wrap(e));

      case 'otherKinds':
        final _otherKinds = $value.otherKinds;
        return $List.view(_otherKinds, (e) => $ElementKindImpl.wrap(e));

      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'overlays':
        final _overlays = $value.overlays;
        return $Iterable.wrap(_overlays);

      case 'buttons':
        final _buttons = $value.buttons;
        return $Iterable.wrap(_buttons);
      case 'getIcon':
        return __getIcon;

      case 'addMapButton':
        return __addMapButton;

      case 'removeMapButton':
        return __removeMapButton;

      case 'addOverlay':
        return __addOverlay;

      case 'getNearestChanges':
        return __getNearestChanges;

      case 'updateNearest':
        return __updateNearest;

      case 'openEditor':
        return __openEditor;

      case 'updateFromJson':
        return __updateFromJson;

      case 'readKindsFromJson':
        return __readKindsFromJson;

      case 'getOtherObjectColor':
        return __getOtherObjectColor;

      case 'otherObjectsLayer':
        return __otherObjectsLayer;

      case 'mapLayers':
        return __mapLayers;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __getIcon = $Function(_getIcon);
  static $Value? _getIcon(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.getIcon(args[0]!.$value, args[1]!.$value);
    return $MultiIcon.wrap(result);
  }

  static const $Function __addMapButton = $Function(_addMapButton);
  static $Value? _addMapButton(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    self.$value.addMapButton(args[0]!.$value);
    return null;
  }

  static const $Function __removeMapButton = $Function(_removeMapButton);
  static $Value? _removeMapButton(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    self.$value.removeMapButton(args[0]!.$value);
    return null;
  }

  static const $Function __addOverlay = $Function(_addOverlay);
  static $Value? _addOverlay(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    self.$value.addOverlay(args[0]!.$value);
    return null;
  }

  static const $Function __getNearestChanges = $Function(_getNearestChanges);
  static $Value? _getNearestChanges(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.getNearestChanges(
      args[0]!.$value,
      maxCount: args[1]?.$value ?? 200,
    );
    return $Future.wrap(
      result.then((e) => $List.view(e, (e) => $OsmChange.wrap(e))),
    );
  }

  static const $Function __updateNearest = $Function(_updateNearest);
  static $Value? _updateNearest(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.updateNearest(args[0]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __openEditor = $Function(_openEditor);
  static $Value? _openEditor(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.openEditor(
      context: args[0]!.$value,
      element: args[1]?.$value,
      location: args[2]?.$value,
    );
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __updateFromJson = $Function(_updateFromJson);
  static $Value? _updateFromJson(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    self.$value.updateFromJson(
      (args[0]!.$reified as Map).cast(),
      args[1]!.$value,
    );
    return null;
  }

  static const $Function __readKindsFromJson = $Function(_readKindsFromJson);
  static $Value? _readKindsFromJson(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    self.$value.readKindsFromJson((args[0]!.$reified as Map).cast());
    return null;
  }

  static const $Function __getOtherObjectColor = $Function(
    _getOtherObjectColor,
  );
  static $Value? _getOtherObjectColor(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.getOtherObjectColor(args[0]!.$value);
    return $Color.wrap(result);
  }

  static const $Function __otherObjectsLayer = $Function(_otherObjectsLayer);
  static $Value? _otherObjectsLayer(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.otherObjectsLayer();
    return $Widget.wrap(result);
  }

  static const $Function __mapLayers = $Function(_mapLayers);
  static $Value? _mapLayers(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $BaseModeDefinition;
    final result = self.$value.mapLayers();
    return $List.view(result, (e) => $Widget.wrap(e));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'nearest':
        $value.nearest = value.$value;
        return;

      case 'other':
        $value.other = value.$value;
        return;

      case 'ourKinds':
        $value.ourKinds = value.$value;
        return;

      case 'otherKinds':
        $value.otherKinds = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
