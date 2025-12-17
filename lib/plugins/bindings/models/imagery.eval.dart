// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/imagery.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval enum wrapper binding for [ImageryCategory]
class $ImageryCategory implements $Instance {
  /// Configure this enum for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeEnumValues(
      'package:every_door/models/imagery.dart',
      'ImageryCategory',
      $ImageryCategory._$values,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/imagery.dart',
      'ImageryCategory.values*g',
      $ImageryCategory.$values,
    );
  }

  /// Compile-time type specification of [$ImageryCategory]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/imagery.dart',
    'ImageryCategory',
  );

  /// Compile-time type declaration of [$ImageryCategory]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ImageryCategory]
  static const $declaration = BridgeEnumDef(
    $type,

    values: ['photo', 'map', 'other'],

    methods: {},
    getters: {},
    setters: {},
    fields: {},
  );

  static final _$values = {
    'photo': $ImageryCategory.wrap(ImageryCategory.photo),
    'map': $ImageryCategory.wrap(ImageryCategory.map),
    'other': $ImageryCategory.wrap(ImageryCategory.other),
  };

  /// Wrapper for the [ImageryCategory.values] getter
  static $Value? $values(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = ImageryCategory.values;
    return $List.view(value, (e) => $ImageryCategory.wrap(e));
  }

  final $Instance _superclass;

  @override
  final ImageryCategory $value;

  @override
  ImageryCategory get $reified => $value;

  /// Wrap a [ImageryCategory] in a [$ImageryCategory]
  $ImageryCategory.wrap(this.$value) : _superclass = $Object($value);

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

/// dart_eval wrapper binding for [Imagery]
class $Imagery implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$Imagery]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/imagery.dart',
    'Imagery',
  );

  /// Compile-time type declaration of [$Imagery]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Imagery]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
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
              'category',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/imagery.dart',
                    'ImageryCategory',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'name',
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
              'attribution',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'best',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),

            BridgeParameter(
              'overlay',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'initialize': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'buildLayer': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/widgets/framework.dart',
                'Widget',
              ),
              [],
            ),
          ),
          namedParams: [
            BridgeParameter(
              'reset',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'category': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/imagery.dart',
              'ImageryCategory',
            ),
            [],
          ),
          nullable: true,
        ),
        isStatic: false,
      ),

      'name': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
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

      'attribution': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'best': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'overlay': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final Imagery $value;

  @override
  Imagery get $reified => $value;

  /// Wrap a [Imagery] in a [$Imagery]
  $Imagery.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return $String(_id);

      case 'category':
        final _category = $value.category;
        return _category == null
            ? const $null()
            : $ImageryCategory.wrap(_category);

      case 'name':
        final _name = $value.name;
        return _name == null ? const $null() : $String(_name);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'attribution':
        final _attribution = $value.attribution;
        return _attribution == null ? const $null() : $String(_attribution);

      case 'best':
        final _best = $value.best;
        return $bool(_best);

      case 'overlay':
        final _overlay = $value.overlay;
        return $bool(_overlay);
      case 'initialize':
        return __initialize;

      case 'buildLayer':
        return __buildLayer;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __initialize = $Function(_initialize);
  static $Value? _initialize(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Imagery;
    final result = self.$value.initialize();
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __buildLayer = $Function(_buildLayer);
  static $Value? _buildLayer(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Imagery;
    final result = self.$value.buildLayer(reset: args[0]?.$value ?? false);
    return $Widget.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
