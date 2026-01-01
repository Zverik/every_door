// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/note.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/located.eval.dart';
import 'package:flutter_map_eval/latlong2/latlong2_eval.dart';

/// dart_eval wrapper binding for [BaseNote]
class $BaseNote implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/note.dart',
      'BaseNote.',
      $BaseNote.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/note.dart',
      'BaseNote.fromJson',
      $BaseNote.$fromJson,
    );
  }

  /// Compile-time type specification of [$BaseNote]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/note.dart',
    'BaseNote',
  );

  /// Compile-time type declaration of [$BaseNote]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$BaseNote]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec('package:every_door/models/located.dart', 'Located'),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
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
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'type',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              false,
            ),

            BridgeParameter(
              'created',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.dateTime, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'isDeleted',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
      'revert': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
    },
    getters: {
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
    },
    setters: {},
    fields: {
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, []), nullable: true),
        isStatic: false,
      ),

      'type': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, []), nullable: true),
        isStatic: false,
      ),

      'created': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dateTime, [])),
        isStatic: false,
      ),

      'uniqueId': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'location': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
            [],
          ),
        ),
        isStatic: false,
      ),

      'isDeleted': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [BaseNote.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $BaseNote.wrap(
      BaseNote(
        location: args[0]!.$value,
        id: args[1]?.$value,
        type: args[2]!.$value,
        created: args[3]?.$value,
        isDeleted: args[4]?.$value ?? false,
      ),
    );
  }

  /// Wrapper for the [BaseNote.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $BaseNote.wrap(BaseNote.fromJson((args[0]!.$reified as Map).cast()));
  }

  final $Instance _superclass;

  @override
  final BaseNote $value;

  @override
  BaseNote get $reified => $value;

  /// Wrap a [BaseNote] in a [$BaseNote]
  $BaseNote.wrap(this.$value) : _superclass = $Located.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return _id == null ? const $null() : $int(_id);

      case 'type':
        final _type = $value.type;
        return _type == null ? const $null() : $int(_type);

      case 'created':
        final _created = $value.created;
        return $DateTime.wrap(_created);

      case 'uniqueId':
        final _uniqueId = $value.uniqueId;
        return $String(_uniqueId);

      case 'location':
        final _location = $value.location;
        return $LatLng.wrap(_location);

      case 'isDeleted':
        final _isDeleted = $value.isDeleted;
        return $bool(_isDeleted);

      case 'isModified':
        final _isModified = $value.isModified;
        return $bool(_isModified);

      case 'isNew':
        final _isNew = $value.isNew;
        return $bool(_isNew);
      case 'revert':
        return __revert;

      case 'toJson':
        return __toJson;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __revert = $Function(_revert);
  static $Value? _revert(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $BaseNote;
    final result = self.$value.revert();
    return $bool(result);
  }

  static const $Function __toJson = $Function(_toJson);
  static $Value? _toJson(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $BaseNote;
    final result = self.$value.toJson();
    return $Map.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'id':
        $value.id = value.$value;
        return;

      case 'isDeleted':
        $value.isDeleted = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
