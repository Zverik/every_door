import 'dart:io';
import 'package:path/path.dart' as p;

const kNotice = '''
// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
''';

void main() {
  final root = File(Platform.script.toFilePath()).parent.parent;
  final lib = Directory(p.join(root.path, 'lib'));
  if (!lib.existsSync())
    throw PathNotFoundException(lib.path, OSError('Cannot find the lib path'));

  final files = lib.listSync(recursive: true).whereType<File>().where((p) =>
      p.path.endsWith('.dart') &&
      !p.path.contains('/plugins/bindings/') &&
      !p.path.contains('/constants.dart') &&
      !p.path.contains('.g.dart') &&
      !p.path.contains('/generated/'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (!content.contains('This file is a part of Every Door')) {
      content = kNotice.trim() + '\n' + content;
      file.writeAsStringSync(content);
    }
  }
}
