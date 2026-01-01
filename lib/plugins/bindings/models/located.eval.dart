import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/located.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval bridge binding for [Located]
class $Located$bridge extends Located with $Bridge<Located> {
  /// Forwarded constructor for [Located.new]
  $Located$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$Located$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/located.dart',
    'Located',
  );

  /// Compile-time type declaration of [$Located$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Located]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
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

      'uniqueId': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isNew': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isModified': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isDeleted': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  LatLng get location => $_get('location');

  @override
  String get uniqueId => $_get('uniqueId');

  @override
  bool get isNew => $_get('isNew');

  @override
  bool get isModified => $_get('isModified');

  @override
  bool get isDeleted => $_get('isDeleted');
}

/// dart_eval wrapper binding for [Located]
class $Located implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/located.dart',
    'Located',
  );

  final $Instance _superclass;

  @override
  final Located $value;

  @override
  Located get $reified => $value;

  /// Wrap a [Located] in a [$Located]
  $Located.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'location':
        return $LatLng.wrap($value.location);

      case 'uniqueId':
        return $String($value.uniqueId);

      case 'isNew':
        return $bool($value.isNew);

      case 'isModified':
        return $bool($value.isModified);

      case 'isDeleted':
        return $bool($value.isDeleted);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
