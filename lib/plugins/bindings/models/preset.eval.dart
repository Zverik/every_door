// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/preset.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/field.eval.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:flutter_map_eval/country_coder/country_coder_eval.dart';

/// dart_eval enum wrapper binding for [PresetType]
class $PresetType implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/models/preset.dart',
      'PresetType',
      $PresetType._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'PresetType.values*g',
      $PresetType.$values,
    );
  }

  /// Compile-time type specification of [$PresetType]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/preset.dart',
    'PresetType',
  );

  /// Compile-time type declaration of [$PresetType]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PresetType]
  static const $declaration = BridgeEnumDef(
    $type,
    values: ['normal', 'nsi', 'fixme', 'taginfo'],
  );

  static final _$values = {
    'normal': $PresetType.wrap(PresetType.normal),
    'nsi': $PresetType.wrap(PresetType.nsi),
    'fixme': $PresetType.wrap(PresetType.fixme),
    'taginfo': $PresetType.wrap(PresetType.taginfo),
  };

  /// Wrapper for the [PresetType.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = PresetType.values;
    return $List.view(value, (e) => $PresetType.wrap(e));
  }

  final $Instance _superclass;

  @override
  final PresetType $value;

  @override
  PresetType get $reified => $value;

  /// Wrap a [PresetType] in a [$PresetType]
  $PresetType.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [Preset]
