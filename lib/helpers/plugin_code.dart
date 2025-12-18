import 'dart:io';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_security.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/every_door_plugin.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_map_eval/flutter_map_eval.dart' as fme;
import 'package:every_door/plugins/bindings/every_door_eval.dart' as ede;

/// Static class (no instance methods) to work with plugin code.
/// Compiling and executing.
class PluginCode {
  static final _logger = Logger('PluginCode');

  static Compiler? _compiler;

  static Compiler get compiler {
    if (_compiler == null) {
      final compiler = Compiler();
      compiler.addPlugin(flutterEvalPlugin);
      for (final p in fme.plugins) compiler.addPlugin(p);
      compiler.addPlugin(ede.EveryDoorPlugin());
      _compiler = compiler;
    }
    return _compiler!;
  }

  /// When the plugin does not have the bytecode in plugin.evc, but
  /// has sources bundled, compile those sources into the plugin.evc.
  /// Note than when we update Every Door, plugins would need to be
  /// recompiled because of bytecode incompatibility. This is a better,
  /// future-proof way of packaging plugins, but would take time to
  /// instantiate.
  static Future<Runtime?> compilePlugin(Plugin plugin) async {
    File main = plugin.resolvePath('src/main.dart');
    if (!await main.exists()) return null;
    _logger.info('Compiling plugin ${plugin.id} from source.');

    final Map<String, String> data = {};
    final src = plugin.resolveDirectory('src');
    await for (final file in src.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final library = path.relative(file.path, from: src.path);
        final content = await file.readAsString();
        data[library] = content;
      }
    }

    try {
      // TODO: this should be done in an isolate
      final program = compiler.compile({plugin.id: data});
      return Runtime.ofProgram(program);
    } catch (e, stacktrace) {
      _logger.severe('Failed to compile the plugin code', e, stacktrace);
    }
    return null;
  }

  /// Reads the plugin bytecode, runs the main() function, and returns the
  /// [EveryDoorPlugin] that it instantiates.
  static Future<EveryDoorPlugin?> instantiatePlugin(Plugin plugin) async {
    Runtime? runtime;
    final main = plugin.resolvePath("plugin.evc");
    if (!await main.exists()) {
      runtime = await compilePlugin(plugin);
      if (runtime == null) return null;
    }

    final bytecode = (await main.readAsBytes()).buffer.asByteData();
    try {
      validateEvc(bytecode);
      runtime = Runtime(bytecode);
    } on Exception catch (e) {
      _logger.warning(e.toString());
      runtime = await compilePlugin(plugin);
    }
    if (runtime == null) return null;

    runtime.addPlugin(flutterEvalPlugin);
    for (final p in fme.plugins) runtime.addPlugin(p);
    runtime.addPlugin(ede.EveryDoorPlugin());
    runtime.grant(FilesystemPermission.directory(plugin.directory.path));
    final apis = plugin.data['accesses'];
    if (apis != null) {
      if (apis is String) {
        runtime.grant(NetworkPermission.url(apis));
      } else if (apis is List) {
        for (final url in apis) runtime.grant(NetworkPermission.url(url));
      }
    }

    try {
      final result =
          runtime.executeLib('package:${plugin.id}/main.dart', 'main');
      if (result is EveryDoorPlugin) return result;
      _logger.warning(
          'build() function for plugin ${plugin.id} returned class ${result?.runtimeType}');
    } catch (e) {
      _logger.warning('Failed to execute build() for plugin ${plugin.id}', e);
    }
    return null;
  }

  static void validateEvc(ByteData bytecode) {
    if (bytecode.lengthInBytes < 10) throw Exception('Bytecode is too short.');

    final m1 = bytecode.getUint8(0),
        m2 = bytecode.getUint8(1),
        m3 = bytecode.getUint8(2),
        m4 = bytecode.getUint8(3);
    final version = bytecode.getInt32(4);
    if (m1 != 0x45 || m2 != 0x56 || m3 != 0x43 || m4 != 0x00) {
      throw Exception(
          'dart_eval runtime error: Not an EVC file or bytecode version older than 064');
    }

    if (version != Runtime.versionCode) {
      var vstr = version.toString();
      if (vstr.length < 3) {
        vstr = '0$vstr';
      }
      throw Exception(
          'dart_eval runtime error: EVC bytecode is version $vstr, but runtime supports version ${Runtime.versionCode}.\n'
          'Try using the same version of dart_eval for compiling as the version in your application.');
    }
  }
}
