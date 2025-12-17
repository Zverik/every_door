// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:every_door/plugins/bindings/plugins/interface.eval.dart';

/// dart_eval bridge binding for [EveryDoorPlugin]
class $EveryDoorPlugin$bridge extends EveryDoorPlugin
    with $Bridge<EveryDoorPlugin> {
  /// Forwarded constructor for [EveryDoorPlugin.new]
  $EveryDoorPlugin$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/plugins/every_door_plugin.dart',
      'EveryDoorPlugin.',
      $EveryDoorPlugin$bridge.$new,
      isBridge: true,
    );
  }

  /// Compile-time type specification of [$EveryDoorPlugin$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/every_door_plugin.dart',
    'EveryDoorPlugin',
  );

  /// Compile-time type declaration of [$EveryDoorPlugin$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$EveryDoorPlugin]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'install': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'app',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/plugins/interface.dart',
                    'EveryDoorApp',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'uninstall': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'app',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/plugins/interface.dart',
                    'EveryDoorApp',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'buildSettingsPane': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/widgets/framework.dart',
                'Widget',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'app',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/plugins/interface.dart',
                    'EveryDoorApp',
                  ),
                  [],
                ),
              ),
              false,
            ),

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
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  /// Proxy for the [EveryDoorPlugin.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $EveryDoorPlugin$bridge();
  }

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'install':
        return $Function((runtime, target, args) {
          final result = super.install(args[1]!.$value);
          return $Future.wrap(result.then((e) => null));
        });
      case 'uninstall':
        return $Function((runtime, target, args) {
          final result = super.uninstall(args[1]!.$value);
          return $Future.wrap(result.then((e) => null));
        });
      case 'buildSettingsPane':
        return $Function((runtime, target, args) {
          final result = super.buildSettingsPane(
            args[1]!.$value,
            args[2]!.$value,
          );
          return result == null ? const $null() : $Widget.wrap(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  Future<void> install(EveryDoorApp app) =>
      $_invoke('install', [$EveryDoorApp.wrap(app)]);

  @override
  Future<void> uninstall(EveryDoorApp app) =>
      $_invoke('uninstall', [$EveryDoorApp.wrap(app)]);

  @override
  Widget? buildSettingsPane(EveryDoorApp app, BuildContext context) => $_invoke(
    'buildSettingsPane',
    [$EveryDoorApp.wrap(app), $BuildContext.wrap(context)],
  );
}
