// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:convert' show json;

import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

const _secureStorageRecoveryChannel =
    MethodChannel('info.zverev.ilya.every_door/secure_storage_recovery');

@visibleForTesting
AuthToken? parseStoredAuthToken(String? data, AuthProvider provider) {
  if (data == null) return null;
  try {
    final decoded = json.decode(data);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored token is not a JSON object');
    }
    return provider.tokenFromJson(decoded);
  } on Object {
    return null;
  }
}

/// This controller manages an [AuthProvider], saving a token to the
/// local storage and keeping user details in [value] ready to display.
@Bind()
class AuthController extends ValueNotifier<UserDetails?> {
  static final _logger = Logger("AuthController");

  /// Controller name. Should be overridden, and unique, otherwise
  /// tokens would get mixed up.
  final String name;

  final AuthProvider provider;

  AuthController(this.name, this.provider): super(null) {
    loadData();
  }

  bool get authorized => value != null;

  String get endpoint => provider.endpoint;

  Future<void> loadData() async {
    try {
      final token = await loadToken();
      if (token != null) {
        value = await provider.loadUserDetails(token);
      } else {
        value = null;
      }
    } on AuthException {
      value = null;
    }
  }

  Future<void> login(BuildContext context) async {
    if (value != null) return;
    final token = await provider.login(context);
    if (token != null && token.isValid()) {
      final user = await provider.loadUserDetails(token);
      await saveToken(token);
      value = user;
    }
  }

  Future<void> logout() async {
    final token = await loadToken();
    if (token != null) {
      await provider.logout(token);
      await saveToken(null);
    }
    value = null;
  }

  Future<AuthToken> fetchToken(BuildContext? context) async {
    AuthToken? token = await loadToken();

    if ((token == null || !token.isValid()) &&
        context != null &&
        context.mounted) {
      // We have a context to navigate to the login screen.
      await login(context);
      token = await loadToken();
    }
    if (token == null) {
      value = null;
      throw AuthException("User is not logged in");
    }

    // Okay we got a token, check if it still fits.
    if (token.needsRefresh() || !token.isValid()) {
      token = await provider.refreshToken(token);
      await saveToken(token);
    }

    return token;
  }

  Future<Map<String, String>> getAuthHeaders(BuildContext? context) async {
    final token = await fetchToken(context);
    try {
      final headers = provider.getHeaders(token);
      if (await provider.testHeaders(headers, null)) return headers;
    } on Exception {
      // Do nothing.
    }
    await logout();
    throw AuthException('Could not use the saved token, please re-login.');
  }

  Future<String?> getApiKey(BuildContext? context) async {
    final token = await fetchToken(context);
    try {
      final key = provider.getApiKey(token);
      if (await provider.testHeaders(null, key)) return key;
    } on Exception {
      // Do nothing.
    }
    await logout();
    throw AuthException('Could not use the saved token, please re-login.');
  }

  String get tokenKey => 'authToken_$name';

  Future<AuthToken?> loadToken() async {
    final secure = FlutterSecureStorage();
    String? data;
    try {
      data = await secure.read(key: tokenKey);
    } on PlatformException catch (e) {
      _logger.warning('Failed to read token, resetting secure storage', e);
      await _deleteAllSecure(secure);
    }
    final token = parseStoredAuthToken(data, provider);
    if (data != null && token == null) {
      _logger.warning('Stored token is corrupted, resetting secure storage');
      await _deleteAllSecure(secure);
    }
    return token;
  }

  Future<void> saveToken(AuthToken? token) async {
    final secure = FlutterSecureStorage();
    try {
      if (token == null)
        await secure.delete(key: tokenKey);
      else
        await secure.write(key: tokenKey, value: json.encode(token.toJson()));
    } on PlatformException catch (e) {
      _logger.warning(
          token == null ? 'Failed to delete token' : 'Failed to save token', e);
      await _deleteAllSecure(secure);
      if (token != null) {
        await secure.write(key: tokenKey, value: json.encode(token.toJson()));
      }
    }
  }

  Future<void> _deleteAllSecure(FlutterSecureStorage secure) async {
    try {
      await secure.deleteAll();
    } on PlatformException catch (e) {
      _logger.warning('Failed to reset secure storage', e);
      try {
        await _secureStorageRecoveryChannel.invokeMethod<bool>(
            'clearLegacySecureStorage');
      } on MissingPluginException {
        // Non-Android platforms do not need the shared-preferences fallback.
      } on PlatformException catch (fallbackError) {
        _logger.warning(
            'Failed to reset secure storage with native fallback', fallbackError);
      }
    }
  }
}
