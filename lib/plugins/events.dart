import 'package:every_door/providers/events.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class PluginEvents {
  final String _pluginId;
  final Ref _ref;

  const PluginEvents(this._pluginId, this._ref);

  void onModeCreated(Function(BaseModeDefinition mode) callback) {
    _ref.read(eventsProvider.notifier).onModeCreated(_pluginId, callback);
  }

  void onUpload(Function() callback) {
    _ref.read(eventsProvider.notifier).onUpload(_pluginId, callback);
  }

  void onDownload(Function(LatLng) callback) {
    _ref.read(eventsProvider.notifier).onDownload(_pluginId, callback);
  }
}