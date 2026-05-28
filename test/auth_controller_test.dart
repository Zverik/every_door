import 'package:every_door/helpers/auth/controller.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

class FakeToken extends AuthToken {
  const FakeToken(this.value);

  final String value;

  @override
  Map<String, dynamic> toJson() => {'value': value};
}

class FakeProvider extends AuthProvider {
  const FakeProvider();

  @override
  String get endpoint => 'example.test';

  @override
  AuthToken tokenFromJson(Map<String, dynamic> data) {
    final value = data['value'];
    if (value is! String) throw const FormatException('Missing value');
    return FakeToken(value);
  }

  @override
  Future<AuthToken?> login(BuildContext context) async => null;

  @override
  Future<UserDetails> loadUserDetails(AuthToken token) async =>
      const UserDetails(displayName: 'test');

  @override
  Future<bool> testHeaders(Map<String, String>? headers, String? apiKey) async =>
      true;
}

void main() {
  const provider = FakeProvider();

  test('parses a stored auth token', () {
    final token = parseStoredAuthToken('{"value":"ok"}', provider);
    final fakeToken = token as FakeToken;

    expect(fakeToken.value, equals('ok'));
  });

  test('ignores non-json secure storage recovery marker', () {
    final token = parseStoredAuthToken('Data has been reset', provider);

    expect(token, isNull);
  });

  test('ignores malformed stored auth token', () {
    expect(parseStoredAuthToken('{', provider), isNull);
    expect(parseStoredAuthToken('[]', provider), isNull);
    expect(parseStoredAuthToken('{"other":"value"}', provider), isNull);
  });
}
