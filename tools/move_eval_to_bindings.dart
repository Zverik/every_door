import 'dart:io';
import 'package:path/path.dart' as p;

String pathInBindings(String path) {
  if (!path.contains('/every_door/lib/'))
    throw ArgumentError('The path should contain /lib/');
  return path.replaceFirst(
      '/every_door/lib/', '/every_door/lib/plugins/bindings/');
}

void fixImportPaths(File file, String packagePath) {
  String contents = file.readAsStringSync();
  contents = contents.replaceAll(
      RegExp(r"package:every_door/(?=[^']+.eval.dart')"),
      'package:every_door/plugins/bindings/');
  contents = contents.replaceAllMapped(RegExp(r"import '([^:']+)'"),
      (match) => "import 'package:every_door/$packagePath/${match.group(1)}'");
  file.writeAsStringSync(contents, flush: true);
}

bool needOverwriteFile(File originalBinding, File genFile) {
  final originalFile = File(originalBinding.path.replaceFirst('.eval.dart', '.dart'));
  if (!originalFile.existsSync()) return true; // idk and don't care

  // If the resulting file exists and the source file was not modified after
  // the binding was generated, then just delete the binding.
  // TODO: some key to overwrite all bindings.
  if (genFile.existsSync() &&
      genFile.lastModifiedSync().isAfter(originalFile.lastModifiedSync())) return false;

  return true;
}

void main() {
  final root = File(Platform.script.toFilePath()).parent.parent;
  final lib = Directory(p.join(root.path, 'lib'));
  if (!lib.existsSync())
    throw PathNotFoundException(lib.path, OSError('Cannot find the lib path'));

  final files = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((p) => !p.path.contains('/plugins/bindings/'));

  for (final file in files) {
    if (file.path.endsWith('.eval.dart')) {
      // Move the file to bindings.
      final genPath = pathInBindings(file.path);
      final genFile = File(genPath);
      if (!needOverwriteFile(file, genFile)) {
        file.deleteSync();
        continue;
      }

      genFile.parent.createSync(recursive: true);
      final newFile = file.renameSync(genPath);
      // Fix imports: all other files will be in bindings too.
      final packagePath = p.relative(file.parent.path, from: lib.path);
      fixImportPaths(newFile, packagePath);
    } else if (p.basename(file.path) == 'eval_plugin.dart') {
      // Move to bindings and rename.
      file.renameSync(
          p.join(p.dirname(pathInBindings(file.path)), 'every_door_eval.dart'));
      // All references are relative there.
    }
  }
}
