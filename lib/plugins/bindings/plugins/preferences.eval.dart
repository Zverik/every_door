// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/preferences.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [PluginPreferences]
class $PluginPreferences implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$PluginPreferences]
  static const $spec = BridgeTypeSpec(
    'package:every_door/plugins/preferences.dart',
    'PluginPreferences',
  );

  /// Compile-time type declaration of [$PluginPreferences]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginPreferences]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'setString': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'setInt': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
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
      ),
      'setBool': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
      ),
      'setDouble': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double, [])),
              false,
            ),
          ],
        ),
      ),
      'setStringList': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),
          ],
        ),
      ),
      'getString': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
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
      'getInt': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.int, []),
            nullable: true,
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
      'getBool': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.bool, []),
            nullable: true,
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
      'getDouble': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.double, []),
            nullable: true,
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
      'getStringList': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
            nullable: true,
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
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final PluginPreferences $value;

  @override
  PluginPreferences get $reified => $value;

  /// Wrap a [PluginPreferences] in a [$PluginPreferences]
  $PluginPreferences.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'setString':
        return __setString;

      case 'setInt':
        return __setInt;

      case 'setBool':
        return __setBool;

      case 'setDouble':
        return __setDouble;

      case 'setStringList':
        return __setStringList;

      case 'getString':
        return __getString;

      case 'getInt':
        return __getInt;

      case 'getBool':
        return __getBool;

      case 'getDouble':
        return __getDouble;

      case 'getStringList':
        return __getStringList;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __setString = $Function(_setString);
  static $Value? _setString(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.setString(args[0]!.$value, args[1]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __setInt = $Function(_setInt);
  static $Value? _setInt(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $PluginPreferences;
    final result = self.$value.setInt(args[0]!.$value, args[1]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __setBool = $Function(_setBool);
  static $Value? _setBool(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $PluginPreferences;
    final result = self.$value.setBool(args[0]!.$value, args[1]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __setDouble = $Function(_setDouble);
  static $Value? _setDouble(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.setDouble(args[0]!.$value, args[1]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __setStringList = $Function(_setStringList);
  static $Value? _setStringList(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.setStringList(
      args[0]!.$value,
      (args[1]!.$reified as List).cast(),
    );
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __getString = $Function(_getString);
  static $Value? _getString(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.getString(args[0]!.$value);
    return result == null ? const $null() : $String(result);
  }

  static const $Function __getInt = $Function(_getInt);
  static $Value? _getInt(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $PluginPreferences;
    final result = self.$value.getInt(args[0]!.$value);
    return result == null ? const $null() : $int(result);
  }

  static const $Function __getBool = $Function(_getBool);
  static $Value? _getBool(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $PluginPreferences;
    final result = self.$value.getBool(args[0]!.$value);
    return result == null ? const $null() : $bool(result);
  }

  static const $Function __getDouble = $Function(_getDouble);
  static $Value? _getDouble(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.getDouble(args[0]!.$value);
    return result == null ? const $null() : $double(result);
  }

  static const $Function __getStringList = $Function(_getStringList);
  static $Value? _getStringList(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $PluginPreferences;
    final result = self.$value.getStringList(args[0]!.$value);
    return result == null
        ? const $null()
        : $List.view(result, (e) => $String(e));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
