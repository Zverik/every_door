import 'package:every_door/plugins/interface.dart';
import 'package:flutter/material.dart';

/// Parent class for every plugin. None of the methods need to be implemented,
/// although it would be weird.
class EveryDoorPlugin {
  /// Set up listeners and stuff. This gets called when the plugin is enabled,
  /// either during the start-up, or after the installation.
  Future<void> install(EveryDoorApp app) async {}

  /// Uninstall plugin. Usually does not need to be overridden, but can e.g. store
  /// data somewhere. Called when the plugin is manually uninstalled.
  /// NOT called when the app is closed and unloaded.
  Future<void> uninstall(EveryDoorApp app) async {}

  /// Returns a widget for the plugin settings. The best option would be
  /// to return a [Column] with a list of [ListTile].
  /// Use [EveryDoorApp.preferences] for storing those.
  Widget? buildSettingsPane(EveryDoorApp app, BuildContext context) {
    return null;
  }
}
