import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/authorization_response.dart';
import 'package:oauth2_client/interfaces.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/src/oauth2_utils.dart';
import 'package:random_string/random_string.dart';


class OAuth2ClientDebug extends OAuth2Client {
  static final _logger = Logger('OAuth2ClientDebug');

  OAuth2ClientDebug({
    required super.authorizeUrl,
    required super.tokenUrl,
    super.refreshUrl,
    super.revokeUrl,
    required super.redirectUri,
    required super.customUriScheme,
    super.credentialsLocation = CredentialsLocation.header,
    super.scopeSeparator = ' ',
    super.clientIdKey = 'client_id',
    super.clientSecretKey = 'client_secret',
  });

  /// Requests an Access Token to the OAuth2 endpoint using the Authorization Code Flow.
  @override
  Future<AccessTokenResponse> getTokenWithAuthCodeFlow(
      {required String clientId,
        List<String>? scopes,
        String? clientSecret,
        bool enablePKCE = true,
        bool enableState = true,
        String? state,
        String? codeVerifier,
        Function? afterAuthorizationCodeCb,
        Map<String, dynamic>? authCodeParams,
        Map<String, dynamic>? accessTokenParams,
        Map<String, String>? accessTokenHeaders,
        BaseWebAuth? webAuthClient,
        httpClient,
        Map<String, dynamic>? webAuthOpts}) async {
    AccessTokenResponse? tknResp;

    String? codeChallenge;

    if (enablePKCE) {
      codeVerifier ??= randomAlphaNumeric(80);

      codeChallenge = OAuth2Utils.generateCodeChallenge(codeVerifier);
    }

    try {
      var authResp = await requestAuthorization(
          webAuthClient: webAuthClient,
          clientId: clientId,
          scopes: scopes,
          codeChallenge: codeChallenge,
          enableState: enableState,
          state: state,
          customParams: authCodeParams,
          webAuthOpts: webAuthOpts);

      if (authResp.isAccessGranted()) {
        if (afterAuthorizationCodeCb != null) {
          afterAuthorizationCodeCb(authResp);
        }

        _logger.info('OAuth2 access granted');
        tknResp = await requestAccessToken(
            httpClient: httpClient,
            //If the authorization request was successful, the code must be set
            //otherwise an exception is raised in the OAuth2Response constructor
            code: authResp.code!,
            clientId: clientId,
            scopes: scopes,
            clientSecret: clientSecret,
            codeVerifier: codeVerifier,
            customParams: accessTokenParams,
            customHeaders: accessTokenHeaders);
      } else {
        tknResp = AccessTokenResponse.fromMap({
          'http_status_code': 404,
          'error': authResp.error,
          'error_description': authResp.errorDescription,
        });
      }
    } on PlatformException catch(e, stack) {
      _logger.severe('Exception during auth code flow', e, stack);
      tknResp = AccessTokenResponse.fromMap({
        'http_status_code': 404,
        'error': e.toString(),
      });
    }

    return tknResp;
  }

  /// Requests an Authorization Code to be used in the Authorization Code grant.
  @override
  Future<AuthorizationResponse> requestAuthorization(
      {required String clientId,
        List<String>? scopes,
        String? codeChallenge,
        bool enableState = true,
        String? state,
        Map<String, dynamic>? customParams,
        BaseWebAuth? webAuthClient,
        Map<String, dynamic>? webAuthOpts}) async {
    webAuthClient ??= this.webAuthClient;

    if (enableState) {
      state ??= randomAlphaNumeric(25);
    }

    final authorizeUrl = getAuthorizeUrl(
        clientId: clientId,
        redirectUri: redirectUri,
        scopes: scopes,
        enableState: enableState,
        state: state,
        codeChallenge: codeChallenge,
        customParams: customParams);

    // Present the dialog to the user
    final result = await webAuthClient.authenticate(
        url: authorizeUrl,
        callbackUrlScheme: customUriScheme,
        redirectUrl: redirectUri,
        opts: webAuthOpts);

    return AuthorizationResponse.fromRedirectUri(result, state);
  }

  /// Requests and Access Token using the provided Authorization [code].
  @override
  Future<AccessTokenResponse> requestAccessToken(
      {required String code,
        required String clientId,
        String? clientSecret,
        String? codeVerifier,
        List<String>? scopes,
        Map<String, dynamic>? customParams,
        Map<String, String>? customHeaders,
        httpClient}) async {
    final params = getTokenUrlParams(
        code: code,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
        customParams: customParams);

    var response = await _performAuthorizedRequest(
        url: tokenUrl,
        clientId: clientId,
        clientSecret: clientSecret,
        params: params,
        headers: customHeaders,
        httpClient: httpClient);

    return http2TokenResponse(response, requestedScopes: scopes);
  }

  /// Refreshes an Access Token issuing a refresh_token grant to the OAuth2 server.
  @override
  Future<AccessTokenResponse> refreshToken(String refreshToken,
      {httpClient,
        required String clientId,
        String? clientSecret,
        List<String>? scopes}) async {
    final Map params = getRefreshUrlParams(refreshToken: refreshToken);

    var response = await _performAuthorizedRequest(
        url: _getRefreshUrl(),
        clientId: clientId,
        clientSecret: clientSecret,
        params: params,
        httpClient: httpClient);

    return http2TokenResponse(response, requestedScopes: scopes);
  }

  /// Performs a post request to the specified [url],
  /// adding authentication credentials as described here: https://tools.ietf.org/html/rfc6749#section-2.3
  Future<http.Response> _performAuthorizedRequest(
      {required String url,
        required String clientId,
        String? clientSecret,
        Map? params,
        Map<String, String>? headers,
        httpClient}) async {
    httpClient ??= http.Client();

    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      ...(headers ?? {})
    };
    params ??= {};

    //If a client secret has been specified, it will be sent in the "Authorization" header instead of a body parameter...
    if (clientSecret == null) {
      if (clientId.isNotEmpty) {
        params[clientIdKey] = clientId;
      }
    } else {
      switch (credentialsLocation) {
        case CredentialsLocation.header:
          headers.addAll(getAuthorizationHeader(
            clientId: clientId,
            clientSecret: clientSecret,
          ));
          break;
        case CredentialsLocation.body:
          params[clientIdKey] = clientId;
          params[clientSecretKey] = clientSecret;
          break;
      }
    }

    // This is a very semi-optimal way to work around the following issue:
    // https://github.com/dart-lang/http/issues/184
    var response = await httpClient.post(Uri.parse(url),
        body: utf8.encode(params.entries
            .map((e) => '${Uri.encodeQueryComponent(e.key, encoding: utf8)}'
            '=${Uri.encodeQueryComponent(e.value, encoding: utf8)}')
            .join('&')),
        headers: headers);

    return response;
  }

  String _getRefreshUrl() {
    return refreshUrl ?? tokenUrl;
  }
}
