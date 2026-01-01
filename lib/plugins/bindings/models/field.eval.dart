// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/field.dart';
import 'package:country_coder/country_coder.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/amenity.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:flutter_map_eval/country_coder/country_coder_eval.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';

/// dart_eval wrapper binding for [FieldPrerequisite]
class $FieldPrerequisite implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/field.dart',
      'FieldPrerequisite.',
      $FieldPrerequisite.$new,
    );

    runtime.registerBridgeFunc(
      'package:every_door/models/field.dart',
      'FieldPrerequisite.fromJson',
      $FieldPrerequisite.$fromJson,
    );
  }

  /// Compile-time type specification of [$FieldPrerequisite]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/field.dart',
    'FieldPrerequisite',
  );

  /// Compile-time type declaration of [$FieldPrerequisite]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$FieldPrerequisite]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'values',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'keyNot',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'valuesNot',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
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
      'matches': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'key': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'keyNot': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'values': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'valuesNot': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [FieldPrerequisite.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $FieldPrerequisite.wrap(
      FieldPrerequisite(
        key: args[0]?.$value,
        values: (args[1]?.$reified as List?)?.cast(),
        keyNot: args[2]?.$value,
        valuesNot: (args[3]?.$reified as List?)?.cast(),
      ),
    );
  }

  /// Wrapper for the [FieldPrerequisite.fromJson] constructor
  static $Value? $fromJson(
    Runtime runtime,
    $Value? thisValue,
    List<$Value?> args,
  ) {
    return $FieldPrerequisite.wrap(
      FieldPrerequisite.fromJson((args[0]!.$reified as Map).cast()),
    );
  }

  final $Instance _superclass;

  @override
  final FieldPrerequisite $value;

  @override
  FieldPrerequisite get $reified => $value;

  /// Wrap a [FieldPrerequisite] in a [$FieldPrerequisite]
  $FieldPrerequisite.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'key':
        final _key = $value.key;
        return _key == null ? const $null() : $String(_key);

      case 'keyNot':
        final _keyNot = $value.keyNot;
        return _keyNot == null ? const $null() : $String(_keyNot);

      case 'values':
        final _values = $value.values;
        return _values == null
            ? const $null()
            : $List.view(_values, (e) => $String(e));

      case 'valuesNot':
        final _valuesNot = $value.valuesNot;
        return _valuesNot == null
            ? const $null()
            : $List.view(_valuesNot, (e) => $String(e));
      case 'matches':
        return __matches;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __matches = $Function(_matches);
  static $Value? _matches(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $FieldPrerequisite;
    final result = self.$value.matches((args[0]!.$reified as Map).cast());
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval bridge binding for [PresetField]
class $PresetField$bridge extends PresetField with $Bridge<PresetField> {
  /// Forwarded constructor for [PresetField.new]
  $PresetField$bridge({
    required super.key,
    required super.label,
    super.icon,
    super.placeholder,
    super.prerequisite,
    super.locationSet,
  });

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$PresetField$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/field.dart',
    'PresetField',
  );

  /// Compile-time type declaration of [$PresetField$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PresetField]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
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
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'buildWidget': BridgeMethodDef(
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
          namedParams: [],
          params: [
            BridgeParameter(
              'element',
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

      'hasRelevantKey': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {
      'key': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'label': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'icon': BridgeFieldDef(
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
        isStatic: false,
      ),

      'placeholder': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'prerequisite': BridgeFieldDef(
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
    },
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'key':
        final _key = super.key;
        return $String(_key);

      case 'label':
        final _label = super.label;
        return $String(_label);

      case 'icon':
        final _icon = super.icon;
        return _icon == null ? const $null() : $IconData.wrap(_icon);

      case 'placeholder':
        final _placeholder = super.placeholder;
        return _placeholder == null ? const $null() : $String(_placeholder);

      case 'prerequisite':
        final _prerequisite = super.prerequisite;
        return _prerequisite == null
            ? const $null()
            : $FieldPrerequisite.wrap(_prerequisite);

      case 'locationSet':
        final _locationSet = super.locationSet;
        return _locationSet == null
            ? const $null()
            : $LocationSet.wrap(_locationSet);
      case 'hasRelevantKey':
        return $Function((runtime, target, args) {
          final result = super.hasRelevantKey(
            (args[1]!.$reified as Map).cast(),
          );
          return $bool(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  String get key => $_get('key');

  @override
  String get label => $_get('label');

  @override
  IconData? get icon => $_get('icon');

  @override
  String? get placeholder => $_get('placeholder');

  @override
  FieldPrerequisite? get prerequisite => $_get('prerequisite');

  @override
  LocationSet? get locationSet => $_get('locationSet');

  @override
  Widget buildWidget(OsmChange element) =>
      $_invoke('buildWidget', [$OsmChange.wrap(element)]);

  @override
  bool hasRelevantKey(Map<String, String> tags) =>
      $_invoke('hasRelevantKey', [$Map.wrap(tags)]);
}

/// dart_eval wrapper binding for [PresetField]
class $PresetField implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/field.dart',
    'PresetField',
  );

  final $Instance _superclass;

  @override
  final PresetField $value;

  @override
  PresetField get $reified => $value;

  /// Wrap a [PresetField] in a [$PresetField]
  $PresetField.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'key':
        final _key = $value.key;
        return $String(_key);

      case 'label':
        final _label = $value.label;
        return $String(_label);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $IconData.wrap(_icon);

      case 'placeholder':
        final _placeholder = $value.placeholder;
        return _placeholder == null ? const $null() : $String(_placeholder);

      case 'prerequisite':
        final _prerequisite = $value.prerequisite;
        return _prerequisite == null
            ? const $null()
            : $FieldPrerequisite.wrap(_prerequisite);

      case 'locationSet':
        final _locationSet = $value.locationSet;
        return _locationSet == null
            ? const $null()
            : $LocationSet.wrap(_locationSet);
      case 'buildWidget':
        return __buildWidget;

      case 'hasRelevantKey':
        return __hasRelevantKey;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __buildWidget = $Function(_buildWidget);
  static $Value? _buildWidget(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PresetField;
    final result = self.$value.buildWidget(args[0]!.$value);
    return $Widget.wrap(result);
  }

  static const $Function __hasRelevantKey = $Function(_hasRelevantKey);
  static $Value? _hasRelevantKey(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PresetField;
    final result = self.$value.hasRelevantKey(
      (args[0]!.$reified as Map).cast(),
    );
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [PresetFieldContext]
class $PresetFieldContext implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/field.dart',
      'PresetFieldContext.',
      $PresetFieldContext.$new,
    );
  }

  /// Compile-time type specification of [$PresetFieldContext]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/field.dart',
    'PresetFieldContext',
  );

  /// Compile-time type declaration of [$PresetFieldContext]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PresetFieldContext]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
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
        isFactory: false,
      ),
    },

    methods: {},
    getters: {},
    setters: {},
    fields: {
      'key': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'label': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'placeholder': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'prerequisite': BridgeFieldDef(
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
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PresetFieldContext.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PresetFieldContext.wrap(
      PresetFieldContext((args[0]!.$reified as Map).cast()),
    );
  }

  final $Instance _superclass;

  @override
  final PresetFieldContext $value;

  @override
  PresetFieldContext get $reified => $value;

  /// Wrap a [PresetFieldContext] in a [$PresetFieldContext]
  $PresetFieldContext.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'key':
        final _key = $value.key;
        return $String(_key);

      case 'label':
        final _label = $value.label;
        return $String(_label);

      case 'placeholder':
        final _placeholder = $value.placeholder;
        return _placeholder == null ? const $null() : $String(_placeholder);

      case 'prerequisite':
        final _prerequisite = $value.prerequisite;
        return _prerequisite == null
            ? const $null()
            : $FieldPrerequisite.wrap(_prerequisite);

      case 'locationSet':
        final _locationSet = $value.locationSet;
        return _locationSet == null
            ? const $null()
            : $LocationSet.wrap(_locationSet);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'key':
        $value.key = value.$value;
        return;

      case 'label':
        $value.label = value.$value;
        return;

      case 'placeholder':
        $value.placeholder = value.$value;
        return;

      case 'prerequisite':
        $value.prerequisite = value.$value;
        return;

      case 'locationSet':
        $value.locationSet = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
