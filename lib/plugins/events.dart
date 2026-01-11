// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/providers/events.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

/// Plugin events wrapper. Use this class to listen to events. Listeners
/// are automatically deactivated when the plugin is inactive. All callback
/// should be asynchronous functions, even when they don't use await.
@Bind()
class PluginEvents {
  final String _pluginId;
  final Ref _ref;

  const PluginEvents(this._pluginId, this._ref);

  /// Listen to editing mode instantiations. The [callback] is called on
  /// each mode when initializing the plugin, and then every time a new
  /// mode is added. The [callback] should be an async function.
  void onModeCreated(Function(BaseModeDefinition mode) callback) {
    _ref.read(eventsProvider.notifier).onModeCreated(_pluginId, callback);
  }

  /// Invoked when the "upload" button is pressed.
  void onUpload(Function() callback) {
    _ref.read(eventsProvider.notifier).onUpload(_pluginId, callback);
  }

  /// Invoked when the "download" button is pressed.
  void onDownload(Function(LatLng) callback) {
    _ref.read(eventsProvider.notifier).onDownload(_pluginId, callback);
  }

  /// Invoked when the editor pane prepares its fields. Here you can
  /// insert or replace some fields, even the entire page.
  void onEditorFields(EditorFieldsCallback callback) {
    _ref.read(eventsProvider.notifier).onEditorFields(_pluginId, callback);
  }
}