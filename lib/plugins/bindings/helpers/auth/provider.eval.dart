import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:flutter/material.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval bridge binding for [AuthToken]
class $AuthToken$bridge extends AuthToken with $Bridge<AuthToken> {
  /// Forwarded constructor for [AuthToken.new]
  $AuthToken$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$AuthToken$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'AuthToken',
  );

  /// Compile-time type declaration of [$AuthToken$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AuthToken]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
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
      'toJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.map, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'isValid': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
      'needsRefresh': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'isValid':
        return $Function((runtime, target, args) {
          final result = super.isValid();
          return $bool(result);
        });
      case 'needsRefresh':
        return $Function((runtime, target, args) {
          final result = super.needsRefresh();
          return $bool(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  Map<String, dynamic> toJson() => ($_invoke('toJson', []) as Map).cast();

  @override
  bool isValid() => $_invoke('isValid', []);

  @override
  bool needsRefresh() => $_invoke('needsRefresh', []);
}

/// dart_eval wrapper binding for [AuthToken]
class $AuthToken implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'AuthToken',
  );

  final $Instance _superclass;

  @override
  final AuthToken $value;

  @override
  AuthToken get $reified => $value;

  /// Wrap a [AuthToken] in a [$AuthToken]
  $AuthToken.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'toJson':
        return __toJson;

      case 'isValid':
        return __isValid;

      case 'needsRefresh':
        return __needsRefresh;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __toJson = $Function(_toJson);
  static $Value? _toJson(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthToken;
    final result = self.$value.toJson();
    return $Map.wrap(result);
  }

  static const $Function __isValid = $Function(_isValid);
  static $Value? _isValid(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthToken;
    final result = self.$value.isValid();
    return $bool(result);
  }

  static const $Function __needsRefresh = $Function(_needsRefresh);
  static $Value? _needsRefresh(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthToken;
    final result = self.$value.needsRefresh();
    return $bool(result);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval bridge binding for [UserDetails]
class $UserDetails$bridge extends UserDetails with $Bridge<UserDetails> {
  /// Forwarded constructor for [UserDetails.new]
  $UserDetails$bridge({required super.displayName});

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/auth/provider.dart',
      'UserDetails.',
      $UserDetails$bridge.$new,
      isBridge: true,
    );
  }

  /// Compile-time type specification of [$UserDetails$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'UserDetails',
  );

  /// Compile-time type declaration of [$UserDetails$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$UserDetails]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'displayName',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
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
      'displayName': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
    },
    wrap: false,
    bridge: true,
  );

  /// Proxy for the [UserDetails.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $UserDetails$bridge(displayName: args[0]!.$value);
  }

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'displayName':
        final _displayName = super.displayName;
        return $String(_displayName);
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  String get displayName => $_get('displayName');
}

/// dart_eval wrapper binding for [UserDetails]
class $UserDetails implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'UserDetails',
  );

  final $Instance _superclass;

  @override
  final UserDetails $value;

  @override
  UserDetails get $reified => $value;

  /// Wrap a [UserDetails] in a [$UserDetails]
  $UserDetails.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'displayName':
        final _displayName = $value.displayName;
        return $String(_displayName);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval bridge binding for [AuthException]
class $AuthException$bridge extends AuthException with $Bridge<AuthException> {
  /// Forwarded constructor for [AuthException.new]
  $AuthException$bridge(super.message);

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/helpers/auth/provider.dart',
      'AuthException.',
      $AuthException$bridge.$new,
      isBridge: true,
    );
  }

  /// Compile-time type specification of [$AuthException$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'AuthException',
  );

  /// Compile-time type declaration of [$AuthException$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AuthException]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,
      $implements: [BridgeTypeRef(CoreTypes.exception, [])],
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [
            BridgeParameter(
              'message',
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
      'message': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
    },
    wrap: false,
    bridge: true,
  );

  /// Proxy for the [AuthException.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $AuthException$bridge(args[0]!.$value);
  }

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'message':
        final _message = super.message;
        return $String(_message);
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  String get message => $_get('message');
}

