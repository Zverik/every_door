// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/generated/l10n/app_localizations.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:flutter/material.dart';

class StoredPassword extends AuthToken {
  final String login;
  final String password;

  const StoredPassword(this.login, this.password);

  @override
  Map<String, dynamic> toJson() => {
        'login': login,
        'password': password,
      };

  factory StoredPassword.fromJson(Map<String, dynamic> data) =>
      StoredPassword(data['login'], data['password']);
}

/// Authentication provider for services requiring a login and a password.
/// Presents a panel to enter those. An implementing subclass should
/// provide a method to make a login request, query for the user data,
/// and maybe for logging out. Usually such servers use a basic auth
/// header, or a cookie.
abstract class PasswordAuthProvider extends AuthProvider {
  @override
  AuthToken tokenFromJson(Map<String, dynamic> data) =>
      StoredPassword.fromJson(data);

  @override
  Future<AuthToken?> login(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    bool done = false;
    List<String>? result;
    while (!done) {
      if (!context.mounted) return null;
      result = await showTextInputDialog(
        context: context,
        title: loc.accountPasswordTitle,
        textFields: [
          DialogTextField(
            hintText: loc.accountFieldLogin,
            initialText: result?[0] ?? '',
          ),
          DialogTextField(
            hintText: loc.accountFieldPassword,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),
        ],
      );
      if (result != null) {
        final token = StoredPassword(result[0], result[1]);
        final correct = await testHeaders(getHeaders(token), getApiKey(token));
        if (correct) return token;
        // Wrong login
        if (context.mounted) {
          await showAlertDialog(
            context: context,
            title: loc.accountAuthErrorTitle,
            message: loc.accountAuthErrorMessage,
          );
        }
      } else {
        done = true;
      }
    }
    return null;
  }
}
