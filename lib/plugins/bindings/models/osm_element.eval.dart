// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';
import 'package:every_door/plugins/bindings/helpers/geometry/geometry.eval.dart';

/// dart_eval enum wrapper binding for [OsmElementType]
class $OsmElementType implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/models/osm_element.dart',
      'OsmElementType',
      $OsmElementType._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmElementType.values*g',
      $OsmElementType.$values,
    );
  }

  /// Compile-time type specification of [$OsmElementType]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/osm_element.dart',
    'OsmElementType',
  );

  /// Compile-time type declaration of [$OsmElementType]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OsmElementType]
  static const $declaration = BridgeEnumDef(
    $type,

    values: ['node', 'way', 'relation'],

    methods: {},
    getters: {},
    setters: {},
    fields: {},
  );

  static final _$values = {
    'node': $OsmElementType.wrap(OsmElementType.node),
    'way': $OsmElementType.wrap(OsmElementType.way),
    'relation': $OsmElementType.wrap(OsmElementType.relation),
  };

  /// Wrapper for the [OsmElementType.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = OsmElementType.values;
    return $List.view(value, (e) => $OsmElementType.wrap(e));
  }

  final $Instance _superclass;

  @override
  final OsmElementType $value;

  @override
  OsmElementType get $reified => $value;

  /// Wrap a [OsmElementType] in a [$OsmElementType]
  $OsmElementType.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [OsmId]
class $OsmId implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmId.',
      $OsmId.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmId.fromString',
      $OsmId.$fromString,
    );
  }

  /// Compile-time type specification of [$OsmId]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/osm_element.dart',
    'OsmId',
  );

  /// Compile-time type declaration of [$OsmId]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OsmId]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'type',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmElementType',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'ref',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),

      'fromString': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              's',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),
    },

    methods: {},
    getters: {
      'fullRef': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'type': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/osm_element.dart',
              'OsmElementType',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'ref': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [OsmId.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $OsmId.wrap(OsmId(args[0]!.$value, args[1]!.$value));
  }

  /// Wrapper for the [OsmId.fromString] constructor
  static $Value? $fromString(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $OsmId.wrap(OsmId.fromString(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final OsmId $value;

  @override
  OsmId get $reified => $value;

  /// Wrap a [OsmId] in a [$OsmId]
  $OsmId.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'type':
        final _type = $value.type;
        return $OsmElementType.wrap(_type);

      case 'ref':
        final _ref = $value.ref;
        return $int(_ref);

      case 'fullRef':
        final _fullRef = $value.fullRef;
        return $String(_fullRef);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [OsmMember]
class $OsmMember implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmMember.',
      $OsmMember.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmMember.fromString',
      $OsmMember.$fromString,
    );
  }

  /// Compile-time type specification of [$OsmMember]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/osm_element.dart',
    'OsmMember',
  );

  /// Compile-time type declaration of [$OsmMember]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OsmMember]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmId',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'role',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
        isFactory: false,
      ),

      'fromString': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              's',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),
    },

    methods: {},
    getters: {
      'type': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/osm_element.dart',
                'OsmElementType',
              ),
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
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/osm_element.dart',
              'OsmId',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'role': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [OsmMember.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $OsmMember.wrap(OsmMember(args[0]!.$value, args[1]?.$value));
  }

  /// Wrapper for the [OsmMember.fromString] constructor
  static $Value? $fromString(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $OsmMember.wrap(OsmMember.fromString(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final OsmMember $value;

  @override
  OsmMember get $reified => $value;

  /// Wrap a [OsmMember] in a [$OsmMember]
  $OsmMember.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return $OsmId.wrap(_id);

      case 'role':
        final _role = $value.role;
        return _role == null ? const $null() : $String(_role);

      case 'type':
        final _type = $value.type;
        return $OsmElementType.wrap(_type);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval enum wrapper binding for [IsMember]
class $IsMember implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/models/osm_element.dart',
      'IsMember',
      $IsMember._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'IsMember.values*g',
      $IsMember.$values,
    );
  }

  /// Compile-time type specification of [$IsMember]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/osm_element.dart',
    'IsMember',
  );

  /// Compile-time type declaration of [$IsMember]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$IsMember]
  static const $declaration = BridgeEnumDef(
    $type,

    values: ['no', 'way', 'relation'],

    methods: {},
    getters: {},
    setters: {},
    fields: {},
  );

  static final _$values = {
    'no': $IsMember.wrap(IsMember.no),
    'way': $IsMember.wrap(IsMember.way),
    'relation': $IsMember.wrap(IsMember.relation),
  };

  /// Wrapper for the [IsMember.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = IsMember.values;
    return $List.view(value, (e) => $IsMember.wrap(e));
  }

  final $Instance _superclass;

  @override
  final IsMember $value;

  @override
  IsMember get $reified => $value;

  /// Wrap a [IsMember] in a [$IsMember]
  $IsMember.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [OsmElement]
