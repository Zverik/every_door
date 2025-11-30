import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Bind()
class PluginPreferences {
  final String _pluginId;
  final Ref _ref;

  PluginPreferences(this._pluginId, this._ref);

  String _key(String name) => "pp_${_pluginId}_$name";

  SharedPreferencesWithCache get _sp =>
      _ref.read(sharedPrefsProvider).requireValue;

  Future<void> setString(String name, String value) async {
    await _sp.setString(_key(name), value);
  }

  Future<void> setInt(String name, int value) async =>
      await _sp.setInt(_key(name), value);

  Future<void> setBool(String name, bool value) async =>
      await _sp.setBool(_key(name), value);

  Future<void> setDouble(String name, double value) async =>
      await _sp.setDouble(_key(name), value);

  Future<void> setStringList(String name, List<String> value) async =>
      await _sp.setStringList(_key(name), value);

  String? getString(String name) => _sp.getString(_key(name));

  int? getInt(String name) => _sp.getInt(_key(name));

  bool? getBool(String name) => _sp.getBool(_key(name));

  double? getDouble(String name) => _sp.getDouble(_key(name));

  List<String>? getStringList(String name) => _sp.getStringList(_key(name));
}
