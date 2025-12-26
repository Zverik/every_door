// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final logStore = LogStore();

class LogStore {
  final List<String> lines = [];

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;

  void clear() {
    lines.clear();
  }

  List<String> last(int count) =>
      lines.length <= count ? lines : lines.sublist(lines.length - count);

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  void _addLine(String? str, [DateTime? time]) {
    if (str == null) return;
    lines.add('[${_formatTime(time ?? DateTime.now())}] $str');
  }

  void addFromLogger(LogRecord record) {
    final line =
        '${record.level.name.substring(0, 1)}/${record.loggerName}: ${record.message}';
    print(line);
    if (record.error != null) print(record.error);
    _addLine(line, record.time);
    _addLine(record.error?.toString());
    _addLine(record.stackTrace?.toString(), record.time);
  }

  void addFromFlutter(FlutterErrorDetails details) {
    _addLine('Flutter: ${details.exceptionAsString()}');
    _addLine(details.stack?.toString());
  }

  void addFromZone(Object error, StackTrace stack) {
    print('Async error: $error');
    print(stack);
    _addLine('Async: $error');
    _addLine(stack.toString());
  }
}
