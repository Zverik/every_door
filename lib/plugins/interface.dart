// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/auth/controller.dart';
import 'package:every_door/helpers/auth/provider.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/events.dart';
import 'package:every_door/plugins/ext_overlay.dart';
import 'package:every_door/plugins/preferences.dart';
import 'package:every_door/plugins/providers.dart';
import 'package:every_door/providers/add_presets.dart';
import 'package:every_door/providers/editor_buttons.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/auth.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

/// This class is used by plugins to interact with the app.
/// It might be rebuilt often, and contains references to Riverpod
/// ref and BuildContext (if applicable). And also a ton of convenience
/// methods.
@Bind()
class EveryDoorApp {
  final Ref _ref;
  final Function()? _onRepaint;

  final Plugin plugin;
  final PluginPreferences preferences;
  final PluginProviders providers;
  final PluginEvents events;
  final Logger logger;

  EveryDoorApp({required this.plugin, required Ref ref, Function()? onRepaint})
      : _ref = ref,
        _onRepaint = onRepaint,
        preferences = PluginPreferences(plugin.id, ref),
        providers = PluginProviders(ref),
        events = PluginEvents(plugin.id, ref),
        logger = Logger("Plugin/${plugin.id}");

  // Future<Database> get database => _ref.read(pluginDatabaseProvider).database;

  /// When available, initiates the screen repaint. Useful for updating the
  /// plugin settings screen.
  void repaint() => _onRepaint?.call();

  /// Get the bundled in [Ref] object. Is not available to plugins, which we
  /// are trying to shield from Riverpod (which MAY be a bad idea though).
  Ref get ref => _ref;

  /// Adds an overlay layer. You only need to specify the [Imagery.id]
  /// and [Imagery.buildLayer], but also set the [Imagery.overlay] to true.
  /// For plugins, it would make sense to either use the metadata static file,
  /// or to instantiate [ExtOverlay].
  ///
  /// Unlike the specific mode-bound overlays, those appear everywhere, even
  /// in map-opening fields. If you want to add an overlay just to the main
  /// map, see [PluginEvents.onModeCreated] and [BaseModeDefinition.addOverlay].
  void addOverlay(Imagery imagery) {
    if (!imagery.overlay) {
      throw ArgumentError("Imagery should be an overlay");
    }
    _ref
        .read(overlayImageryProvider.notifier)
        .addLayer(imagery.id, imagery, pluginId: plugin.id);
  }

  /// Adds an editor mode. Cannot replace existing ones, use [removeMode]
  /// for that.
  void addMode(BaseModeDefinition mode) {
    try {
      _ref.read(editorModeProvider.notifier).register(mode);
    } on ArgumentError {
      logger.severe("Failed to add mode ${mode.name}");
    }
  }

  /// Removes the mode. Can remove both a pre-defined mode (like "notes"),
  /// and a plugin-added one.
  void removeMode(String name) {
    _ref.read(editorModeProvider.notifier).unregister(name);
  }

  /// Do something with every mode installed. Useful for dynamically adding
  /// and removing buttons and layers, for example.
  void eachMode(Function(BaseModeDefinition) callback) {
    _ref.read(editorModeProvider.notifier).modes().forEach(callback);
  }

  /// Adds an authentication provider. It is not currently possible
  /// to override an [AuthController]. It is also not possible to
  /// replace the generic providers such as "osm", or use providers
  /// defined in other plugins (because of the mandatory prefix).
  void addAuthProvider(String name, AuthProvider provider) {
    if (provider.title == null) {
      throw ArgumentError("Title is required for a provider");
    }
    _ref
        .read(authProvider.notifier)
        .update(AuthController('${plugin.id}#$name', provider));
  }

  /// Returns a controller for an authentication provider. Use "osm"
  /// to get OSM request headers.
  AuthController auth(String name) =>
      _ref.read(authProvider)['${plugin.id}#$name'] ??
      _ref.read(authProvider)[name]!;

  /// Adds a handler for a new (or existing) field type.
  /// Use [PresetFieldContext] constructor to get commonly used
  /// values from the data.
  void registerFieldType(String fieldType, FieldBuilder builder) {
    _ref
        .read(pluginPresetsProvider)
        .registerFieldType(fieldType, plugin, builder);
  }

  /// Adds a field for an identifier, that is not described as a structure.
  /// That means, it has a key, a label, and everything else already baked-in.
  void registerField(String fieldId, PresetField field) {
    _ref
        .read(pluginPresetsProvider)
        .registerPresetField(fieldId, plugin, field);
  }

  /// Adds a button to the editor pane. Buttons modify some [OsmChange]
  /// object property that is not intuitive to modify with a field.
  void addEditorButton(EditorButton button) {
    _ref.read(editorButtonsProvider.notifier).add(plugin.id, button);
  }
}
