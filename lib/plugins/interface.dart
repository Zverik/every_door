import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/auth/controller.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/database.dart';
import 'package:every_door/plugins/events.dart';
import 'package:every_door/plugins/preferences.dart';
import 'package:every_door/plugins/providers.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/auth.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// This class is used by plugins to interact with the app.
/// It might be rebuilt often, and contains references to Riverpod
/// ref and BuildContext (if applicable). And also a ton of convenience
/// methods.
@Bind()
class EveryDoorApp {
  final Ref _ref;
  final BuildContext? context;
  final Plugin plugin;
  final Function()? onRepaint;

  final PluginPreferences preferences;
  final PluginProviders providers;
  final PluginEvents events;
  final Logger logger;

  EveryDoorApp(
      {required this.plugin, required Ref ref, this.context, this.onRepaint})
      : _ref = ref,
        preferences = PluginPreferences(plugin.id, ref),
        providers = PluginProviders(ref),
        events = PluginEvents(plugin.id, ref),
        logger = Logger("Plugin/${plugin.id}");

  Future<Database> get database => _ref.read(pluginDatabaseProvider).database;

  void repaint() => onRepaint?.call();

  Ref get ref => _ref;

  void addOverlay(Imagery imagery) {
    if (!imagery.overlay) {
      throw ArgumentError("Imagery should be an overlay");
    }
    // TODO
    _ref
        .read(overlayImageryProvider.notifier)
        .addLayer(imagery.id, imagery, pluginId: plugin.id);
  }

  void addMode(BaseModeDefinition mode) {
    try {
      _ref.read(editorModeProvider.notifier).register(mode);
    } on ArgumentError {
      logger.severe("Failed to add mode ${mode.name}");
    }
  }

  void removeMode(String name) {
    _ref.read(editorModeProvider.notifier).unregister(name);
  }

  void eachMode(Function(BaseModeDefinition) callback) {
    _ref.read(editorModeProvider.notifier).modes().forEach(callback);
  }

  void addAuthProvider(String name, AuthProvider provider) {
    if (provider.title == null) {
      throw ArgumentError("Title is required for a provider");
    }
    _ref
        .read(authProvider.notifier)
        .update(AuthController('${plugin.id}#$name', provider));
  }

  AuthController auth(String name) =>
      _ref.read(authProvider)['${plugin.id}#$name']!;
}
