// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:ui' show Locale;

import 'package:every_door/helpers/editor_fields.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:logging/logging.dart';

final eventsProvider =
    NotifierProvider<EventsNotifier, List<_EventListener>>(EventsNotifier.new);

abstract class _EventData {}

enum _EventType {
  downloading,
  postProcessDownload,
  uploading,
  preProcessUpload,
  modeCreated,
  editorFields,
}

class _EventDataModeCreated implements _EventData {
  final BaseModeDefinition mode;
  const _EventDataModeCreated(this.mode);
}

class _EventDataDownload implements _EventData {
  final LatLng location;
  const _EventDataDownload(this.location);
}

class _EventDataEditorFields implements _EventData {
  final List<EditorFields> fields;
  final OsmChange amenity;
  final Preset preset;
  final Locale locale;

  const _EventDataEditorFields(
      {required this.fields,
      required this.amenity,
      required this.preset,
      required this.locale});
}

typedef EditorFieldsCallback = Future<List<EditorFields>> Function(
    List<EditorFields>, OsmChange, Preset, Locale);

class _EventListener {
  final String? pluginId;
  final _EventType type;
  final Future<dynamic> Function(_EventData?) callback;

  const _EventListener(
      {this.pluginId, required this.type, required this.callback});
}

class EventsNotifier extends Notifier<List<_EventListener>> {
  static final _logger = Logger("EventsNotifier");

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
        try {
          await e.callback(_EventDataModeCreated(mode));
        } on Exception catch (ex, st) {
          _logger.severe("Failed to call ${e.pluginId}.onModeCreated", ex, st);
        }
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
      try {
        await Future.wait(tasks);
      } on Exception catch (e, st) {
        _logger.warning("Some listeners to onUpload failed", e, st);
      }
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
      try {
        await Future.wait(tasks);
      } on Exception catch (e, st) {
        _logger.warning("Some listeners to onDownload failed", e, st);
      }
    }
  }

  void onEditorFields(String? pluginId, EditorFieldsCallback callback) {
    state = state +
        [
          _EventListener(
            pluginId: pluginId,
            type: _EventType.editorFields,
            callback: (data) {
              data as _EventDataEditorFields;
              return callback(
                  data.fields, data.amenity, data.preset, data.locale);
            },
          )
        ];
  }

  Future<List<EditorFields>> callEditorFields(List<EditorFields> fields,
      OsmChange amenity, Preset preset, Locale locale) async {
    for (final task in state) {
      if (task.type == _EventType.editorFields) {
        try {
          fields = await task.callback(_EventDataEditorFields(
            fields: fields,
            amenity: amenity,
            preset: preset,
            locale: locale,
          ));
        } on Exception catch (e, st) {
          _logger.severe("Failed to call ${task.pluginId}.onEditorFields", e, st);
        }
      }
    }
    return fields;
  }
}
