import 'dart:io';

import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/add_presets.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pluginManagerProvider =
    NotifierProvider<PluginManager, List<Plugin>>(PluginManager.new);

class PluginManager extends Notifier<List<Plugin>> {
  static final _logger = Logger('PluginManager');

  static const _kEnabledKey = 'plugins_enabled';

  @override
  List<Plugin> build() {
    ref.listen(pluginRepositoryProvider, (old, list) {
      if (old == null || old.isEmpty) {
        loadStateAndEnable();
        return;
      }

      // When plugins are removed, we need to disable them.
      for (final p in old) {
        if (!list.contains(p)) _disable(p);
      }
      for (final p in list) {
        if (!old.contains(p)) _enable(p);
      }
    });
    return [];
  }

  void loadStateAndEnable() async {
    // Read enabled list.
    final prefs = await SharedPreferences.getInstance();
    final enabledList = prefs.getStringList(_kEnabledKey);
    if (enabledList == null) return;

    final enabledPlugins = ref
        .read(pluginRepositoryProvider)
        .where((p) => enabledList.contains(p.id));

    // Enable plugins.
    for (final plugin in enabledPlugins) {
      _enable(plugin, true);
    }
  }

  Future<void> _saveEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledList = state.map((p) => p.id).toList();
    enabledList.sort();
    await prefs.setStringList(_kEnabledKey, enabledList);
  }

  void _enable(Plugin plugin, [bool force = false]) {
    if (!force && state.contains(plugin)) return;
    _enableImagery(plugin);
    _enableElementKinds(plugin);
    _enableModes(plugin);
    _enableFields(plugin);
    _enablePresets(plugin);
    // TODO: use the data from the plugin
    state = state.followedBy([plugin]).toList();
  }

  void _disable(Plugin plugin) {
    if (!state.contains(plugin)) return;
    _disableImagery(plugin);
    _disableElementKinds(plugin);
    _disableModes(plugin);
    _disablePresets(plugin);
    _disableFields(plugin);
    // TODO: clear the data from the plugin
    state = state.where((p) => p != plugin).toList();
  }

  Future<void> setStateAndSave(Plugin id, bool active) async {
    if (!active) {
      _disable(id);
    } else {
      _enable(id);
    }
    await _saveEnabled();
  }

  void _enableImagery(Plugin plugin) {
    final imageryData = plugin.data['imagery'];
    if (imageryData == null || imageryData is! Map) return;
    for (final entry in imageryData.entries) {
      final imagery = _imageryFromMap(entry.key, entry.value, plugin);
      if (imagery == null) {
        _logger.warning('Failed to parse imagery ${entry.key}');
        continue;
      }

      if (entry.key == 'base') {
        ref.read(baseImageryProvider.notifier).state = imagery;
      } else {
        ref.read(imageryProvider.notifier).registerImagery(imagery);
      }
    }

    final overlayData = plugin.data['overlays'];
    if (overlayData == null || overlayData is! Map) return;
    for (final entry in overlayData.entries) {
      final imagery = _imageryFromMap(entry.key, entry.value, plugin);
      ref.read(overlayImageryProvider.notifier).addLayer(
            key: entry.key,
            imagery: imagery,
            widget: imagery == null
                ? _widgetFromMap(entry.key, entry.value, plugin)
                : null,
          );
    }
  }

  Widget? _widgetFromMap(String key, Map<String, dynamic> data, Plugin plugin) {
    final url = data['url'] as String;
    if (data['type'] == 'geojson' ||
        url.endsWith('.geojson') ||
        url.endsWith('.json')) {
      final layer = GeoJsonLayer(
        data: FileGeoJson(plugin.resolvePath(url)),
      );
      return layer;
    }
    return null;
  }

  Imagery? _imageryFromMap(
      String key, Map<String, dynamic> data, Plugin plugin) {
    final url = data['url'] as String;

    File? mbtiles;
    ImageryType type;
    if (url.startsWith('http')) {
      if (data['type'] == 'wms' || url.toLowerCase().contains('service=wms')) {
        type = ImageryType.wms;
      } else {
        type = ImageryType.tms;
      }
    } else {
      if (data['type'] == 'mbtiles' || url.toLowerCase().endsWith('.mbtiles')) {
        type = ImageryType.mbtiles;
        mbtiles = plugin.resolvePath(url);
      } else {
        return null;
      }
    }

    final imagery = Imagery(
      id: key,
      name: data['name'] ?? key, // TODO: translatable
      type: type,
      url: url,
      mbtiles: mbtiles != null
          ? MbTiles(mbtilesPath: mbtiles.path, gzip: false)
          : null,
      attribution: data['attribution'],
      minZoom: data['minZoom'],
      maxZoom: data['maxZoom'],
      tileSize: data['tileSize'] ?? 256,
      wms4326: data['has4326'] ?? false,
    );
    return imagery;
  }

  void _disableImagery(Plugin plugin) {
    final imageryData = plugin.data['imagery'];
    if (imageryData == null || imageryData is! Map) return;
    for (final entry in imageryData.entries) {
      if (entry.key == 'base') {
        ref.read(baseImageryProvider.notifier).state = kOSMImagery;
      } else {
        ref.read(imageryProvider.notifier).unregisterImagery(entry.key);
      }
    }

    final overlayData = plugin.data['overlays'];
    if (overlayData == null || overlayData is! Map) return;
    for (final entry in overlayData.entries) {
      ref.read(overlayImageryProvider.notifier).removeLayer(entry.key);
    }
  }

  void _enableElementKinds(Plugin plugin) {
    final kindsData = plugin.data['kinds'];
    if (kindsData == null || kindsData is! Map) return;
    for (final entry in kindsData.entries) {
      final kind = ElementKindImpl.fromJson(entry.key, entry.value);
      ElementKind.register(kind);
    }
  }

  void _disableElementKinds(Plugin plugin) {
    final kindsData = plugin.data['kinds'];
    if (kindsData == null || kindsData is! Map) return;

    // We're just rebuilding the entire tree.
    ElementKind.reset();
    for (final otherPlugin in state) {
      if (plugin.id != otherPlugin.id) {
        _enableElementKinds(plugin);
      }
    }
  }

  void _enableModes(Plugin plugin) {
    final modeData = plugin.data['modes'];
    if (modeData == null || modeData is! Map) return;
    for (final entry in modeData.entries) {
      final modeType = entry.value['type'];
      final modeProvider = ref.read(editorModeProvider.notifier);
      final oldMode = modeProvider.get(entry.key);
      _logger.info('Looking for ${entry.key} of type $modeType: $oldMode');
      if (oldMode != null) {
        oldMode.updateFromJson(entry.value, plugin);
        // TODO: replaces
        continue;
      }

      BaseModeDefinition mode;
      switch (modeType) {
        case 'entrances':
          mode = EntrancesModeCustom(
              ref: ref, name: entry.key, data: entry.value, plugin: plugin);
        case 'micro':
          mode = MicromappingModeCustom(
              ref: ref, name: entry.key, data: entry.value, plugin: plugin);
        // TODO: amenity and notes
        default:
          throw ArgumentError(
              'Unknown mode type for ${entry.key}: "$modeType"');
      }
      modeProvider.register(mode);
    }
  }

  void _disableModes(Plugin plugin) {
    final modeData = plugin.data['modes'];
    if (modeData == null || modeData is! Map) return;
    ref.read(editorModeProvider.notifier).reset();
    for (final otherPlugin in state) {
      if (plugin.id != otherPlugin.id) {
        _enableElementKinds(plugin);
      }
    }
  }

  void _enableFields(Plugin plugin) {
    final fieldData = plugin.data['fields'];
    if (fieldData == null || fieldData is! Map) return;
    final prov = ref.read(pluginPresetsProvider);
    fieldData.forEach((k, data) {
      prov.addField(k, data, plugin);
    });
    // TODO
  }

  void _disableFields(Plugin plugin) {
    final fieldData = plugin.data['fields'];
    if (fieldData == null || fieldData is! Map) return;
    final prov = ref.read(pluginPresetsProvider);
    for (final k in fieldData.keys) prov.removeField(k);
    // TODO
  }

  void _enablePresets(Plugin plugin) {
    final presetData = plugin.data['presets'];
    if (presetData == null || presetData is! Map) return;
    final prov = ref.read(pluginPresetsProvider);
    presetData.forEach((k, data) {
      prov.addPreset(k, data, plugin);
    });
    // TODO
  }

  void _disablePresets(Plugin plugin) {
    final presetData = plugin.data['presets'];
    if (presetData == null || presetData is! Map) return;
    final prov = ref.read(pluginPresetsProvider);
    for (final k in presetData.keys) prov.removePreset(k, plugin);
    // TODO
  }
}
