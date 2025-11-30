import 'package:eval_annotation/eval_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

@Bind()
class PluginPreferences {
  final String _pluginId;
  SharedPreferences? _preferences;

  PluginPreferences(this._pluginId);

  Future<SharedPreferences> _sp() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  String _key(String name) => "pp_${_pluginId}_$name";

  Future<void> setString(String name, String value) async {
    await (await _sp()).setString(_key(name), value);
  }

  Future<void> setInt(String name, int value) async =>
      await (await _sp()).setInt(_key(name), value);

  Future<void> setBool(String name, bool value) async =>
      await (await _sp()).setBool(_key(name), value);

  Future<String?> getString(String name) async =>
      (await _sp()).getString(_key(name));
  
  Future<int?> getInt(String name) async =>
      (await _sp()).getInt(_key(name));
  
  Future<bool?> getBool(String name) async =>
      (await _sp()).getBool(_key(name));
}
