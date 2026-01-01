// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/amenity.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:flutter_eval/foundation.dart';
import 'package:every_door/plugins/bindings/models/osm_element.eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [OsmChange]
class $OsmChange implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/amenity.dart',
      'OsmChange.',
      $OsmChange.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/amenity.dart',
      'OsmChange.create',
      $OsmChange.$create,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/amenity.dart',
      'OsmChange.fromJson',
      $OsmChange.$fromJson,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/amenity.dart',
      'OsmChange.kCheckedKey*g',
      $OsmChange.$kCheckedKey,
    );
  }

  /// Compile-time type specification of [$OsmChange]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/amenity.dart',
    'OsmChange',
  );

  /// Compile-time type declaration of [$OsmChange]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OsmChange]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter/src/foundation/change_notifier.dart',
          'ChangeNotifier',
        ),
        [],
      ),

      $implements: [
        BridgeTypeRef(CoreTypes.comparable, [
          BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
        ]),
        $Located$bridge.$type,
      ],
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'newTags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.string, []),
                    nullable: true,
                  ),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'newLocation',
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
              'hardDeleted',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'error',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'updated',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.dateTime, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'newNodes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'databaseId',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'element',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmElement',
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

      'create': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
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
              'location',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'updated',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.dateTime, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'databaseId',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'error',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'newId',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
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
      'copy': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/amenity.dart',
                'OsmChange',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'revert': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      '[]': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'k',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      '[]=': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'k',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'v',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'removeTag': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'undoTagChange': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'hasTag': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'changedTag': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'calculateAge': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'isCountedOld': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'age',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              false,
            ),
          ],
        ),
      ),

      'check': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'uncheck': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'toggleCheck': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
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

      'toElement': BridgeMethodDef(
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
              'newId',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'newVersion',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [],
        ),
      ),

      'mergeNewElement': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/amenity.dart',
                'OsmChange',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'newElement',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/osm_element.dart',
                    'OsmElement',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'togglePrefix': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'prefix',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'toggleDisused': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'getAnyName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'getLocalName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
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

      'getContact': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'setContact': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'removeOpeningHoursSigned': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'isFixmeNote': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'getFullTags': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.map, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'clearDisused',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
        ),
      ),

      'compareTo': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'other',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              false,
            ),
          ],
        ),
      ),
    },
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

      'id': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/osm_element.dart',
                'OsmId',
              ),
              [],
            ),
          ),
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

      'isModified': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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

      'isHardDeleted': BridgeMethodDef(
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

      'isPoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'canDelete': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'canMove': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isConfirmed': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'mainKey': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'age': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'baseAge': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isOld': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'wasOld': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isCheckedToday': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isDisused': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'name': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'hasPayment': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'acceptsCards': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'cashOnly': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'hasWebsite': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'descriptiveTag': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'typeAndName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'address': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
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
              'loc',
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

      'isDeleted': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
      ),
    },
    fields: {
      'kCheckedKey': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: true,
      ),

      'element': BridgeFieldDef(
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
        isStatic: false,
      ),

      'newTags': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(
              BridgeTypeRef(CoreTypes.string, []),
              nullable: true,
            ),
          ]),
        ),
        isStatic: false,
      ),

      'newLocation': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'newNodes': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'error': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'databaseId': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'updated': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dateTime, [])),
        isStatic: false,
      ),

      'newId': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, []), nullable: true),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [OsmChange.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $OsmChange.wrap(
      OsmChange(
        args[0]!.$value,
        newTags: (args[1]?.$reified as Map?)?.cast(),
        newLocation: args[2]?.$value,
        hardDeleted: args[3]?.$value ?? false,
        error: args[4]?.$value,
        updated: args[5]?.$value,
        newNodes: (args[6]?.$reified as List?)?.cast(),
        databaseId: args[7]?.$value,
      ),
    );
  }

  /// Wrapper for the [OsmChange.create] constructor
  static $Value? $create(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $OsmChange.wrap(
      OsmChange.create(
        tags: (args[0]!.$reified as Map).cast(),
        location: args[1]!.$value,
        updated: args[2]?.$value,
        databaseId: args[3]?.$value,
        error: args[4]?.$value,
        newId: args[5]?.$value,
      ),
    );
  }

  /// Wrapper for the [OsmChange.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $OsmChange.wrap(
      OsmChange.fromJson((args[0]!.$reified as Map).cast()),
    );
  }

  /// Wrapper for the [OsmChange.kCheckedKey] getter
  static $Value? $kCheckedKey(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = OsmChange.kCheckedKey;
    return $String(value);
  }

  final $Instance _superclass;

  @override
  final OsmChange $value;

  @override
  OsmChange get $reified => $value;

  /// Wrap a [OsmChange] in a [$OsmChange]
  $OsmChange.wrap(this.$value) : _superclass = $ChangeNotifier.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'element':
        final _element = $value.element;
        return _element == null ? const $null() : $OsmElement.wrap(_element);

      case 'newTags':
        final _newTags = $value.newTags;
        return $Map.wrap(_newTags);

      case 'newLocation':
        final _newLocation = $value.newLocation;
        return _newLocation == null
            ? const $null()
            : $LatLng.wrap(_newLocation);

      case 'newNodes':
        final _newNodes = $value.newNodes;
        return _newNodes == null
            ? const $null()
            : $List.view(_newNodes, (e) => $int(e));

      case 'error':
        final _error = $value.error;
        return _error == null ? const $null() : $String(_error);

      case 'databaseId':
        final _databaseId = $value.databaseId;
        return $String(_databaseId);

      case 'updated':
        final _updated = $value.updated;
        return $DateTime.wrap(_updated);

      case 'newId':
        final _newId = $value.newId;
        return _newId == null ? const $null() : $int(_newId);

      case 'location':
        final _location = $value.location;
        return $LatLng.wrap(_location);

      case 'uniqueId':
        final _uniqueId = $value.uniqueId;
        return $String(_uniqueId);

      case 'id':
        final _id = $value.id;
        return $OsmId.wrap(_id);

      case 'isDeleted':
        final _isDeleted = $value.isDeleted;
        return $bool(_isDeleted);

      case 'isModified':
        final _isModified = $value.isModified;
        return $bool(_isModified);

      case 'isNew':
        final _isNew = $value.isNew;
        return $bool(_isNew);

      case 'isHardDeleted':
        final _isHardDeleted = $value.isHardDeleted;
        return $bool(_isHardDeleted);

      case 'isArea':
        final _isArea = $value.isArea;
        return $bool(_isArea);

      case 'isPoint':
        final _isPoint = $value.isPoint;
        return $bool(_isPoint);

      case 'canDelete':
        final _canDelete = $value.canDelete;
        return $bool(_canDelete);

      case 'canMove':
        final _canMove = $value.canMove;
        return $bool(_canMove);

      case 'isConfirmed':
        final _isConfirmed = $value.isConfirmed;
        return $bool(_isConfirmed);

      case 'mainKey':
        final _mainKey = $value.mainKey;
        return _mainKey == null ? const $null() : $String(_mainKey);

      case 'age':
        final _age = $value.age;
        return $int(_age);

      case 'baseAge':
        final _baseAge = $value.baseAge;
        return $int(_baseAge);

      case 'isOld':
        final _isOld = $value.isOld;
        return $bool(_isOld);

      case 'wasOld':
        final _wasOld = $value.wasOld;
        return $bool(_wasOld);

      case 'isCheckedToday':
        final _isCheckedToday = $value.isCheckedToday;
        return $bool(_isCheckedToday);

      case 'isDisused':
        final _isDisused = $value.isDisused;
        return $bool(_isDisused);

      case 'name':
        final _name = $value.name;
        return _name == null ? const $null() : $String(_name);

      case 'hasPayment':
        final _hasPayment = $value.hasPayment;
        return $bool(_hasPayment);

      case 'acceptsCards':
        final _acceptsCards = $value.acceptsCards;
        return $bool(_acceptsCards);

      case 'cashOnly':
        final _cashOnly = $value.cashOnly;
        return $bool(_cashOnly);

      case 'hasWebsite':
        final _hasWebsite = $value.hasWebsite;
        return $bool(_hasWebsite);

      case 'descriptiveTag':
        final _descriptiveTag = $value.descriptiveTag;
        return _descriptiveTag == null
            ? const $null()
            : $String(_descriptiveTag);

      case 'typeAndName':
        final _typeAndName = $value.typeAndName;
        return $String(_typeAndName);

      case 'address':
        final _address = $value.address;
        return _address == null ? const $null() : $String(_address);
      case 'copy':
        return __copy;

      case 'revert':
        return __revert;

      case '[]':
        return __operatorIndexGet;

      case '[]=':
        return __operatorIndexSet;

      case 'removeTag':
        return __removeTag;

      case 'undoTagChange':
        return __undoTagChange;

      case 'hasTag':
        return __hasTag;

      case 'changedTag':
        return __changedTag;

      case 'calculateAge':
        return __calculateAge;

      case 'isCountedOld':
        return __isCountedOld;

      case 'check':
        return __check;

      case 'uncheck':
        return __uncheck;

      case 'toggleCheck':
        return __toggleCheck;

      case 'toJson':
        return __toJson;

      case 'toElement':
        return __toElement;

      case 'mergeNewElement':
        return __mergeNewElement;

      case 'togglePrefix':
        return __togglePrefix;

      case 'toggleDisused':
        return __toggleDisused;

      case 'getAnyName':
        return __getAnyName;

      case 'getLocalName':
        return __getLocalName;

      case 'getContact':
        return __getContact;

      case 'setContact':
        return __setContact;

      case 'removeOpeningHoursSigned':
        return __removeOpeningHoursSigned;

      case 'isFixmeNote':
        return __isFixmeNote;

      case 'getFullTags':
        return __getFullTags;

      case 'compareTo':
        return __compareTo;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __copy = $Function(_copy);
  static $Value? _copy(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    final result = self.$value.copy();
    return $OsmChange.wrap(result);
  }

  static const $Function __revert = $Function(_revert);
  static $Value? _revert(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    self.$value.revert();
    return null;
  }

  static const $Function __operatorIndexGet = $Function(_operatorIndexGet);
  static $Value? _operatorIndexGet(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value[args[0]!.$value];
    return result == null ? const $null() : $String(result);
  }

  static const $Function __operatorIndexSet = $Function(_operatorIndexSet);
  static $Value? _operatorIndexSet(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value[args[0]!.$value] = args[1]!.$value;
    return null;
  }

  static const $Function __removeTag = $Function(_removeTag);
  static $Value? _removeTag(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.removeTag(args[0]!.$value);
    return null;
  }

  static const $Function __undoTagChange = $Function(_undoTagChange);
  static $Value? _undoTagChange(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.undoTagChange(args[0]!.$value);
    return null;
  }

  static const $Function __hasTag = $Function(_hasTag);
  static $Value? _hasTag(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    final result = self.$value.hasTag(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __changedTag = $Function(_changedTag);
  static $Value? _changedTag(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.changedTag(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __calculateAge = $Function(_calculateAge);
  static $Value? _calculateAge(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.calculateAge(args[0]!.$value);
    return $int(result);
  }

  static const $Function __isCountedOld = $Function(_isCountedOld);
  static $Value? _isCountedOld(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.isCountedOld(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __check = $Function(_check);
  static $Value? _check(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    self.$value.check();
    return null;
  }

  static const $Function __uncheck = $Function(_uncheck);
  static $Value? _uncheck(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    self.$value.uncheck();
    return null;
  }

  static const $Function __toggleCheck = $Function(_toggleCheck);
  static $Value? _toggleCheck(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.toggleCheck();
    return null;
  }

  static const $Function __toJson = $Function(_toJson);
  static $Value? _toJson(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $OsmChange;
    final result = self.$value.toJson();
    return $Map.wrap(result);
  }

  static const $Function __toElement = $Function(_toElement);
  static $Value? _toElement(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.toElement(
      newId: args[0]?.$value,
      newVersion: args[1]?.$value,
    );
    return $OsmElement.wrap(result);
  }

  static const $Function __mergeNewElement = $Function(_mergeNewElement);
  static $Value? _mergeNewElement(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.mergeNewElement(args[0]!.$value);
    return $OsmChange.wrap(result);
  }

  static const $Function __togglePrefix = $Function(_togglePrefix);
  static $Value? _togglePrefix(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.togglePrefix(args[0]!.$value);
    return null;
  }

  static const $Function __toggleDisused = $Function(_toggleDisused);
  static $Value? _toggleDisused(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.toggleDisused();
    return null;
  }

  static const $Function __getAnyName = $Function(_getAnyName);
  static $Value? _getAnyName(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.getAnyName();
    return result == null ? const $null() : $String(result);
  }

  static const $Function __getLocalName = $Function(_getLocalName);
  static $Value? _getLocalName(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.getLocalName(args[0]!.$value);
    return result == null ? const $null() : $String(result);
  }

  static const $Function __getContact = $Function(_getContact);
  static $Value? _getContact(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.getContact(args[0]!.$value);
    return result == null ? const $null() : $String(result);
  }

  static const $Function __setContact = $Function(_setContact);
  static $Value? _setContact(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.setContact(args[0]!.$value, args[1]!.$value);
    return null;
  }

  static const $Function __removeOpeningHoursSigned = $Function(
    _removeOpeningHoursSigned,
  );
  static $Value? _removeOpeningHoursSigned(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    self.$value.removeOpeningHoursSigned();
    return null;
  }

  static const $Function __isFixmeNote = $Function(_isFixmeNote);
  static $Value? _isFixmeNote(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.isFixmeNote();
    return $bool(result);
  }

  static const $Function __getFullTags = $Function(_getFullTags);
  static $Value? _getFullTags(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.getFullTags(args[0]?.$value ?? false);
    return $Map.wrap(result);
  }

  static const $Function __compareTo = $Function(_compareTo);
  static $Value? _compareTo(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $OsmChange;
    final result = self.$value.compareTo(args[0]!.$value);
    return $int(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'newTags':
        $value.newTags = value.$value;
        return;

      case 'newLocation':
        $value.newLocation = value.$value;
        return;

      case 'newNodes':
        $value.newNodes = value.$value;
        return;

      case 'error':
        $value.error = value.$value;
        return;

      case 'updated':
        $value.updated = value.$value;
        return;

      case 'newId':
        $value.newId = value.$value;
        return;

      case 'location':
        $value.location = value.$value;
        return;

      case 'isDeleted':
        $value.isDeleted = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
