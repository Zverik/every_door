import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final root = File(Platform.script.toFilePath()).parent.parent;
  final lib = Directory(p.join(root.path, 'lib'));
  if (!lib.existsSync())
    throw PathNotFoundException(lib.path, OSError('Cannot find the lib path'));

  final files = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((p) => p.path.contains('/plugins/bindings/'));

  // Probably need to iterate over files in plugins/bindings
  // and copy both them and files they reference to the every_door_plugin/lib
  // Again, skipping files that are not newer than target files.
  // Also remove the @Bind and eval_annotation references.

  for (final file in files) {
    // TODO
  }
}