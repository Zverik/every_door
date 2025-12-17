// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/providers.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [PluginProviders]
class $PluginProviders implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
  }

  /// Compile-time type specification of [$PluginProviders]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/providers.dart',
    'PluginProviders',
  );

  /// Compile-time type declaration of [$PluginProviders]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginProviders]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
    },

    methods: {},
    getters: {
      'location': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'isTracking': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'compass': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.double, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {
      'location': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
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

      'zoom': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
              false,
            ),
          ],
        ),
      ),
    },
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final PluginProviders $value;

  @override
  PluginProviders get $reified => $value;

  /// Wrap a [PluginProviders] in a [$PluginProviders]
  $PluginProviders.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'location':
        final _location = $value.location;
        return $LatLng.wrap(_location);

      case 'isTracking':
        final _isTracking = $value.isTracking;
        return $bool(_isTracking);

      case 'compass':
        final _compass = $value.compass;
        return _compass == null ? const $null() : $double(_compass);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'location':
        $value.location = value.$value;
        return;

      case 'zoom':
        $value.zoom = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
