// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/auth/controller.eval.dart';
import 'package:every_door/plugins/bindings/models/plugin.eval.dart';
import 'package:every_door/plugins/bindings/plugins/events.eval.dart';
import 'package:every_door/plugins/bindings/plugins/preferences.eval.dart';
import 'package:every_door/plugins/bindings/plugins/providers.eval.dart';
import 'package:every_door/plugins/bindings/screens/modes/definitions/base.eval.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:flutter_map_eval/logging/logging_eval.dart';

/// dart_eval wrapper binding for [EveryDoorApp]
class $EveryDoorApp implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$EveryDoorApp]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/interface.dart',
    'EveryDoorApp',
  );

  /// Compile-time type declaration of [$EveryDoorApp]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$EveryDoorApp]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'repaint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [],
        ),
      ),
      'addOverlay': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'imagery',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/imagery.dart',
                    'Imagery',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),
      'addMode': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'mode',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/screens/modes/definitions/base.dart',
                    'BaseModeDefinition',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),
      'removeMode': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'eachMode': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'callback',
              BridgeTypeAnnotation(
                BridgeTypeRef.genericFunction(
                  BridgeFunctionDef(
                    returns: BridgeTypeAnnotation(
                      BridgeTypeRef(CoreTypes.dynamic),
                    ),
                    params: [
                      BridgeParameter(
                        '',
                        BridgeTypeAnnotation(
                          BridgeTypeRef(
                            BridgeTypeSpec(
                              'package:every_door/screens/modes/definitions/base.dart',
                              'BaseModeDefinition',
                            ),
                            [],
                          ),
                        ),
                        false,
                      ),
                    ],
                    namedParams: [],
                  ),
                ),
              ),
              false,
            ),
          ],
        ),
      ),
      'addAuthProvider': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'provider',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'AuthProvider',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),
      'auth': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/auth/controller.dart',
                'AuthController',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
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
      'plugin': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:every_door/models/plugin.dart', 'Plugin'),
            [],
          ),
        ),
        isStatic: false,
      ),
      'onRepaint': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef.genericFunction(
            BridgeFunctionDef(
              returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
              params: [],
              namedParams: [],
            ),
          ),
          nullable: true,
        ),
        isStatic: false,
      ),
      'preferences': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/plugins/preferences.dart',
              'PluginPreferences',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
      'providers': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/plugins/providers.dart',
              'PluginProviders',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
      'events': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/plugins/events.dart',
              'PluginEvents',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
      'logger': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec('package:logging/src/logger.dart', 'Logger'),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final EveryDoorApp $value;

  @override
  EveryDoorApp get $reified => $value;

  /// Wrap a [EveryDoorApp] in a [$EveryDoorApp]
  $EveryDoorApp.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'plugin':
        final _plugin = $value.plugin;
        return $Plugin.wrap(_plugin);

      case 'onRepaint':
        final _onRepaint = $value.onRepaint;
        return _onRepaint == null
            ? const $null()
            : $Function((runtime, target, args) {
                final funcResult = _onRepaint();
                return $Object(funcResult);
              });

      case 'preferences':
        final _preferences = $value.preferences;
        return $PluginPreferences.wrap(_preferences);

      case 'providers':
        final _providers = $value.providers;
        return $PluginProviders.wrap(_providers);

      case 'events':
        final _events = $value.events;
        return $PluginEvents.wrap(_events);

      case 'logger':
        final _logger = $value.logger;
        return $Logger.wrap(_logger);

      case 'repaint':
        return __repaint;

      case 'addOverlay':
        return __addOverlay;

      case 'addMode':
        return __addMode;

      case 'removeMode':
        return __removeMode;

      case 'eachMode':
        return __eachMode;

      case 'addAuthProvider':
        return __addAuthProvider;

      case 'auth':
        return __auth;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __repaint = $Function(_repaint);
  static $Value? _repaint(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $EveryDoorApp;
    self.$value.repaint();
    return null;
  }

  static const $Function __addOverlay = $Function(_addOverlay);
  static $Value? _addOverlay(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $EveryDoorApp;
    self.$value.addOverlay(args[0]!.$value);
    return null;
  }

  static const $Function __addMode = $Function(_addMode);
  static $Value? _addMode(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $EveryDoorApp;
    self.$value.addMode(args[0]!.$value);
    return null;
  }

  static const $Function __removeMode = $Function(_removeMode);
  static $Value? _removeMode(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $EveryDoorApp;
    self.$value.removeMode(args[0]!.$value);
    return null;
  }

  static const $Function __eachMode = $Function(_eachMode);
  static $Value? _eachMode(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $EveryDoorApp;
    self.$value.eachMode((BaseModeDefinition arg0) {
      return (args[0]! as EvalCallable)(runtime, null, [
        $BaseModeDefinition.wrap(arg0),
      ])?.$value;
    });
    return null;
  }

  static const $Function __addAuthProvider = $Function(_addAuthProvider);
  static $Value? _addAuthProvider(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $EveryDoorApp;
    self.$value.addAuthProvider(args[0]!.$value, args[1]!.$value);
    return null;
  }

  static const $Function __auth = $Function(_auth);
  static $Value? _auth(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $EveryDoorApp;
    final result = self.$value.auth(args[0]!.$value);
    return $AuthController.wrap(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
