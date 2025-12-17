import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/helpers/oauth2_client_debug.dart';
import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';

class OAuth2Token implements AuthToken {
  final AccessTokenResponse token;

  const OAuth2Token(this.token);

  @override
  Map<String, dynamic> toJson() => token.toMap();

  factory OAuth2Token.fromJson(Map<String, dynamic> data) =>
      OAuth2Token(AccessTokenResponse.fromMap(data));

  @override
  bool isValid() => token.isValid();

  @override
  bool needsRefresh() => token.refreshNeeded();
}

/// Authentication provider for services with OAuth2. Which are
/// basically the most of them, including OpenStreetMap.
@Bind(bridge: true, implicitSupers: true)
abstract class OAuth2AuthProvider extends AuthProvider {
  final OAuth2Client _client;
  final String _clientId;
  final String _clientSecret;
  final List<String> _scopes;

  OAuth2AuthProvider({
    required String authorizeUrl,
    required String tokenUrl,
    required String clientId,
    required String clientSecret,
    required List<String> scopes,
  })  : _client = OAuth2ClientDebug(
          authorizeUrl: authorizeUrl,
          tokenUrl: tokenUrl,
          redirectUri: 'everydoor:/oauth',
          customUriScheme: 'everydoor',
        ),
        _clientId = clientId,
        _clientSecret = clientSecret,
        _scopes = scopes;

  @override
  AuthToken tokenFromJson(Map<String, dynamic> data) =>
      OAuth2Token.fromJson(data);

  @override
  Future<AuthToken?> login(BuildContext context) async {
    final token = await _client.getTokenWithAuthCodeFlow(
      clientId: _clientId,
      clientSecret: _clientSecret,
      enablePKCE: true,
      // enableState: true,
      scopes: _scopes,
    );
    return OAuth2Token(token);
  }

  @override
  Future<void> logout(AuthToken token) async {
    await _client.revokeToken(
      (token as OAuth2Token).token,
      clientId: _clientId,
      clientSecret: _clientSecret,
    );
  }

  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    final refreshToken = (token as OAuth2Token).token.refreshToken;
    if (refreshToken == null) {
      throw AuthException("Refresh token is null");
    }
    final response =
        await _client.refreshToken(refreshToken, clientId: _clientId);
    return OAuth2Token(response);
  }

  @override
  Map<String, String> getHeaders(AuthToken token) =>
      {'Authorization': 'Bearer ${(token as OAuth2Token).token.accessToken}'};
}
