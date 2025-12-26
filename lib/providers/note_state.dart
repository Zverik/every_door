// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
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
