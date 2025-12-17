// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_map_eval/flutter_map/flutter_map_eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [GeometryException]
class $GeometryException implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/geometry/geometry.dart',
      'GeometryException.',
      $GeometryException.$new,
    );
  }

  /// Compile-time type specification of [$GeometryException]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'GeometryException',
  );

  /// Compile-time type declaration of [$GeometryException]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$GeometryException]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $implements: [BridgeTypeRef(CoreTypes.exception, [])],
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'message',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
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
    fields: {
      'message': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [GeometryException.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $GeometryException.wrap(GeometryException(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final GeometryException $value;

  @override
  GeometryException get $reified => $value;

  /// Wrap a [GeometryException] in a [$GeometryException]
  $GeometryException.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'message':
        final _message = $value.message;
        return $String(_message);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [Geometry]
class $Geometry implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$Geometry]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'Geometry',
  );

  /// Compile-time type declaration of [$Geometry]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Geometry]
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
      'bounds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/geo/latlng_bounds.dart',
                'LatLngBounds',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'center': BridgeMethodDef(
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
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final Geometry $value;

  @override
  Geometry get $reified => $value;

  /// Wrap a [Geometry] in a [$Geometry]
  $Geometry.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'bounds':
        final _bounds = $value.bounds;
        return $LatLngBounds.wrap(_bounds);

      case 'center':
        final _center = $value.center;
        return $LatLng.wrap(_center);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [Polygon]
class $Polygon implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/geometry/geometry.dart',
      'Polygon.',
      $Polygon.$new,
    );
  }

  /// Compile-time type specification of [$Polygon]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'Polygon',
  );

  /// Compile-time type declaration of [$Polygon]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Polygon]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/helpers/geometry/geometry.dart',
          'Geometry',
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
              'nodes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'contains': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
        ),
      ),

      'containsPolygon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'poly',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'Polygon',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'findPointOnSurface': BridgeMethodDef(
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
    },
    getters: {
      'bounds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/geo/latlng_bounds.dart',
                'LatLngBounds',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'center': BridgeMethodDef(
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
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [Polygon.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $Polygon.wrap(Polygon(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final Polygon $value;

  @override
  Polygon get $reified => $value;

  /// Wrap a [Polygon] in a [$Polygon]
  $Polygon.wrap(this.$value) : _superclass = $Geometry.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'bounds':
        final _bounds = $value.bounds;
        return $LatLngBounds.wrap(_bounds);

      case 'center':
        final _center = $value.center;
        return $LatLng.wrap(_center);
      case 'contains':
        return __contains;

      case 'containsPolygon':
        return __containsPolygon;

      case 'findPointOnSurface':
        return __findPointOnSurface;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __contains = $Function(_contains);
  static $Value? _contains(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Polygon;
    final result = self.$value.contains(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __containsPolygon = $Function(_containsPolygon);
  static $Value? _containsPolygon(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Polygon;
    final result = self.$value.containsPolygon(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __findPointOnSurface = $Function(_findPointOnSurface);
  static $Value? _findPointOnSurface(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Polygon;
    final result = self.$value.findPointOnSurface();
    return $LatLng.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [Envelope]
class $Envelope implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/geometry/geometry.dart',
      'Envelope.',
      $Envelope.$new,
    );
  }

  /// Compile-time type specification of [$Envelope]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'Envelope',
  );

  /// Compile-time type declaration of [$Envelope]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Envelope]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $implements: [
        BridgeTypeRef(
          BridgeTypeSpec(
            'package:every_door/helpers/geometry/geometry.dart',
            'Polygon',
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
              '_bounds',
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
        isFactory: false,
      ),
    },

    methods: {
      'contains': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
        ),
      ),

      'containsPolygon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'poly',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'Polygon',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'findPointOnSurface': BridgeMethodDef(
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
    },
    getters: {
      'bounds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/geo/latlng_bounds.dart',
                'LatLngBounds',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'center': BridgeMethodDef(
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
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [Envelope.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $Envelope.wrap(Envelope(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final Envelope $value;

  @override
  Envelope get $reified => $value;

  /// Wrap a [Envelope] in a [$Envelope]
  $Envelope.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'bounds':
        final _bounds = $value.bounds;
        return $LatLngBounds.wrap(_bounds);

      case 'center':
        final _center = $value.center;
        return $LatLng.wrap(_center);
      case 'contains':
        return __contains;

      case 'containsPolygon':
        return __containsPolygon;

      case 'findPointOnSurface':
        return __findPointOnSurface;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __contains = $Function(_contains);
  static $Value? _contains(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Envelope;
    final result = self.$value.contains(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __containsPolygon = $Function(_containsPolygon);
  static $Value? _containsPolygon(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Envelope;
    final result = self.$value.containsPolygon(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __findPointOnSurface = $Function(_findPointOnSurface);
  static $Value? _findPointOnSurface(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Envelope;
    final result = self.$value.findPointOnSurface();
    return $LatLng.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [MultiPolygon]
class $MultiPolygon implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/geometry/geometry.dart',
      'MultiPolygon.',
      $MultiPolygon.$new,
    );
  }

  /// Compile-time type specification of [$MultiPolygon]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'MultiPolygon',
  );

  /// Compile-time type declaration of [$MultiPolygon]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MultiPolygon]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $implements: [
        BridgeTypeRef(
          BridgeTypeSpec(
            'package:every_door/helpers/geometry/geometry.dart',
            'Polygon',
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
              'polygons',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/helpers/geometry/geometry.dart',
                        'Polygon',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'contains': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
        ),
      ),

      'findPointOnSurface': BridgeMethodDef(
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

      'containsPolygon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'poly',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'Polygon',
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
      'bounds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/geo/latlng_bounds.dart',
                'LatLngBounds',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'center': BridgeMethodDef(
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
    },
    setters: {},
    fields: {
      'outer': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/geometry/geometry.dart',
                  'Polygon',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'inner': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/geometry/geometry.dart',
                  'Polygon',
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

  /// Wrapper for the [MultiPolygon.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MultiPolygon.wrap(MultiPolygon(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final MultiPolygon $value;

  @override
  MultiPolygon get $reified => $value;

  /// Wrap a [MultiPolygon] in a [$MultiPolygon]
  $MultiPolygon.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'outer':
        final _outer = $value.outer;
        return $List.view(_outer, (e) => $Polygon.wrap(e));

      case 'inner':
        final _inner = $value.inner;
        return $List.view(_inner, (e) => $Polygon.wrap(e));

      case 'bounds':
        final _bounds = $value.bounds;
        return $LatLngBounds.wrap(_bounds);

      case 'center':
        final _center = $value.center;
        return $LatLng.wrap(_center);
      case 'contains':
        return __contains;

      case 'findPointOnSurface':
        return __findPointOnSurface;

      case 'containsPolygon':
        return __containsPolygon;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __contains = $Function(_contains);
  static $Value? _contains(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $MultiPolygon;
    final result = self.$value.contains(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __findPointOnSurface = $Function(_findPointOnSurface);
  static $Value? _findPointOnSurface(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $MultiPolygon;
    final result = self.$value.findPointOnSurface();
    return $LatLng.wrap(result);
  }

  static const $Function __containsPolygon = $Function(_containsPolygon);
  static $Value? _containsPolygon(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $MultiPolygon;
    final result = self.$value.containsPolygon(args[0]!.$value);
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [LineString]
class $LineString implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/geometry/geometry.dart',
      'LineString.',
      $LineString.$new,
    );
  }

  /// Compile-time type specification of [$LineString]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/geometry/geometry.dart',
    'LineString',
  );

  /// Compile-time type declaration of [$LineString]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$LineString]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:every_door/helpers/geometry/geometry.dart',
          'Geometry',
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
              'nodes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'getLengthInMeters': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'closestPoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
              [],
            ),
          ),
          namedParams: [],
          params: [
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
        ),
      ),

      'distanceToPoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
          namedParams: [
            BridgeParameter(
              'inMeters',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
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
        ),
      ),

      'intersects': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'LineString',
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
      'bounds': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter_map/src/geo/latlng_bounds.dart',
                'LatLngBounds',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'center': BridgeMethodDef(
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
    },
    setters: {},
    fields: {
      'nodes': BridgeFieldDef(
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
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [LineString.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $LineString.wrap(LineString(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final LineString $value;

  @override
  LineString get $reified => $value;

  /// Wrap a [LineString] in a [$LineString]
  $LineString.wrap(this.$value) : _superclass = $Geometry.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'nodes':
        final _nodes = $value.nodes;
        return $List.view(_nodes, (e) => $LatLng.wrap(e));

      case 'bounds':
        final _bounds = $value.bounds;
        return $LatLngBounds.wrap(_bounds);

      case 'center':
        final _center = $value.center;
        return $LatLng.wrap(_center);
      case 'getLengthInMeters':
        return __getLengthInMeters;

      case 'closestPoint':
        return __closestPoint;

      case 'distanceToPoint':
        return __distanceToPoint;

      case 'intersects':
        return __intersects;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __getLengthInMeters = $Function(_getLengthInMeters);
  static $Value? _getLengthInMeters(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LineString;
    final result = self.$value.getLengthInMeters();
    return $double(result);
  }

  static const $Function __closestPoint = $Function(_closestPoint);
  static $Value? _closestPoint(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LineString;
    final result = self.$value.closestPoint(args[0]!.$value);
    return $LatLng.wrap(result);
  }

  static const $Function __distanceToPoint = $Function(_distanceToPoint);
  static $Value? _distanceToPoint(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LineString;
    final result = self.$value.distanceToPoint(
      args[0]!.$value,
      inMeters: args[1]?.$value ?? true,
    );
    return $double(result);
  }

  static const $Function __intersects = $Function(_intersects);
  static $Value? _intersects(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LineString;
    final result = self.$value.intersects(args[0]!.$value);
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
