import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/editor_fields.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/models/field.dart';

/// dart_eval wrapper binding for [EditorFields]
class $EditorFields implements EditorFields, $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/editor_fields.dart',
      'EditorFields.',
      $EditorFields.$new,
    );
  }

  /// Compile-time type specification of [$EditorFields]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/editor_fields.dart',
    'EditorFields',
  );

  /// Compile-time type declaration of [$EditorFields]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$EditorFields]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'fields',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
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
              'title',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'collapsed',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'iconLabels',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'mandatoryKeys',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.set, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
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
    fields: {
      'title': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'collapsed': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'iconLabels': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'fields': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.iterable, [
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

      'mandatoryKeys': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.set, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [EditorFields.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $EditorFields.wrap(
      EditorFields(
        fields: (args[0]!.$reified as Iterable<dynamic>).cast(),
        title: args[1]?.$value,
        collapsed: args[2]?.$value ?? true,
        iconLabels: args[3]?.$value ?? false,
        mandatoryKeys: args[4]?.$reified?.cast() ?? <String>{},
      ),
    );
  }

  final $Instance _superclass;

  @override
  final EditorFields $value;

  @override
  EditorFields get $reified => $value;

  /// Wrap a [EditorFields] in a [$EditorFields]
  $EditorFields.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'title':
        final title = $value.title;
        return title == null ? const $null() : $String(title);

      case 'collapsed':
        return $bool($value.collapsed);

      case 'iconLabels':
        return $bool($value.iconLabels);

      case 'fields':
        return $Iterable.wrap($value.fields);

      case 'mandatoryKeys':
        return $Set.wrap($value.mandatoryKeys);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  bool get collapsed => $value.collapsed;

  @override
  Iterable<PresetField> get fields => $value.fields;

  @override
  bool get iconLabels => $value.iconLabels;

  @override
  Set<String> get mandatoryKeys => $value.mandatoryKeys;

  @override
  String? get title => $value.title;
}
