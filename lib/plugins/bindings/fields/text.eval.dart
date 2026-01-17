import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/fields/text.dart';
import 'package:flutter/material.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/field.eval.dart';

/// dart_eval enum wrapper binding for [TextFieldCapitalize]
class $TextFieldCapitalize implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/fields/text.dart',
      'TextFieldCapitalize',
      $TextFieldCapitalize._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/fields/text.dart',
      'TextFieldCapitalize.values*g',
      $TextFieldCapitalize.$values,
    );
  }

  /// Compile-time type specification of [$TextFieldCapitalize]
  static const $spec = BridgeTypeSpec(
    'package:every_door/fields/text.dart',
    'TextFieldCapitalize',
  );

  /// Compile-time type declaration of [$TextFieldCapitalize]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$TextFieldCapitalize]
  static const $declaration = BridgeEnumDef(
    $type,
    values: ['no', 'asName', 'sentence', 'all'],
  );

  static final _$values = {
    'no': $TextFieldCapitalize.wrap(TextFieldCapitalize.no),
    'asName': $TextFieldCapitalize.wrap(TextFieldCapitalize.asName),
    'sentence': $TextFieldCapitalize.wrap(TextFieldCapitalize.sentence),
    'all': $TextFieldCapitalize.wrap(TextFieldCapitalize.all),
  };

  /// Wrapper for the [TextFieldCapitalize.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = TextFieldCapitalize.values;
    return $List.view(value, (e) => $TextFieldCapitalize.wrap(e));
  }

  final $Instance _superclass;

  @override
  final TextFieldCapitalize $value;

  @override
  TextFieldCapitalize get $reified => $value;

  /// Wrap a [TextFieldCapitalize] in a [$TextFieldCapitalize]
  $TextFieldCapitalize.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [TextPresetField]
class $TextPresetField implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/fields/text.dart',
      'TextPresetField.',
      $TextPresetField.$new,
    );
  }

  /// Compile-time type specification of [$TextPresetField]
  static const $spec = BridgeTypeSpec(
    'package:every_door/fields/text.dart',
    'TextPresetField',
  );

  /// Compile-time type declaration of [$TextPresetField]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$TextPresetField]
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
              'placeholder',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
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
              'keyboardType',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/services/text_input.dart',
                    'TextInputType',
                  ),
                  [],
                ),
              ),
              true,
            ),

            BridgeParameter(
              'capitalize',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/fields/text.dart',
                    'TextFieldCapitalize',
                  ),
                  [],
                ),
              ),
              true,
            ),

            BridgeParameter(
              'maxLines',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'showClearButton',
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

  /// Wrapper for the [TextPresetField.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $TextPresetField.wrap(
      TextPresetField(
        key: args[0]!.$value,
        label: args[1]!.$value,
        icon: args[2]?.$value,
        placeholder: args[3]?.$value,
        prerequisite: args[4]?.$value,
        locationSet: args[5]?.$value,
        keyboardType: args[6]?.$value ?? TextInputType.text,
        capitalize: args[7]?.$value ?? TextFieldCapitalize.sentence,
        maxLines: args[8]?.$value,
        showClearButton: args[9]?.$value ?? false,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final TextPresetField $value;

  @override
  TextPresetField get $reified => $value;

  /// Wrap a [TextPresetField] in a [$TextPresetField]
  $TextPresetField.wrap(this.$value) : _superclass = $PresetField.wrap($value);

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
