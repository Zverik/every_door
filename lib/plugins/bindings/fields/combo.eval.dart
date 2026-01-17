// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/fields/combo.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:every_door/plugins/bindings/models/field.eval.dart';

/// dart_eval wrapper binding for [ComboOption]
class $ComboOption implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/fields/combo.dart',
      'ComboOption.',
      $ComboOption.$new,
    );
  }

  /// Compile-time type specification of [$ComboOption]
  static const $spec = BridgeTypeSpec(
    'package:every_door/fields/combo.dart',
    'ComboOption',
  );

  /// Compile-time type declaration of [$ComboOption]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ComboOption]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'label',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'widget',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'Widget',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'withLabel': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/fields/combo.dart',
                'ComboOption',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'label',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'value': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'label': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'widget': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:flutter/src/widgets/framework.dart',
              'Widget',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ComboOption.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ComboOption.wrap(
      ComboOption(
        args[0]!.$value,
        label: args[1]?.$value,
        widget: args[2]?.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ComboOption $value;

  @override
  ComboOption get $reified => $value;

  /// Wrap a [ComboOption] in a [$ComboOption]
  $ComboOption.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'value':
        final _value = $value.value;
        return $String(_value);

      case 'label':
        final _label = $value.label;
        return _label == null ? const $null() : $String(_label);

      case 'widget':
        final _widget = $value.widget;
        return _widget == null ? const $null() : $Widget.wrap(_widget);
      case 'withLabel':
        return __withLabel;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __withLabel = $Function(_withLabel);
  static $Value? _withLabel(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $ComboOption;
    final result = self.$value.withLabel(args[0]!.$value);
    return $ComboOption.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval enum wrapper binding for [ComboType]
class $ComboType implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/fields/combo.dart',
      'ComboType',
      $ComboType._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/fields/combo.dart',
      'ComboType.values*g',
      $ComboType.$values,
    );
  }

  /// Compile-time type specification of [$ComboType]
  static const $spec = BridgeTypeSpec(
    'package:every_door/fields/combo.dart',
    'ComboType',
  );

  /// Compile-time type declaration of [$ComboType]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ComboType]
  static const $declaration = BridgeEnumDef(
    $type,
    values: ['regular', 'type', 'semi', 'multi'],
  );

  static final _$values = {
    'regular': $ComboType.wrap(ComboType.regular),
    'type': $ComboType.wrap(ComboType.type),
    'semi': $ComboType.wrap(ComboType.semi),
    'multi': $ComboType.wrap(ComboType.multi),
  };

  /// Wrapper for the [ComboType.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ComboType.values;
    return $List.view(value, (e) => $ComboType.wrap(e));
  }

  final $Instance _superclass;

  @override
  final ComboType $value;

  @override
  ComboType get $reified => $value;

  /// Wrap a [ComboType] in a [$ComboType]
  $ComboType.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [ComboPresetField]
class $ComboPresetField implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/fields/combo.dart',
      'ComboPresetField.',
      $ComboPresetField.$new,
    );
  }

  /// Compile-time type specification of [$ComboPresetField]
  static const $spec = BridgeTypeSpec(
    'package:every_door/fields/combo.dart',
    'ComboPresetField',
  );

  /// Compile-time type declaration of [$ComboPresetField]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ComboPresetField]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec('package:every_door/models/field.dart', 'PresetField'),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'label',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'icon',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/icon_data.dart',
                    'IconData',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'prerequisite',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/field.dart',
                    'FieldPrerequisite',
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
              'type',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/fields/combo.dart',
                    'ComboType',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'options',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/fields/combo.dart',
                        'ComboOption',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
              false,
            ),

            BridgeParameter(
              'customValues',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'snakeCase',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ComboPresetField.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ComboPresetField.wrap(
      ComboPresetField(
        key: args[0]!.$value,
        label: args[1]!.$value,
        icon: args[2]?.$value,
        prerequisite: args[3]?.$value,
        locationSet: args[4]?.$value,
        type: args[5]!.$value,
        options: (args[6]!.$reified as List).cast(),
        customValues: args[7]?.$value ?? true,
        snakeCase: args[8]?.$value ?? true,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ComboPresetField $value;

  @override
  ComboPresetField get $reified => $value;

  /// Wrap a [ComboPresetField] in a [$ComboPresetField]
  $ComboPresetField.wrap(this.$value) : _superclass = $PresetField.wrap($value);

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
