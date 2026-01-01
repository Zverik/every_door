// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:flutter/material.dart';

/// Authentication token class. Should be subclasses to contain actual
/// token data. It's a good idea to add a factory constructor
/// [AuthToken.fromJson] to keep serialization and deserialization in one place.
@Bind(wrap: true, bridge: true)
abstract class AuthToken {
  const AuthToken();

  /// Serialize token contents into a json, to store on the device.
  Map<String, dynamic> toJson();

  /// Checks whether the token is valid. Should return false if anything
  /// in the token data prompts it won't work.
  bool isValid() => true;

  /// Check whether the token is obsolete. If the token has an expiration
  /// date, override this method.
  bool needsRefresh() => false;
}

/// A base class for user details. Override to add more, e.g. an avatar.
@Bind(bridge: true, wrap: true)
class UserDetails {
  final String displayName;
  const UserDetails({required this.displayName});
}

/// An exception thrown when the authentication goes wrong.
/// Please do not forget to provide a message.
@Bind(bridge: true)
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException($message)';
}

/// Authentication provider base class. Should know how to login and
/// to get user details. Also stores an [endpoint] for making calls.
@Bind(bridge: true, wrap: true)
abstract class AuthProvider {
  /// A constant constructor doing nothing. A provider should not have a state.
  const AuthProvider();

  /// Service endpoint to make requests.
  String get endpoint;

  /// A title for the settings panel.
  String? get title => null;

  /// An icon for the settings panel.
  MultiIcon? get icon => null;

  /// Unpack token retrieved from a secure storage.
  AuthToken tokenFromJson(Map<String, dynamic> data);

  /// Open a login panel, perform the authentication, and receive
  /// a token.
  /// Should return [null] if the process was manually cancelled,
  /// or throw an [AuthException] if it failed.
  Future<AuthToken?> login(BuildContext context);

  /// In case a token can become obsolete, implement this method.
  Future<AuthToken> refreshToken(AuthToken token) async {
    throw AuthException("Tokens cannot be refreshed");
  }

  /// If needed, inform the server to log the user out.
  Future<void> logout(AuthToken token) async {}

  /// Returns headers to be added to an API request.
  /// Usually this adds a single "Authentication" header,
  /// but this depends on the API.
  ///
  /// See also [getApiKey], one of those should be implemented.
  Map<String, String> getHeaders(AuthToken token) {
    throw AuthException("Headers cannot be built");
  }

  /// Returns a string to be supplied to API, if it needs one.
  ///
  /// See also [getHeaders], one of those should be implemented.
  String getApiKey(AuthToken token) {
    throw AuthException("API key cannot be generated");
  }

  /// Makes a query to the server asking for user details.
  /// It gets called when opening the app, and after logging in.
  ///
  /// If the request fails, throw an [AuthException].
  Future<UserDetails> loadUserDetails(AuthToken token);

  /// Test the auth credentials. Should return [true] if they work.
  Future<bool> testHeaders(Map<String, String>? headers, String? apiKey);
}
