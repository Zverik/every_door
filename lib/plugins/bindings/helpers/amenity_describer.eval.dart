import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/amenity_describer.dart';
import 'package:every_door/models/amenity.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:flutter_eval/painting.dart';

/// dart_eval bridge binding for [AmenityIndicator]
class $AmenityIndicator$bridge extends AmenityIndicator
    with $Bridge<AmenityIndicator> {
  /// Forwarded constructor for [AmenityIndicator.new]
  $AmenityIndicator$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$AmenityIndicator$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/amenity_describer.dart',
    'AmenityIndicator',
  );

  /// Compile-time type declaration of [$AmenityIndicator$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AmenityIndicator]
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

    methods: {
      'applies': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
          ],
        ),
      ),

      'whenMissing': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
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
          ],
        ),
      ),

      'whenPresent': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
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
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'applies':
        return $Function((runtime, target, args) {
          final result = super.applies(args[1]!.$value);
          return $bool(result);
        });
      case 'whenMissing':
        return $Function((runtime, target, args) {
          final result = super.whenMissing(args[1]!.$value);
          return result == null ? const $null() : $String(result);
        });
      case 'whenPresent':
        return $Function((runtime, target, args) {
          final result = super.whenPresent(args[1]!.$value);
          return result == null ? const $null() : $String(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  bool applies(OsmChange amenity) =>
      $_invoke('applies', [$OsmChange.wrap(amenity)]);

  @override
  String? whenMissing(OsmChange amenity) =>
      $_invoke('whenMissing', [$OsmChange.wrap(amenity)]);

  @override
  String? whenPresent(OsmChange amenity) =>
      $_invoke('whenPresent', [$OsmChange.wrap(amenity)]);
}

/// dart_eval wrapper binding for [AmenityIndicator]
class $AmenityIndicator implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/amenity_describer.dart',
    'AmenityIndicator',
  );

  final $Instance _superclass;

  @override
  final AmenityIndicator $value;

  @override
  AmenityIndicator get $reified => $value;

  /// Wrap a [AmenityIndicator] in a [$AmenityIndicator]
  $AmenityIndicator.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'applies':
        return __applies;

      case 'whenMissing':
        return __whenMissing;

      case 'whenPresent':
        return __whenPresent;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __applies = $Function(_applies);
  static $Value? _applies(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AmenityIndicator;
    final result = self.$value.applies(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __whenMissing = $Function(_whenMissing);
  static $Value? _whenMissing(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AmenityIndicator;
    final result = self.$value.whenMissing(args[0]!.$value);
    return result == null ? const $null() : $String(result);
  }

  static const $Function __whenPresent = $Function(_whenPresent);
  static $Value? _whenPresent(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AmenityIndicator;
    final result = self.$value.whenPresent(args[0]!.$value);
    return result == null ? const $null() : $String(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [AmenityDescriber]
class $AmenityDescriber implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/amenity_describer.dart',
      'AmenityDescriber.',
      $AmenityDescriber.$new,
    );
  }

  /// Compile-time type specification of [$AmenityDescriber]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/amenity_describer.dart',
    'AmenityDescriber',
  );

  /// Compile-time type declaration of [$AmenityDescriber]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AmenityDescriber]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $implements: [
        BridgeTypeRef(
          BridgeTypeSpec(
            'package:every_door/helpers/poi_describer.dart',
            'PoiDescriber',
          ),
          [],
        ),
      ],
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              '_ref',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:riverpod/src/framework.dart', 'Ref'),
                  [
                    BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.object, []),
                      nullable: true,
                    ),
                  ],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'indicators',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/amenity_describer.dart',
                        'AmenityIndicator',
                      ),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'describe': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/painting/text_span.dart',
                'TextSpan',
              ),
              [],
            ),
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
    getters: {},
    setters: {},
    fields: {
      'indicators': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/amenity_describer.dart',
                  'AmenityIndicator',
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

  /// Wrapper for the [AmenityDescriber.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $AmenityDescriber.wrap(
      AmenityDescriber(args[0]!.$value, (args[1]?.$reified as Map?)?.cast()),
    );
  }

  final $Instance _superclass;

  @override
  final AmenityDescriber $value;

  @override
  AmenityDescriber get $reified => $value;

  /// Wrap a [AmenityDescriber] in a [$AmenityDescriber]
  $AmenityDescriber.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'indicators':
        return $Map.wrap($value.indicators);
      case 'describe':
        return __describe;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __describe = $Function(_describe);
  static $Value? _describe(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AmenityDescriber;
    final result = self.$value.describe(args[0]!.$value);
    return $TextSpan.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
