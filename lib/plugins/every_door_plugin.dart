import 'package:every_door/plugins/interface.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:latlong2/latlong.dart';

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

  /// Configure an editor mode. Called when a user switches to the mode.
  /// You can add buttons and layers here, and configure mode-specific things.
  Future<void> configureMode(EveryDoorApp app, BaseModeDefinition mode) async {}

  /// Download data. Called when a user taps the "download" button.
  /// While the [location] can be found in the [app], it's moved to the
  /// signature to signify its importance. The download radius is up to
  /// the developer.
  Future<void> downloadData(EveryDoorApp app, LatLng location) async {}

  /// Upload data. Called when a user taps the "upload" button.
  Future<void> uploadData(EveryDoorApp app) async {}
}