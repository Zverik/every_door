import 'package:every_door/providers/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noteIsOsmProvider =
    NotifierProvider<NoteStateProvider, bool>(NoteStateProvider.new);

class NoteStateProvider extends Notifier<bool> {
  static const kPrefsKey = 'is_osm_note';

  @override
  bool build() {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    bool? newOSM = prefs.getBool(kPrefsKey);
    return newOSM ?? false;
  }

  Future<void> set(bool noteIsOsm) async {
    state = noteIsOsm;
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    await prefs.setBool(kPrefsKey, state);
  }
}
