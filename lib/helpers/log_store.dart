// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final logStore = LogStore();

class LogStore {
  final List<String> lines = [];

  clear() {
    lines.clear();
  }

  last(int count) =>
      lines.length <= count ? lines : lines.sublist(lines.length - count);

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  _addLine(String? str, [DateTime? time]) {
    if (str == null) return;
    lines.add('[${_formatTime(time ?? DateTime.now())}] $str');
  }

  addFromLogger(LogRecord record) {
    final line =
        '${record.level.name.substring(0, 1)}/${record.loggerName}: ${record.message}';
    print(line);
    if (record.error != null) print(record.error);
    _addLine(line, record.time);
    _addLine(record.error?.toString());
    _addLine(record.stackTrace?.toString(), record.time);
  }

  addFromFlutter(FlutterErrorDetails details) {
    _addLine('Flutter: ${details.exceptionAsString()}');
    _addLine(details.stack?.toString());
  }

  addFromZone(Object error, StackTrace stack) {
    print('Async error: $error');
    print(stack);
    _addLine('Async: $error');
    _addLine(stack.toString());
  }
}
