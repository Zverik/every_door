import 'dart:io';
import 'package:path/path.dart' as p;

const kPackageName = 'every_door_plugin';

void makeDirectories(String path) {
  final dir = Directory(p.dirname(path));
  dir.createSync(recursive: true);
}

void processBindingFile(File file, Directory lib, Directory dest) {
  String content = file.readAsStringSync();
  final importRe = RegExp(r"import 'package:every_door/([^']+\.dart)'");
  for (final match in importRe.allMatches(content)) {
    final path = match.group(1)!;
    if (!path.contains('/plugins/bindings/') && !path.contains('.eval.dart')) {
      // Copy this file only if it is missing in the dest!
      final source = File(p.join(lib.path, path));
      final target = File(p.join(dest.path, path));
      // Probably would need to skip files that are not newer than target files.
      // Also remove the @Bind and eval_annotation references.
      if (source.existsSync() && !target.existsSync()) {
        makeDirectories(target.path);
        source.copySync(target.path);
        replacePackage(target);
      }
    }
  }
}

void replacePackage(File target) {
  String content = target.readAsStringSync();
  content = content.replaceAll(
      "import 'package:every_door/", "import 'package:$kPackageName/");
  target.writeAsStringSync(content);
}

void main() {
  final root = File(Platform.script.toFilePath()).parent.parent;
  final lib = Directory(p.join(root.path, 'lib'));
  if (!lib.existsSync())
    throw PathNotFoundException(lib.path, OSError('Cannot find the lib path'));

  final dest = Directory(p.join(root.parent.path, kPackageName, 'lib'));
  if (!dest.existsSync())
    throw PathNotFoundException(
        dest.path, OSError("Cannot find the plugin path"));

  final files = lib.listSync(recursive: true).whereType<File>().where((p) =>
      p.path.contains('lib/plugins/bindings/') &&
      p.path.endsWith('.eval.dart'));

  for (final file in files) {
    processBindingFile(file, lib, dest);
  }
}