class $OsmElement implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmElement.',
      $OsmElement.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmElement.fromJson',
      $OsmElement.$fromJson,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/osm_element.dart',
      'OsmElement.tagsToString',
      $OsmElement.$tagsToString,
    );
  }

  /// Compile-time type specification of [$OsmElement]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/osm_element.dart',
    'OsmElement',
  );

  /// Compile-time type declaration of [$OsmElement]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OsmElement]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'source',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmId',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'version',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              false,
            ),

            BridgeParameter(
              'timestamp',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dateTime, [])),
              false,
            ),

            BridgeParameter(
              'downloaded',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.dateTime, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'center',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'geometry',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'Geometry',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'nodes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'nodeLocations',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'members',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/osm_element.dart',
                        'OsmMember',
                      ),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'isMember',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'IsMember',
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

      'fromJson': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
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
        isFactory: true,
      ),
    },

    methods: {
      'copyWith': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/osm_element.dart',
                'OsmElement',
              ),
              [],
            ),
          ),
          namedParams: [
            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'version',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'center',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'geometry',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/geometry/geometry.dart',
                    'Geometry',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'isMember',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'IsMember',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'nodes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'nodeLocations',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                      [],
                    ),
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'currentTimestamp',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'clearMembers',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
      ),

      'updateMeta': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/osm_element.dart',
                'OsmElement',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'old',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmElement',
                  ),
                  [],
                ),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'toJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.map, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'toXML': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [
            BridgeParameter(
              'changeset',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'visible',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'builder',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:xml/src/xml/builder.dart',
                    'XmlBuilder',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'tagsToString': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.string, []),
                    nullable: true,
                  ),
                ]),
              ),
              false,
            ),
          ],
        ),
        isStatic: true,
      ),
    },
    getters: {
      'type': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/osm_element.dart',
                'OsmElementType',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'isPoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isGood': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isSnapTarget': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isGeometryValid': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isArea': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'idVersion': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'source': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'id': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/osm_element.dart',
              'OsmId',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'tags': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'version': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
        isStatic: false,
      ),

      'timestamp': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dateTime, [])),
        isStatic: false,
      ),

      'downloaded': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.dateTime, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'center': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'geometry': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/geometry/geometry.dart',
              'Geometry',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'nodes': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'nodeLocations': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                [],
              ),
            ),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'members': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/osm_element.dart',
                  'OsmMember',
                ),
                [],
              ),
            ),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'isMember': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/osm_element.dart',
              'IsMember',
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

  /// Wrapper for the [OsmElement.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $OsmElement.wrap(
      OsmElement(
        source: args[0]!.$value,
        id: args[1]!.$value,
        version: args[2]!.$value,
        timestamp: args[3]!.$value,
        downloaded: args[4]?.$value,
        tags: (args[5]!.$reified as Map).cast(),
        center: args[6]?.$value,
        geometry: args[7]?.$value,
        nodes: (args[8]?.$reified as List?)?.cast(),
        nodeLocations: (args[9]?.$reified as Map?)?.cast(),
        members: (args[10]?.$reified as List?)?.cast(),
        isMember: args[11]?.$value ?? IsMember.no,
      ),
    );
  }

  /// Wrapper for the [OsmElement.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $OsmElement.wrap(
      OsmElement.fromJson((args[0]!.$reified as Map).cast()),
    );
  }

  /// Wrapper for the [OsmElement.tagsToString] method
  static $Value? $tagsToString(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = OsmElement.tagsToString((args[0]!.$reified as Map).cast());
    return $String(value);
  }

  final $Instance _superclass;

  @override
  final OsmElement $value;

  @override
  OsmElement get $reified => $value;

  /// Wrap a [OsmElement] in a [$OsmElement]
  $OsmElement.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'source':
        final _source = $value.source;
        return $String(_source);

      case 'id':
        final _id = $value.id;
        return $OsmId.wrap(_id);

      case 'tags':
        final _tags = $value.tags;
        return $Map.wrap(_tags);

      case 'version':
        final _version = $value.version;
        return $int(_version);

      case 'timestamp':
        final _timestamp = $value.timestamp;
        return $DateTime.wrap(_timestamp);

      case 'downloaded':
        final _downloaded = $value.downloaded;
        return _downloaded == null
            ? const $null()
            : $DateTime.wrap(_downloaded);

      case 'center':
        final _center = $value.center;
        return _center == null ? const $null() : $LatLng.wrap(_center);

      case 'geometry':
        final _geometry = $value.geometry;
        return _geometry == null ? const $null() : $Geometry.wrap(_geometry);

      case 'nodes':
        final _nodes = $value.nodes;
        return _nodes == null
            ? const $null()
            : $List.view(_nodes, (e) => $int(e));

      case 'nodeLocations':
        final _nodeLocations = $value.nodeLocations;
        return _nodeLocations == null
            ? const $null()
            : $Map.wrap(_nodeLocations);

      case 'members':
        final _members = $value.members;
        return _members == null
            ? const $null()
            : $List.view(_members, (e) => $OsmMember.wrap(e));

      case 'isMember':
        final _isMember = $value.isMember;
        return $IsMember.wrap(_isMember);

      case 'type':
        final _type = $value.type;
        return $OsmElementType.wrap(_type);

      case 'isPoint':
        final _isPoint = $value.isPoint;
        return $bool(_isPoint);

      case 'isGood':
        final _isGood = $value.isGood;
        return $bool(_isGood);

      case 'isSnapTarget':
        final _isSnapTarget = $value.isSnapTarget;
        return $bool(_isSnapTarget);

      case 'isGeometryValid':
        final _isGeometryValid = $value.isGeometryValid;
        return $bool(_isGeometryValid);

      case 'isArea':
        final _isArea = $value.isArea;
        return $bool(_isArea);

      case 'idVersion':
        final _idVersion = $value.idVersion;
        return $String(_idVersion);
      case 'copyWith':
        return __copyWith;

      case 'updateMeta':
        return __updateMeta;

      case 'toJson':
        return __toJson;

      case 'toXML':
        return __toXML;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __copyWith = $Function(_copyWith);
  static $Value? _copyWith(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmElement;
    final result = self.$value.copyWith(
      tags: (args[0]?.$reified as Map?)?.cast(),
      id: args[1]?.$value,
      version: args[2]?.$value,
      center: args[3]?.$value,
      geometry: args[4]?.$value,
      isMember: args[5]?.$value,
      nodes: (args[6]?.$reified as List?)?.cast(),
      nodeLocations: (args[7]?.$reified as Map?)?.cast(),
      currentTimestamp: args[8]?.$value ?? false,
      clearMembers: args[9]?.$value ?? false,
    );
    return $OsmElement.wrap(result);
  }

  static const $Function __updateMeta = $Function(_updateMeta);
  static $Value? _updateMeta(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmElement;
    final result = self.$value.updateMeta(args[0]!.$value);
    return $OsmElement.wrap(result);
  }

  static const $Function __toJson = $Function(_toJson);
  static $Value? _toJson(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmElement;
    final result = self.$value.toJson();
    return $Map.wrap(result);
  }

  static const $Function __toXML = $Function(_toXML);
  static $Value? _toXML(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmElement;
    // self.$value.toXML(
    //   args[0]!.$value,
    //   changeset: args[1]?.$value,
    //   visible: args[2]?.$value ?? true,
    // );
    return null;
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
