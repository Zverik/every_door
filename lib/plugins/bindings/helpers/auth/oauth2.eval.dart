// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/helpers/auth/oauth2.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/plugins/bindings/helpers/auth/provider.eval.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval bridge binding for [OAuth2AuthProvider]
class $OAuth2AuthProvider$bridge extends OAuth2AuthProvider
    with $Bridge<OAuth2AuthProvider> {
  /// Forwarded constructor for [OAuth2AuthProvider.new]
  $OAuth2AuthProvider$bridge({
    required super.authorizeUrl,
    required super.tokenUrl,
    required super.clientId,
    required super.clientSecret,
    required super.scopes,
  });

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$OAuth2AuthProvider$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/helpers/auth/oauth2.dart',
    'OAuth2AuthProvider',
  );

  /// Compile-time type declaration of [$OAuth2AuthProvider$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$OAuth2AuthProvider]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'authorizeUrl',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'tokenUrl',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'clientId',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'clientSecret',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),

            BridgeParameter(
              'scopes',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              false,
            ),
          ],
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
      case 'tokenFromJson':
        return $Function((runtime, target, args) {
          final result = super.tokenFromJson((args[1]!.$reified as Map).cast());
          return $AuthToken.wrap(result);
        });
      case 'login':
        return $Function((runtime, target, args) {
          final result = super.login(args[1]!.$value);
          return $Future.wrap(
            result.then((e) => e == null ? const $null() : $AuthToken.wrap(e)),
          );
        });
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