class $Preset implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.',
      $Preset.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.fixme',
      $Preset.$fixme,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.poi',
      $Preset.$poi,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.fromJson',
      $Preset.$fromJson,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.fromNSIJson',
      $Preset.$fromNSIJson,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.decodeTags',
      $Preset.$decodeTags,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.decodeTagsSkipNull',
      $Preset.$decodeTagsSkipNull,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/preset.dart',
      'Preset.defaultPreset*g',
      $Preset.$defaultPreset,
    );
  }

  /// Compile-time type specification of [$Preset]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/preset.dart',
    'Preset',
  );

  /// Compile-time type declaration of [$Preset]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Preset]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'fields',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/field.dart',
                        'PresetField',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'moreFields',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/field.dart',
                        'PresetField',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'onArea',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'addTags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'removeTags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.string, []),
                    nullable: true,
                  ),
                ]),
              ),
              true,
            ),

            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'subtitle',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

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
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'locationSet',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:country_coder/src/location_set.dart',
                    'LocationSet',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'fieldData',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'type',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/preset.dart',
                    'PresetType',
                  ),
                  [],
                ),
              ),
              true,
            ),

            BridgeParameter(
              'noStandard',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),

      'fixme': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'subtitle',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'title',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isFactory: true,
      ),

      'poi': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'row',
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

      'fromNSIJson': BridgeConstructorDef(
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
      'decodeTags': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.map, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
        isStatic: true,
      ),

      'decodeTagsSkipNull': BridgeMethodDef(
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
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
        isStatic: true,
      ),

      'withFields': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:every_door/models/preset.dart', 'Preset'),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'fields',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/field.dart',
                        'PresetField',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'moreFields',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/field.dart',
                        'PresetField',
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
      ),

      'withSubtitle': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:every_door/models/preset.dart', 'Preset'),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'subtitle',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'doAddTags': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'change',
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

      'doRemoveTags': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'change',
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
    getters: {
      'subtitle': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'isGeneric': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'fields': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/field.dart',
                  'PresetField',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'moreFields': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/models/field.dart',
                  'PresetField',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: false,
      ),

      'fieldData': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'onArea': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'addTags': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),

      'removeTags': BridgeFieldDef(
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

      'id': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'name': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'icon': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/multi_icon.dart',
              'MultiIcon',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'locationSet': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:country_coder/src/location_set.dart',
              'LocationSet',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'type': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/preset.dart',
              'PresetType',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),

      'noStandard': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'defaultPreset': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:every_door/models/preset.dart', 'Preset'),
            [],
          ),
        ),
        isStatic: true,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [Preset.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $Preset.wrap(
      Preset(
        id: args[0]!.$value,
        fields: (args[1]?.$reified ?? const [] as List?)?.cast(),
        moreFields: (args[2]?.$reified ?? const [] as List?)?.cast(),
        onArea: args[3]?.$value ?? true,
        addTags: (args[4]!.$reified as Map).cast(),
        removeTags: (args[5]?.$reified ?? const {} as Map?)?.cast(),
        name: args[6]!.$value,
        subtitle: args[7]?.$value,
        icon: args[8]?.$value,
        locationSet: args[9]?.$value,
        fieldData: (args[10]?.$reified as Map?)?.cast(),
        type: args[11]?.$value ?? PresetType.normal,
        noStandard: args[12]?.$value ?? false,
      ),
    );
  }

  /// Wrapper for the [Preset.fixme] constructor
  static $Value? $fixme(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $Preset.wrap(
      Preset.fixme(args[0]!.$value, subtitle: args[1]?.$value),
    );
  }

  /// Wrapper for the [Preset.poi] constructor
  static $Value? $poi(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $Preset.wrap(Preset.poi((args[0]!.$reified as Map).cast()));
  }

  /// Wrapper for the [Preset.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $Preset.wrap(Preset.fromJson((args[0]!.$reified as Map).cast()));
  }

  /// Wrapper for the [Preset.fromNSIJson] constructor
  static $Value? $fromNSIJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $Preset.wrap(Preset.fromNSIJson((args[0]!.$reified as Map).cast()));
  }

  /// Wrapper for the [Preset.decodeTags] method
  static $Value? $decodeTags(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = Preset.decodeTags((args[0]!.$reified as Map).cast());
    return $Map.wrap(value);
  }

  /// Wrapper for the [Preset.decodeTagsSkipNull] method
  static $Value? $decodeTagsSkipNull(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = Preset.decodeTagsSkipNull((args[0]!.$reified as Map).cast());
    return $Map.wrap(value);
  }

  /// Wrapper for the [Preset.defaultPreset] getter
  static $Value? $defaultPreset(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = Preset.defaultPreset;
    return $Preset.wrap(value);
  }

  final $Instance _superclass;

  @override
  final Preset $value;

  @override
  Preset get $reified => $value;

  /// Wrap a [Preset] in a [$Preset]
  $Preset.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'fields':
        final _fields = $value.fields;
        return $List.view(_fields, (e) => $PresetField.wrap(e));

      case 'moreFields':
        final _moreFields = $value.moreFields;
        return $List.view(_moreFields, (e) => $PresetField.wrap(e));

      case 'fieldData':
        final _fieldData = $value.fieldData;
        return _fieldData == null ? const $null() : $Map.wrap(_fieldData);

      case 'onArea':
        final _onArea = $value.onArea;
        return $bool(_onArea);

      case 'addTags':
        final _addTags = $value.addTags;
        return $Map.wrap(_addTags);

      case 'removeTags':
        final _removeTags = $value.removeTags;
        return $Map.wrap(_removeTags);

      case 'id':
        final _id = $value.id;
        return $String(_id);

      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'locationSet':
        final _locationSet = $value.locationSet;
        return _locationSet == null
            ? const $null()
            : $LocationSet.wrap(_locationSet);

      case 'type':
        final _type = $value.type;
        return $PresetType.wrap(_type);

      case 'noStandard':
        final _noStandard = $value.noStandard;
        return $bool(_noStandard);

      case 'subtitle':
        final _subtitle = $value.subtitle;
        return $String(_subtitle);

      case 'isGeneric':
        final _isGeneric = $value.isGeneric;
        return $bool(_isGeneric);
      case 'withFields':
        return __withFields;

      case 'withSubtitle':
        return __withSubtitle;

      case 'doAddTags':
        return __doAddTags;

      case 'doRemoveTags':
        return __doRemoveTags;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __withFields = $Function(_withFields);
  static $Value? _withFields(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Preset;
    final result = self.$value.withFields(
      (args[0]!.$reified as List).cast(),
      (args[1]!.$reified as List).cast(),
    );
    return $Preset.wrap(result);
  }

  static const $Function __withSubtitle = $Function(_withSubtitle);
  static $Value? _withSubtitle(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Preset;
    final result = self.$value.withSubtitle(args[0]!.$value);
    return $Preset.wrap(result);
  }

  static const $Function __doAddTags = $Function(_doAddTags);
  static $Value? _doAddTags(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Preset;
    self.$value.doAddTags(args[0]!.$value);
    return null;
  }

  static const $Function __doRemoveTags = $Function(_doRemoveTags);
  static $Value? _doRemoveTags(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Preset;
    self.$value.doRemoveTags(args[0]!.$value);
    return null;
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
