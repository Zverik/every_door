// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/widgets/entrance_markers.dart';
import 'package:flutter/material.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_eval/painting.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';

/// dart_eval wrapper binding for [SizedMarker]
class $SizedMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/entrance_markers.dart',
      'SizedMarker.',
      $SizedMarker.$new,
    );
  }

  /// Compile-time type specification of [$SizedMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/entrance_markers.dart',
    'SizedMarker',
  );

  /// Compile-time type declaration of [$SizedMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SizedMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'child',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'Widget',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'width',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
              false,
            ),

            BridgeParameter(
              'height',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
              false,
            ),

            BridgeParameter(
              'rotate',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'alignment',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/painting/alignment.dart',
                    'Alignment',
                  ),
                  [],
                ),
              ),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'buildMarker': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/layer/marker_layer/marker_layer.dart',
                'Marker',
              ),
              [],
            ),
          ),
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
              'point',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'child': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:flutter/src/widgets/framework.dart',
              'Widget',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'width': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
        isStatic: false,
      ),

      'height': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
        isStatic: false,
      ),

      'rotate': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'alignment': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:flutter/src/painting/alignment.dart',
              'Alignment',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [SizedMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $SizedMarker.wrap(
      SizedMarker(
        child: args[0]!.$value,
        width: args[1]!.$value,
        height: args[2]!.$value,
        rotate: args[3]?.$value ?? false,
        alignment: args[4]?.$value ?? Alignment.center,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final SizedMarker $value;

  @override
  SizedMarker get $reified => $value;

  /// Wrap a [SizedMarker] in a [$SizedMarker]
  $SizedMarker.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'child':
        final _child = $value.child;
        return $Widget.wrap(_child);

      case 'width':
        final _width = $value.width;
        return $double(_width);

      case 'height':
        final _height = $value.height;
        return $double(_height);

      case 'rotate':
        final _rotate = $value.rotate;
        return $bool(_rotate);

      case 'alignment':
        final _alignment = $value.alignment;
        return $Alignment.wrap(_alignment);
      case 'buildMarker':
        return __buildMarker;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __buildMarker = $Function(_buildMarker);
  static $Value? _buildMarker(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $SizedMarker;
    final result = self.$value.buildMarker(
      key: args[0]?.$value,
      point: args[1]!.$value,
    );
    return $Marker.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [BuildingMarker]
class $BuildingMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/entrance_markers.dart',
      'BuildingMarker.',
      $BuildingMarker.$new,
    );
  }

  /// Compile-time type specification of [$BuildingMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/entrance_markers.dart',
    'BuildingMarker',
  );

  /// Compile-time type declaration of [$BuildingMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$BuildingMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/widgets/entrance_markers.dart',
          'SizedMarker',
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
              'isComplete',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'label',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [BuildingMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $BuildingMarker.wrap(
      BuildingMarker(
        isComplete: args[0]?.$value ?? false,
        label: args[1]!.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final BuildingMarker $value;

  @override
  BuildingMarker get $reified => $value;

  /// Wrap a [BuildingMarker] in a [$BuildingMarker]
  $BuildingMarker.wrap(this.$value) : _superclass = $SizedMarker.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [AddressMarker]
class $AddressMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/entrance_markers.dart',
      'AddressMarker.',
      $AddressMarker.$new,
    );
  }

  /// Compile-time type specification of [$AddressMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/entrance_markers.dart',
    'AddressMarker',
  );

  /// Compile-time type declaration of [$AddressMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AddressMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/widgets/entrance_markers.dart',
          'SizedMarker',
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
              'label',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [AddressMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $AddressMarker.wrap(AddressMarker(label: args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final AddressMarker $value;

  @override
  AddressMarker get $reified => $value;

  /// Wrap a [AddressMarker] in a [$AddressMarker]
  $AddressMarker.wrap(this.$value) : _superclass = $SizedMarker.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [EntranceMarker]
class $EntranceMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/entrance_markers.dart',
      'EntranceMarker.',
      $EntranceMarker.$new,
    );
  }

  /// Compile-time type specification of [$EntranceMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/entrance_markers.dart',
    'EntranceMarker',
  );

  /// Compile-time type declaration of [$EntranceMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$EntranceMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/widgets/entrance_markers.dart',
          'SizedMarker',
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
              'isComplete',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [EntranceMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $EntranceMarker.wrap(
      EntranceMarker(isComplete: args[0]?.$value ?? false),
    );
  }

  final $Instance _superclass;

  @override
  final EntranceMarker $value;

  @override
  EntranceMarker get $reified => $value;

  /// Wrap a [EntranceMarker] in a [$EntranceMarker]
  $EntranceMarker.wrap(this.$value) : _superclass = $SizedMarker.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [IconMarker]
class $IconMarker implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/widgets/entrance_markers.dart',
      'IconMarker.',
      $IconMarker.$new,
    );
  }

  /// Compile-time type specification of [$IconMarker]
  static const $spec = BridgeTypeSpec(
    'package:every_door/widgets/entrance_markers.dart',
    'IconMarker',
  );

  /// Compile-time type declaration of [$IconMarker]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$IconMarker]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/widgets/entrance_markers.dart',
          'SizedMarker',
        ),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'icon',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/multi_icon.dart',
                    'MultiIcon',
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

    methods: {},
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [IconMarker.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $IconMarker.wrap(IconMarker(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final IconMarker $value;

  @override
  IconMarker get $reified => $value;

  /// Wrap a [IconMarker] in a [$IconMarker]
  $IconMarker.wrap(this.$value) : _superclass = $SizedMarker.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
