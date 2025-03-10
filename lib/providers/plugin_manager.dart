import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/plugin_repo.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
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
    // TODO: use the data from the plugin
    state = state.followedBy([plugin]).toList();
  }

  void _disable(Plugin plugin) {
    if (!state.contains(plugin)) return;
    _disableImagery(plugin);
    _disableElementKinds(plugin);
    _disableModes(plugin);
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
      final data = entry.value as Map<String, dynamic>;
      final url = data['url'] as String;
      final imagery = Imagery(
        id: entry.key,
        name: data['name'] ?? entry.key, // TODO: translatable
        type: data['type'] == 'wms' || url.toLowerCase().contains('service=wms')
            ? ImageryType.wms
            : ImageryType.tms,
        url: url,
        attribution: data['attribution'],
        minZoom: data['minZoom'],
        maxZoom: data['maxZoom'],
        tileSize: data['tileSize'] ?? 256,
        wms4326: data['has4326'] ?? false,
      );
      ref.read(imageryProvider.notifier).registerImagery(imagery);
    }
  }

  void _disableImagery(Plugin plugin) {
    final imageryData = plugin.data['imagery'];
    if (imageryData == null || imageryData is! Map) return;
    for (final entry in imageryData.entries) {
      ref.read(imageryProvider.notifier).unregisterImagery(entry.key);
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
}
