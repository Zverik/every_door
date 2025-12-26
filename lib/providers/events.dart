// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

final eventsProvider =
    NotifierProvider<EventsNotifier, List<_EventListener>>(EventsNotifier.new);

abstract class _EventData {}

enum _EventType {
  downloading,
  postProcessDownload,
  uploading,
  preProcessUpload,
  modeCreated,
}

class _EventDataModeCreated implements _EventData {
  final BaseModeDefinition mode;
  const _EventDataModeCreated(this.mode);
}

class _EventDataDownload implements _EventData {
  final LatLng location;
  const _EventDataDownload(this.location);
}

class _EventListener {
  final String? pluginId;
  final _EventType type;
  final Future<dynamic> Function(_EventData?) callback;

  const _EventListener(
      {this.pluginId, required this.type, required this.callback});
}

class EventsNotifier extends Notifier<List<_EventListener>> {
  @override
  List<_EventListener> build() => [];

  void clear() {
    state = [];
  }

  void removePluginEvents(String pluginId) {
    state = state.where((e) => e.pluginId != pluginId).toList();
  }

  void onModeCreated(String? pluginId, Function(BaseModeDefinition) callback) {
    state = state +
        [
          _EventListener(
            pluginId: pluginId,
            type: _EventType.modeCreated,
            callback: (data) => callback((data as _EventDataModeCreated).mode),
          )
        ];
  }

  Future<void> callModeCreated(BaseModeDefinition mode,
      [String? pluginId]) async {
    for (final e in state) {
      if (e.type == _EventType.modeCreated &&
          (pluginId == null || e.pluginId == pluginId)) {
        await e.callback(_EventDataModeCreated(mode));
      }
    }
  }

  void onUpload(String? pluginId, Function() callback) {
    state = state +
        [
          _EventListener(
            pluginId: pluginId,
            type: _EventType.uploading,
            callback: (data) => callback(),
          )
        ];
  }

  Future<void> callUpload() async {
    final tasks = state
        .where((e) => e.type == _EventType.uploading)
        .map((e) => e.callback(null));
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  void onDownload(String? pluginId, Function(LatLng) callback) {
    state = state +
        [
          _EventListener(
            pluginId: pluginId,
            type: _EventType.downloading,
            callback: (data) => callback((data as _EventDataDownload).location),
          )
        ];
  }

  Future<void> callDownload(LatLng location) async {
    final tasks = state
        .where((e) => e.type == _EventType.downloading)
        .map((e) => e.callback(_EventDataDownload(location)));
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }
}
