// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/auth/controller.dart';
import 'package:every_door/helpers/auth/osm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider =
    NotifierProvider<AuthMapController, Map<String, AuthController>>(
        AuthMapController.new);

class AuthMapController extends Notifier<Map<String, AuthController>> {
  @override
  Map<String, AuthController> build() {
    final osm = AuthController(
        'osm',
        OsmAuthProvider(
          clientId: 'r_ZDi6JezDDBHj8WSU286d5A7FntAJSMpkB2FGEcaG8',
          clientSecret: 'DRFc8pDeGt4D2E3j-WdfdTq02o_fnek-WQeWgvXfvTg',
          endpoint: 'api.openstreetmap.org',
          authEndpoint: 'www.openstreetmap.org',
        ));
    osm.addListener(onValueChanged);
    return {'osm': osm};
  }

  OsmUserDetails? get osmUser => state['osm']?.value as OsmUserDetails?;

  void update(AuthController controller) {
    if (controller.name == 'osm') {
      // TODO: clear everything
      throw ArgumentError("Cannot replace the OSM auth provider for now");
    }

    final old = state[controller.name];
    if (old != null) {
      old.removeListener(onValueChanged);
    }
    controller.addListener(onValueChanged);
    final newState = Map.of(state);
    newState[controller.name] = controller;
    state = newState;
  }

  void remove(String name) {
    if (!state.containsKey(name)) return;
    final newState = Map.of(state);
    final old = newState.remove(name);
    old?.removeListener(onValueChanged);
    state = newState;
  }

  void removePrefixed(String prefix) {
    final newState = Map.of(state);
    newState.forEach((k, v) {
      if (k.startsWith(prefix)) v.removeListener(onValueChanged);
    });
    newState.removeWhere((k, v) => k.startsWith(prefix));
    if (newState.length == state.length) return;
    state = newState;
  }

  void onValueChanged() {
    // Trigger the notify, given the comparison function is [identical].
    state = Map.of(state);
  }
}
