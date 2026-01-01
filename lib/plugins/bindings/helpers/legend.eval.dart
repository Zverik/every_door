// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/legend.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:flutter_eval/foundation.dart';
import 'package:flutter_eval/src/sky_engine/ui/painting.dart';

/// dart_eval wrapper binding for [LegendItem]
class $LegendItem implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/legend.dart',
      'LegendItem.',
      $LegendItem.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/helpers/legend.dart',
      'LegendItem.other',
      $LegendItem.$other,
    );
  }

  /// Compile-time type specification of [$LegendItem]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/legend.dart',
    'LegendItem',
  );

  /// Compile-time type declaration of [$LegendItem]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$LegendItem]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
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
              'label',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),

      'other': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'label',
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
      'color': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
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

      'label': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'isOther': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [LegendItem.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $LegendItem.wrap(
      LegendItem(
        color: args[0]?.$value,
        icon: args[1]?.$value,
        label: args[2]!.$value,
      ),
    );
  }

  /// Wrapper for the [LegendItem.other] constructor
  static $Value? $other(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $LegendItem.wrap(LegendItem.other(args[0]!.$value));
  }

  final $Instance _superclass;

  @override
  final LegendItem $value;

  @override
  LegendItem get $reified => $value;

  /// Wrap a [LegendItem] in a [$LegendItem]
  $LegendItem.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'color':
        final _color = $value.color;
        return _color == null ? const $null() : $Color.wrap(_color);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'label':
        final _label = $value.label;
        return $String(_label);

      case 'isOther':
        final _isOther = $value.isOther;
        return $bool(_isOther);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [NamedColor]
class $NamedColor implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/legend.dart',
      'NamedColor.',
      $NamedColor.$new,
    );
  }

  /// Compile-time type specification of [$NamedColor]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/legend.dart',
    'NamedColor',
  );

  /// Compile-time type declaration of [$NamedColor]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$NamedColor]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
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
      'name': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [NamedColor.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $NamedColor.wrap(NamedColor(args[0]!.$value, args[1]!.$value));
  }

  final $Instance _superclass;

  @override
  final NamedColor $value;

  @override
  NamedColor get $reified => $value;

  /// Wrap a [NamedColor] in a [$NamedColor]
  $NamedColor.wrap(this.$value) : _superclass = $Color.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'name':
        final _name = $value.name;
        return $String(_name);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [PresetLabel]
class $PresetLabel implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/legend.dart',
      'PresetLabel.',
      $PresetLabel.$new,
    );
  }

  /// Compile-time type specification of [$PresetLabel]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/legend.dart',
    'PresetLabel',
  );

  /// Compile-time type declaration of [$PresetLabel]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PresetLabel]
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
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'label',
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
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'label': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PresetLabel.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PresetLabel.wrap(PresetLabel(args[0]!.$value, args[1]!.$value));
  }

  final $Instance _superclass;

  @override
  final PresetLabel $value;

  @override
  PresetLabel get $reified => $value;

  /// Wrap a [PresetLabel] in a [$PresetLabel]
  $PresetLabel.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return $String(_id);

      case 'label':
        final _label = $value.label;
        return $String(_label);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [LegendController]
class $LegendController implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/legend.dart',
      'LegendController.kLegendColors*g',
      $LegendController.$kLegendColors,
    );
  }

  /// Compile-time type specification of [$LegendController]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/legend.dart',
    'LegendController',
  );

  /// Compile-time type declaration of [$LegendController]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$LegendController]
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
    ),
    constructors: {
    },

    methods: {
      'fixPreset': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [
            BridgeParameter(
              'color',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Color'), []),
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
          ],
          params: [
            BridgeParameter(
              'preset',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'resetFixes': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),

      'updateLegend': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'locale',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Locale'), []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'maxItems',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'amenities',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.iterable, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:every_door/models/located.dart',
                        'Located',
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

      'getLegendItem': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/legend.dart',
                'LegendItem',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'amenity',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/located.dart',
                    'Located',
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
      'legend': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/legend.dart',
                    'LegendItem',
                  ),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'iconsInLegend': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),

      'kLegendColors': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(
              BridgeTypeRef(
                BridgeTypeSpec(
                  'package:every_door/helpers/legend.dart',
                  'NamedColor',
                ),
                [],
              ),
            ),
          ]),
        ),
        isStatic: true,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [LegendController.kLegendColors] getter
  static $Value? $kLegendColors(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final value = LegendController.kLegendColors;
    return $List.view(value, (e) => $NamedColor.wrap(e));
  }

  final $Instance _superclass;

  @override
  final LegendController $value;

  @override
  LegendController get $reified => $value;

  /// Wrap a [LegendController] in a [$LegendController]
  $LegendController.wrap(this.$value)
    : _superclass = $ChangeNotifier.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'iconsInLegend':
        final _iconsInLegend = $value.iconsInLegend;
        return $bool(_iconsInLegend);

      case 'legend':
        final _legend = $value.legend;
        return $List.view(_legend, (e) => $LegendItem.wrap(e));
      case 'fixPreset':
        return __fixPreset;

      case 'resetFixes':
        return __resetFixes;

      case 'updateLegend':
        return __updateLegend;

      case 'getLegendItem':
        return __getLegendItem;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __fixPreset = $Function(_fixPreset);
  static $Value? _fixPreset(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LegendController;
    self.$value.fixPreset(
      args[0]!.$value,
      color: args[1]?.$value,
      icon: args[2]?.$value,
    );
    return null;
  }

  static const $Function __resetFixes = $Function(_resetFixes);
  static $Value? _resetFixes(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LegendController;
    self.$value.resetFixes();
    return null;
  }

  static const $Function __updateLegend = $Function(_updateLegend);
  static $Value? _updateLegend(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LegendController;
    final result = self.$value.updateLegend(
      (args[0]!.$reified as List).cast(),
      locale: args[1]?.$value,
      maxItems: args[2]?.$value ?? 6,
    );
    return $Future.wrap(result.then((e) => $Object(e)));
  }

  static const $Function __getLegendItem = $Function(_getLegendItem);
  static $Value? _getLegendItem(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $LegendController;
    final result = self.$value.getLegendItem(args[0]!.$value);
    return result == null ? const $null() : $LegendItem.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'iconsInLegend':
        $value.iconsInLegend = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