/// dart_eval bridge binding for [AuthProvider]
class $AuthProvider$bridge extends AuthProvider with $Bridge<AuthProvider> {
  /// Forwarded constructor for [AuthProvider.new]
  $AuthProvider$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$AuthProvider$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'AuthProvider',
  );

  /// Compile-time type declaration of [$AuthProvider$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$AuthProvider]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
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
      'tokenFromJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/auth/provider.dart',
                'AuthToken',
              ),
              [],
            ),
          ),
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
      ),
      'login': BridgeMethodDef(
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
      'refreshToken': BridgeMethodDef(
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
              'token',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'AuthToken',
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
              ),
              false,
            ),
          ],
        ),
      ),
      'getHeaders': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.map, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
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
              ),
              false,
            ),
          ],
        ),
      ),
      'getApiKey': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
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
              ),
              false,
            ),
          ],
        ),
      ),
      'loadUserDetails': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/auth/provider.dart',
                    'UserDetails',
                  ),
                  [],
                ),
              ),
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
              ),
              false,
            ),
          ],
        ),
      ),
      'testHeaders': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'headers',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              false,
            ),
            BridgeParameter(
              'apiKey',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'endpoint': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
      'title': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'icon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/multi_icon.dart',
                'MultiIcon',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    switch (identifier) {
      case 'title':
        final _title = super.title;
        return _title == null ? const $null() : $String(_title);

      case 'icon':
        final _icon = super.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);
      case 'refreshToken':
        return $Function((runtime, target, args) {
          final result = super.refreshToken(args[1]!.$value);
          return $Future.wrap(result.then((e) => $AuthToken.wrap(e)));
        });
      case 'logout':
        return $Function((runtime, target, args) {
          final result = super.logout(args[1]!.$value);
          return $Future.wrap(result.then((e) => null));
        });
      case 'getHeaders':
        return $Function((runtime, target, args) {
          final result = super.getHeaders(args[1]!.$value);
          return $Map.wrap(result);
        });
      case 'getApiKey':
        return $Function((runtime, target, args) {
          final result = super.getApiKey(args[1]!.$value);
          return $String(result);
        });
    }
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  String get endpoint => $_get('endpoint');

  @override
  String? get title => $_get('title');

  @override
  MultiIcon? get icon => $_get('icon');

  @override
  AuthToken tokenFromJson(Map<String, dynamic> data) =>
      $_invoke('tokenFromJson', [$Map.wrap(data)]);

  @override
  Future<AuthToken?> login(BuildContext context) =>
      $_invoke('login', [$BuildContext.wrap(context)]);

  @override
  Future<AuthToken> refreshToken(AuthToken token) =>
      $_invoke('refreshToken', [$AuthToken.wrap(token)]);

  @override
  Future<void> logout(AuthToken token) =>
      $_invoke('logout', [$AuthToken.wrap(token)]);

  @override
  Map<String, String> getHeaders(AuthToken token) =>
      ($_invoke('getHeaders', [$AuthToken.wrap(token)]) as Map).cast();

  @override
  String getApiKey(AuthToken token) =>
      $_invoke('getApiKey', [$AuthToken.wrap(token)]);

  @override
  Future<UserDetails> loadUserDetails(AuthToken token) =>
      $_invoke('loadUserDetails', [$AuthToken.wrap(token)]);

  @override
  Future<bool> testHeaders(Map<String, String>? headers, String? apiKey) =>
      $_invoke('testHeaders', [
        headers == null ? const $null() : $Map.wrap(headers),
        apiKey == null ? const $null() : $String(apiKey),
      ]);
}

/// dart_eval wrapper binding for [AuthProvider]
class $AuthProvider implements $Instance {
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/provider.dart',
    'AuthProvider',
  );

  final $Instance _superclass;

  @override
  final AuthProvider $value;

  @override
  AuthProvider get $reified => $value;

  /// Wrap a [AuthProvider] in a [$AuthProvider]
  $AuthProvider.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'endpoint':
        final _endpoint = $value.endpoint;
        return $String(_endpoint);

      case 'title':
        final _title = $value.title;
        return _title == null ? const $null() : $String(_title);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);
      case 'tokenFromJson':
        return __tokenFromJson;

      case 'login':
        return __login;

      case 'refreshToken':
        return __refreshToken;

      case 'logout':
        return __logout;

      case 'getHeaders':
        return __getHeaders;

      case 'getApiKey':
        return __getApiKey;

      case 'loadUserDetails':
        return __loadUserDetails;

      case 'testHeaders':
        return __testHeaders;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __tokenFromJson = $Function(_tokenFromJson);
  static $Value? _tokenFromJson(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.tokenFromJson((args[0]!.$reified as Map).cast());
    return $AuthToken.wrap(result);
  }

  static const $Function __login = $Function(_login);
  static $Value? _login(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthProvider;
    final result = self.$value.login(args[0]!.$value);
    return $Future.wrap(
      result.then((e) => e == null ? const $null() : $AuthToken.wrap(e)),
    );
  }

  static const $Function __refreshToken = $Function(_refreshToken);
  static $Value? _refreshToken(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.refreshToken(args[0]!.$value);
    return $Future.wrap(result.then((e) => $AuthToken.wrap(e)));
  }

  static const $Function __logout = $Function(_logout);
  static $Value? _logout(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $AuthProvider;
    final result = self.$value.logout(args[0]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  static const $Function __getHeaders = $Function(_getHeaders);
  static $Value? _getHeaders(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.getHeaders(args[0]!.$value);
    return $Map.wrap(result);
  }

  static const $Function __getApiKey = $Function(_getApiKey);
  static $Value? _getApiKey(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.getApiKey(args[0]!.$value);
    return $String(result);
  }

  static const $Function __loadUserDetails = $Function(_loadUserDetails);
  static $Value? _loadUserDetails(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.loadUserDetails(args[0]!.$value);
    return $Future.wrap(result.then((e) => $UserDetails.wrap(e)));
  }

  static const $Function __testHeaders = $Function(_testHeaders);
  static $Value? _testHeaders(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $AuthProvider;
    final result = self.$value.testHeaders(
      (args[0]!.$reified as Map).cast(),
      args[1]!.$value,
    );
    return $Future.wrap(result.then((e) => $bool(e)));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
