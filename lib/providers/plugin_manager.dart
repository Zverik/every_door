import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/geojson.dart';
import 'package:every_door/models/imagery/mbtiles.dart';
import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/models/imagery/vector.dart';
import 'package:every_door/models/imagery/vector/style_reader.dart';
import 'package:every_door/models/imagery/wms.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/add_presets.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/providers/shared_file.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
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
    ref.listen(pluginRepositoryProvider, (old, list) async {
      if (old == null || old.isEmpty) {
        await loadStateAndEnable();
        return;
      }

      // When plugins are removed, we need to disable them.
      for (final p in old) {
        if (!list.contains(p)) _disable(p);
      }
      for (final p in list) {
        if (!old.contains(p)) await _enable(p);
      }
    });
    return [];
  }

  Future<void> loadStateAndEnable() async {
    // Read enabled list.
    final prefs = await SharedPreferences.getInstance();
    final enabledList = prefs.getStringList(_kEnabledKey);
    if (enabledList == null) return;

    final enabledPlugins = ref
        .read(pluginRepositoryProvider)
        .where((p) => enabledList.contains(p.id));

    // Enable plugins.
    for (final plugin in enabledPlugins) {
      await _enable(plugin, true);
    }

    // This is very deep, because we need everything set up before
    // we can process incoming files.
    ref.read(sharedFileProvider).checkInitialMedia();
  }

  Future<void> _saveEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledList = state.map((p) => p.id).toList();
    enabledList.sort();
    _logger.info('Saving enabled plugins: $enabledList');
    await prefs.setStringList(_kEnabledKey, enabledList);
  }

  Future<void> _enable(Plugin plugin, [bool force = false]) async {
    if (!force && state.contains(plugin)) return;
    try {
      _enableElementKinds(plugin);
      _enableModes(plugin);
      _enableFields(plugin);
      _enablePresets(plugin);
      await _enableImagery(plugin);
    } catch (e) {
      // Installation failed, revert.
      _technicallyDisable(plugin);
      rethrow;
    }
    plugin.active = true;
    // TODO: use the data from the plugin
    state = state.followedBy([plugin]).toList();
  }

  void _technicallyDisable(Plugin plugin) {
    _disableElementKinds(plugin);
    _disableModes(plugin);
    _disablePresets(plugin);
    _disableFields(plugin);
    _disableImagery(plugin);
  }

  void _disable(Plugin plugin) {
    if (!state.contains(plugin)) return;
    _technicallyDisable(plugin);
    plugin.active = false;
    // TODO: clear the data from the plugin
    state = state.where((p) => p.id != plugin.id).toList();
  }

  Future<void> setStateAndSave(Plugin id, bool active) async {
    if (!active) {
      _disable(id);
    } else {
      await _enable(id);
    }
    await _saveEnabled();
  }

  Future<void> _enableImagery(Plugin plugin) async {
    final imageryData = plugin.data['imagery'];
    if (imageryData != null && imageryData is Map) {
      for (final entry in imageryData.entries) {
        final imagery = await _imageryFromMap(entry.key, entry.value, plugin);
        if (imagery == null) {
          _logger.warning('Failed to parse imagery ${entry.key}');
          continue;
        }

        if (entry.key == 'base') {
          ref.read(baseImageryProvider.notifier).set(imagery);
        } else {
          final bool force = imageryData['force'] == true;
          ref.read(imageryProvider.notifier).registerImagery(imagery, force);
        }
      }
    }

    final overlayData = plugin.data['overlays'];
    if (overlayData != null && overlayData is List) {
      for (final entry in overlayData.asMap().entries) {
        if (entry.value is! Map<String, dynamic>) continue;
        final key = 'plugin_${plugin.id}_${entry.key}';
        final imagery = await _imageryFromMap(key, entry.value, plugin);
        if (imagery != null) {
          Set<String>? modes;
          final modesData = entry.value['modes'];
          if (modesData is String)
            modes = {modesData};
          else if (modesData is Iterable)
            modes = modesData.map((i) => i.toString()).toSet();

          ref
              .read(overlayImageryProvider.notifier)
              .addLayer(key, imagery, modes);
        }
      }
    }
  }

  Future<Imagery?> _imageryFromMap(
      String key, Map<String, dynamic> data, Plugin plugin, [bool isBase = false]) async {
    final String url = data['url'] as String;
    final bool isURL = url.startsWith('http://') || url.startsWith('https://');
    final String? ext = url.contains('.')
        ? url.substring(url.lastIndexOf('.') + 1).toLowerCase()
        : null;
    final String? typ = data['type'] as String?;

    final tmi = TileImageryData(
      id: key,
      name: data['name'] ?? key, // TODO: translatable
      url: url,
      attribution: data['attribution'],
      minZoom: data['minZoom'],
      maxZoom: data['maxZoom'],
      tileSize: data['tileSize'] ?? 256,
      headers: data['headers'] is Map ? data['headers'] : null,
    );

    if (typ == 'geojson' || ext == 'geojson' || ext == 'json') {
      return GeoJsonImagery(
        id: tmi.id,
        category: tmi.category,
        name: tmi.name,
        icon: tmi.icon,
        attribution: tmi.attribution,
        source: isURL
            ? NetworkGeoJson(url, headers: tmi.headers ?? const {})
            : FileGeoJson(plugin.resolvePath(url)),
      );
    }

    if (typ == 'vector') {
      return VectorImagery(
        id: tmi.id,
        category: tmi.category,
        name: tmi.name,
        icon: tmi.icon,
        attribution: tmi.attribution,
        url: url,
        apiKey: data['key'],
        fast: data['fast'] != false,
        plugin: plugin,
        headers: tmi.headers,
      );
    }

    if (isURL) {
      if (typ == 'wms' || url.toLowerCase().contains('service=wms')) {
        return WmsImagery.from(tmi, wms4326: data['has4326'] ?? false);
      } else if (typ == 'tms' ||
          url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.endsWith('.png')) {
        return TmsImagery.from(tmi);
      }
    } else {
      if (typ == 'mbtiles' || ext == 'mbtiles') {
        final mbtiles = plugin.resolvePath(url);
        if (mbtiles.existsSync()) {
          return MbTilesImagery.from(tmi,
              mbtiles: MbTiles(mbtilesPath: mbtiles.path, gzip: false));
        } else {
          throw ArgumentError('File $mbtiles does not exist.');
        }
      }
    }

    _logger.severe('Could not understand imagery $key for plugin ${plugin.id}');
    return null;
  }

  void _disableImagery(Plugin plugin) {
    final imageryData = plugin.data['imagery'];
    if (imageryData != null && imageryData is Map) {
      for (final entry in imageryData.entries) {
        if (entry.key == 'base') {
          ref.read(baseImageryProvider.notifier).revert();
        } else {
          ref.read(imageryProvider.notifier).unregisterImagery(entry.key);
        }
      }
    }

    final overlayData = plugin.data['overlays'];
    if (overlayData != null) {
      ref
          .read(overlayImageryProvider.notifier)
          .removeLayers('plugin_${plugin.id}_');
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
        _enableElementKinds(otherPlugin);
      }
    }
  }

  void _enableModes(Plugin plugin) {
    final modeData = plugin.data['modes'];
    if (modeData == null || modeData is! Map) return;
    for (final entry in modeData.entries) {
      if (entry.value is! Map) {
        throw ArgumentError('Data for mode ${entry.key} is not a map');
      }
      final modeParams = entry.value as Map<String, dynamic>;

      final modeProvider = ref.read(editorModeProvider.notifier);
      final oldMode = modeProvider.get(entry.key);
      _logger.fine('Looking for mode ${entry.key}: $oldMode');
      if (oldMode != null) {
        if (modeParams['hide'] == true) {
          modeProvider.unregister(entry.key);
        } else {
          oldMode.updateFromJson(modeParams, plugin);
        }
        continue;
      }

      BaseModeDefinition mode;
      final modeType = modeParams['type'];
      switch (modeType) {
        case 'entrances':
          mode = EntrancesModeCustom(
              ref: ref, name: entry.key, data: modeParams, plugin: plugin);
        case 'micro':
          mode = MicromappingModeCustom(
              ref: ref, name: entry.key, data: modeParams, plugin: plugin);
        // TODO: amenity and notes
        default:
          throw ArgumentError(
              'Unknown or unsupported mode type for ${entry.key}: "$modeType"');
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
        _enableModes(otherPlugin);
      }
    }
  }

  void _enableFields(Plugin plugin) {
    final fieldData = plugin.data['fields'];
    if (fieldData == null || fieldData is! Map) return;
    final prov = ref.read(pluginPresetsProvider);
    fieldData.forEach((k, data) {
      prov.addField(
          k, data, plugin, plugin.getLocalizationsBranch('fields.$k'));
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
      prov.addPreset(
          k, data, plugin, plugin.getLocalizationsBranch('presets.$k'));
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
