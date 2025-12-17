// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/helpers/auth/controller.dart';
import 'package:every_door/plugins/bindings/helpers/auth/provider.eval.dart';
import 'package:flutter_eval/foundation.dart';

/// dart_eval wrapper binding for [AuthController]
class $AuthController implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/auth/controller.dart',
      'AuthController.',
      $AuthController.$new,
    );
  }

  /// Compile-time type specification of [$AuthController]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/controller.dart',
    'AuthController',
  );

  /// Compile-time type declaration of [$AuthController]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AuthController]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec(
          'package:flutter/src/foundation/change_notifier.dart',
          'ValueNotifier',
        ),
        [
          BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/auth/provider.dart',
                'UserDetails',
              ),
              [],
            ),
            nullable: true,
          ),
        ],
      ),
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
        isFactory: false,
      ),
    },

    methods: {
      'loadData': BridgeMethodDef(
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

      'login': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
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
          ],
        ),
      ),

      'logout': BridgeMethodDef(
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

      'fetchToken': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'AuthToken',
                  ),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
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
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'getAuthHeaders': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
            ]),
          ),
          namedParams: [],
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
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'getApiKey': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [],
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
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'loadToken': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'AuthToken',
                  ),
                  [],
                ),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'saveToken': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'token',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'AuthToken',
                  ),
                  [],
                ),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'authorized': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'endpoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'tokenKey': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'name': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),

      'provider': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/helpers/auth/provider.dart',
              'AuthProvider',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [AuthController.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $AuthController.wrap(
      AuthController(args[0]!.$value, args[1]!.$value),
    );
  }

  final $Instance _superclass;

  @override
  final AuthController $value;

  @override
  AuthController get $reified => $value;

  /// Wrap a [AuthController] in a [$AuthController]
  $AuthController.wrap(this.$value) : _superclass = $ValueNotifier.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'provider':
        final _provider = $value.provider;
        // return $AuthProvider.wrap(_provider);
        return null;

      case 'authorized':
        final _authorized = $value.authorized;
        return $bool(_authorized);

      case 'endpoint':
        final _endpoint = $value.endpoint;
        return $String(_endpoint);

      case 'tokenKey':
        final _tokenKey = $value.tokenKey;
        return $String(_tokenKey);
      case 'loadData':
        return __loadData;

      case 'login':
        return __login;

      case 'logout':
        return __logout;

      case 'fetchToken':
        return __fetchToken;

      case 'getAuthHeaders':
        return __getAuthHeaders;

      case 'getApiKey':
        return __getApiKey;

      case 'loadToken':
        return __loadToken;

      case 'saveToken':
        return __saveToken;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __loadData = $Function(_loadData);
  static $Value? _loadData(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.loadData();
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __login = $Function(_login);
  static $Value? _login(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthController;
    final result = self.$value.login(args[0]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __logout = $Function(_logout);
  static $Value? _logout(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthController;
    final result = self.$value.logout();
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __fetchToken = $Function(_fetchToken);
  static $Value? _fetchToken(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.fetchToken(args[0]!.$value);
    return $Future.wrap(result.then((e) => $AuthToken.wrap(e)));
  }

  static const $Function __getAuthHeaders = $Function(_getAuthHeaders);
  static $Value? _getAuthHeaders(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.getAuthHeaders(args[0]!.$value);
    return $Future.wrap(result.then((e) => $Map.wrap(e)));
  }

  static const $Function __getApiKey = $Function(_getApiKey);
  static $Value? _getApiKey(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.getApiKey(args[0]!.$value);
    return $Future.wrap(
      result.then((e) => e == null ? const $null() : $String(e)),
    );
  }

  static const $Function __loadToken = $Function(_loadToken);
  static $Value? _loadToken(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.loadToken();
    return $Future.wrap(
      result.then((e) => e == null ? const $null() : $AuthToken.wrap(e)),
    );
  }

  static const $Function __saveToken = $Function(_saveToken);
  static $Value? _saveToken(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthController;
    final result = self.$value.saveToken(args[0]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
