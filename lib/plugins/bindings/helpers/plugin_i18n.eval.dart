// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/plugin_i18n.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [PluginLocalizationsBranch]
class $PluginLocalizationsBranch implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
  }

  /// Compile-time type specification of [$PluginLocalizationsBranch]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/plugin_i18n.dart',
    'PluginLocalizationsBranch',
  );

  /// Compile-time type declaration of [$PluginLocalizationsBranch]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginLocalizationsBranch]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
    },

    methods: {
      'translateCtx': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [
            BridgeParameter(
              'args',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
                  ),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'translate': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [
            BridgeParameter(
              'args',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'locale',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:ui', 'Locale'), []),
              ),
              false,
            ),

            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'translateList': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
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

            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final PluginLocalizationsBranch $value;

  @override
  PluginLocalizationsBranch get $reified => $value;

  /// Wrap a [PluginLocalizationsBranch] in a [$PluginLocalizationsBranch]
  $PluginLocalizationsBranch.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'translateCtx':
        return __translateCtx;

      case 'translate':
        return __translate;

      case 'translateList':
        return __translateList;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __translateCtx = $Function(_translateCtx);
  static $Value? _translateCtx(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginLocalizationsBranch;
    final result = self.$value.translateCtx(
      args[0]!.$value,
      args[1]!.$value,
      args: (args[2]?.$reified as Map?)?.cast(),
    );
    return $String(result);
  }

  static const $Function __translate = $Function(_translate);
  static $Value? _translate(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginLocalizationsBranch;
    final result = self.$value.translate(
      args[0]!.$value,
      args[1]!.$value,
      args: (args[2]?.$reified as Map?)?.cast(),
    );
    return $String(result);
  }

  static const $Function __translateList = $Function(_translateList);
  static $Value? _translateList(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginLocalizationsBranch;
    final result = self.$value.translateList(args[0]!.$value, args[1]!.$value);
    return $List.view(result, (e) => $String(e));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
