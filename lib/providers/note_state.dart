import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final noteIsOsmProvider =
    NotifierProvider<NoteStateProvider, bool>(NoteStateProvider.new);

class NoteStateProvider extends Notifier<bool> {
  static const kPrefsKey = 'is_osm_note';

  @override
  bool build() {
    _loadValue();
    return false;
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    bool? newOSM = prefs.getBool(kPrefsKey);
    if (newOSM != null && newOSM != state) state = newOSM;
  }

  Future<void> _storeValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefsKey, state);
  }

  void set(bool noteIsOsm) {
    state = noteIsOsm;
    _storeValue();
  }
}
