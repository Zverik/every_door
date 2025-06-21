import 'dart:async';
import 'dart:io';

import 'package:every_door/models/plugin.dart';
import 'package:every_door/providers/plugin_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'package:every_door/helpers/yaml_map.dart';

final pluginRepositoryProvider =
    NotifierProvider<PluginRepository, List<Plugin>>(PluginRepository.new);

class PluginRepository extends Notifier<List<Plugin>> {
  static final _logger = Logger('PluginRepository');
  late final Directory _pluginsDirectory;

  @override
  List<Plugin> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final docDir = await getApplicationDocumentsDirectory();
    _pluginsDirectory = Directory("${docDir.path}/plugins");

    // Create plugins dir if not exists.
    await _pluginsDirectory.create(recursive: true);

    // Read plugins list.
    final plugins = <Plugin>[];
    await for (final entry in _pluginsDirectory.list()) {
      if (entry is Directory) {
        try {
          final metadata = await readPluginData(entry);
          plugins.add(Plugin.fromData(metadata, entry));
        } on PluginLoadException catch (e) {
          _logger.severe('Failed to load plugin metadata', e);
        }
      }
    }

    _installFromAssets();

    state = plugins;
  }

  Future<void> deletePlugin(String id) async {
    final plugin = state.where((p) => p.id == id).firstOrNull;
    if (plugin == null) return;

    ref.read(pluginManagerProvider.notifier).setStateAndSave(plugin, false);
    state = state.where((p) => p.id != id).toList();
    final pluginDir = _getPluginDirectory(id);
    if (await pluginDir.exists()) {
      await pluginDir.delete(recursive: true);
    }
  }

  Future<void> _installFromAssets() async {
    ByteData pluginFile;
    try {
      pluginFile = await rootBundle.load('assets/plugin.edp');
    } on FlutterError {
      // No plugin packaged.
      return;
    }

    final tmpDir = await getTemporaryDirectory();
    final File tmpPath = File('${tmpDir.path}/bundled_plugin.zip');
    await tmpPath.writeAsBytes(pluginFile.buffer.asUint8List(), flush: true);

    try {
      await install(tmpPath);
    } on PluginLoadException catch (e) {
      _logger.warning('Failed to install a bundled plugin', e);
    } finally {
      try {
        await tmpPath.delete();
      } on Exception {
        // it's fine if we leave it.
      }
    }
  }

  Directory _getPluginDirectory(String id) {
    return Directory("${_pluginsDirectory.path}/$id");
  }

  /// Reads the YAML file bundled with the plugin, and returns
  /// the plugin identifier, and the rest of the metadata.
  Future<PluginData> readPluginData(Directory path) async {
    // Read the metadata.
    final metadataFile = File("${path.path}/plugin.yaml");
    if (!await metadataFile.exists()) {
      throw PluginLoadException("No ${path.path}/plugin.yaml found");
    }

    // Parse the metadata.yaml file.
    final metadataContents = await metadataFile.readAsString();
    final yamlData = loadYamlNode(metadataContents);
    if (yamlData is! YamlMap) {
      throw PluginLoadException('Metadata should contain a map.');
    }
    final Map<String, dynamic> metadata = yamlData.toMap();

    // Check for required fields.
    final String? pluginId = metadata['id'];
    if (pluginId == null) {
      throw PluginLoadException("Missing plugin id in metadata");
    }

    // Validate the plugin id.
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]+$').hasMatch(pluginId)) {
      throw PluginLoadException("Plugin id \"$pluginId\" has bad characters.");
    }

    return PluginData(pluginId, metadata);
  }

  /// Unpacks the provided archive at [file] into a temporary directory,
  /// and returns the directory. The caller is responsible for deleting
  /// the directory afterwards. Calling [installFromTmpDir] also works.
  /// The installation process is split in two parts, so that you could
  /// call [readPluginData] in between and decide whether you want to continue.
  ///
  /// May throw [PluginLoadException] when file operations go wrong.
  Future<Directory> unpackAndDelete(File file) async {
    if (!await file.exists()) {
      throw PluginLoadException("File is missing: ${file.path}");
    }

    // Unpack the file.
    final tmpDir = await getTemporaryDirectory();
    final tmpPluginDir = await tmpDir.createTemp("plugin");
    try {
      await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: tmpPluginDir,
      );
    } on PlatformException catch (e) {
      tmpPluginDir.delete(recursive: true);
      throw PluginLoadException("Failed to unpack ${file.path}", e);
    }

    // Delete the temporary file if possible.
    if (await file.exists()) {
      try {
        await file.delete();
      } on FileSystemException {
        // Does not matter.
      }
    }

    return tmpPluginDir;
  }

  /// Installs the plugin from the temporary directory. Removes
  /// the directory after either error or success. Will throw
  /// exceptions when either file operations fail, or plugin
  /// cannot be enabled because of internal errors.
  Future<Plugin> installFromTmpDir(Directory tmpPluginDir) async {
    try {
      // Read the metadata.
      final tmpPlugin = await readPluginData(tmpPluginDir);

      // If this plugin was installed, remove it.
      await deletePlugin(tmpPlugin.id);

      // Create the plugin directory and move files there.
      final pluginDir = _getPluginDirectory(tmpPlugin.id);
      await tmpPluginDir.rename(pluginDir.path);

      final data = await readPluginData(pluginDir);
      final plugin = Plugin.fromData(data, pluginDir);

      // Add the plugin record to the list.
      state = state.followedBy([plugin]).toList();

      await ref
          .read(pluginManagerProvider.notifier)
          .setStateAndSave(plugin, true);

      return plugin;
    } finally {
      // delete the directory and exit
      try {
        await tmpPluginDir.delete(recursive: true);
      } on Exception {
        // Oh well, let the trash rest there.
      }
    }
  }

  /// Unpacks the file and installs a plugin from it.
  Future<void> install(File file) async {
    final tmpPluginDir = await unpackAndDelete(file);
    await installFromTmpDir(tmpPluginDir);
  }
}
