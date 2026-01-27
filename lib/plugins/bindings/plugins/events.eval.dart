// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:ui' show Locale;

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/editor_fields.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/plugins/bindings/helpers/editor_fields.eval.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:every_door/plugins/bindings/models/preset.eval.dart';
import 'package:every_door/plugins/events.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_eval/ui.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/screens/modes/definitions/base.eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [PluginEvents]
class $PluginEvents implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
  }

  /// Compile-time type specification of [$PluginEvents]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/events.dart',
    'PluginEvents',
  );

  /// Compile-time type declaration of [$PluginEvents]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginEvents]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
    },

    methods: {
      'onModeCreated': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'callback',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.dynamic),
                    ),
                    params: [
                      BridgeParameter(
                        'mode',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(
                            BridgeTypeSpec(
                              'package:every_door/screens/modes/definitions/base.dart',
                              'BaseModeDefinition',
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
        ),
      ),

      'onUpload': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'callback',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.dynamic),
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

      'onDownload': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'callback',
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
        ),
      ),

      'onEditorFields': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'callback',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.future, [
                        BridgeTypeAnnotation(
                          BridgeTypeRef(CoreTypes.list, [
                            BridgeTypeAnnotation(
                              BridgeTypeRef(
                                BridgeTypeSpec(
                                  'package:every_door/helpers/editor_fields.dart',
                                  'EditorFields',
                                ),
                                [],
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                    params: [
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(CoreTypes.list, [
                            BridgeTypeAnnotation(
                              BridgeTypeRef(
                                BridgeTypeSpec(
                                  'package:every_door/helpers/editor_fields.dart',
                                  'EditorFields',
                                ),
                                [],
                              ),
                            ),
                          ]),
                        ),
                        false,
                      ),

                      BridgeParameter(
                        '',
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
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(
                            BridgeTypeSpec(
                              'package:every_door/models/preset.dart',
                              'Preset',
                            ),
                            [],
                          ),
                        ),
                        false,
                      ),

                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(
                            BridgeTypeSpec('dart:ui', 'Locale'),
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
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final PluginEvents $value;

  @override
  PluginEvents get $reified => $value;

  /// Wrap a [PluginEvents] in a [$PluginEvents]
  $PluginEvents.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'onModeCreated':
        return __onModeCreated;

      case 'onUpload':
        return __onUpload;

      case 'onDownload':
        return __onDownload;

      case 'onEditorFields':
        return __onEditorFields;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __onModeCreated = $Function(_onModeCreated);
  static $Value? _onModeCreated(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginEvents;
    self.$value.onModeCreated((BaseModeDefinition mode) {
      return (args[0]! as EvalCallable)(runtime, null, [
        $BaseModeDefinition.wrap(mode),
      ])?.$value;
    });
    return null;
  }

  static const $Function __onUpload = $Function(_onUpload);
  static $Value? _onUpload(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginEvents;
    self.$value.onUpload(() {
      return (args[0]! as EvalCallable)(runtime, null, [])?.$value;
    });
    return null;
  }

  static const $Function __onDownload = $Function(_onDownload);
  static $Value? _onDownload(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginEvents;
    self.$value.onDownload((LatLng arg0) {
      return (args[0]! as EvalCallable)(runtime, null, [
        $LatLng.wrap(arg0),
      ])?.$value;
    });
    return null;
  }

  static const $Function __onEditorFields = $Function(_onEditorFields);
  static $Value? _onEditorFields(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginEvents;
    self.$value.onEditorFields((
      List<EditorFields> arg0,
      OsmChange arg1,
      Preset arg2,
      Locale arg3,
    ) async {
      final future = (args[0]! as EvalCallable)(runtime, null, [
        // $List.view(arg0, (e) => $EditorFields.wrap(e)),
        $List.wrap(arg0.map((ef) => $EditorFields.wrap(ef)).toList()),
        $OsmChange.wrap(arg1),
        $Preset.wrap(arg2),
        $Locale.wrap(arg3),
      ]);
      final value = await future!.$value;
      return (value?.$reified as List<dynamic>).cast();
    });
    return null;
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
