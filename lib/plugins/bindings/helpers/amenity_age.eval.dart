import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/amenity_age.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [AmenityAgeData]
class $AmenityAgeData implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/amenity_age.dart',
      'AmenityAgeData.',
      $AmenityAgeData.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/amenity_age.dart',
      'AmenityAgeData.from',
      $AmenityAgeData.$from,
    );
  }

  /// Compile-time type specification of [$AmenityAgeData]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/amenity_age.dart',
    'AmenityAgeData',
  );

  /// Compile-time type declaration of [$AmenityAgeData]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AmenityAgeData]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'isDisused',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'showWarning',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'isOld',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.bool, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'wasOld',
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
      'from': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/amenity_age.dart',
                'AmenityAgeData',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'amenity',
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
              'checkIntervals',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                ]),
              ),
              false,
            ),
          ],
        ),

        isStatic: true,
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'isDisused': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'showWarning': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'isOld': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, []), nullable: true),
        isStatic: false,
      ),

      'wasOld': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [AmenityAgeData.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $AmenityAgeData.wrap(
      AmenityAgeData(
        isDisused: args[0]?.$value ?? false,
        showWarning: args[1]?.$value ?? false,
        isOld: args[2]?.$value,
        wasOld: args[3]?.$value ?? false,
      ),
    );
  }

  /// Wrapper for the [AmenityAgeData.from] method
  static $Value? $from(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = AmenityAgeData.from(
      args[0]!.$value,
      (args[1]!.$reified as Map).cast(),
    );
    return $AmenityAgeData.wrap(value);
  }

  final $Instance _superclass;

  @override
  final AmenityAgeData $value;

  @override
  AmenityAgeData get $reified => $value;

  /// Wrap a [AmenityAgeData] in a [$AmenityAgeData]
  $AmenityAgeData.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'isDisused':
        return $bool($value.isDisused);

      case 'showWarning':
        return $bool($value.showWarning);

      case 'isOld':
        final _isOld = $value.isOld;
        return _isOld == null ? const $null() : $bool(_isOld);

      case 'wasOld':
        return $bool($value.wasOld);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
