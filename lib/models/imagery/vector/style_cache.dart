import 'dart:convert' show utf8, json;
import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show md5;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class CacheException implements Exception {
  final String url;
  final String message;

  CacheException(this.url, this.message);

  @override
  String toString() => 'CacheException("$url", "$message")';
}

class _CacheEntry {
  final Uint8List data;
  final DateTime modified;

  _CacheEntry({required this.data, required this.modified});
}

class StyleCache {
  static final instance = StyleCache._();
  static final _ttl = Duration(days: 7);
  String? _path;

  StyleCache._();

  Future<String> get _storagePath async {
    String? path = _path;
    if (path == null) {
      final tempFolder = await getTemporaryDirectory();
      final directory = Directory('${tempFolder.path}/.style_cache');
      final exists = await directory.exists();
      if (!exists) {
        await directory.create(recursive: true);
      }
      path = directory.path;
      _path = path;
    }
    return path;
  }

  Future<File> _fileOf(String url) async {
    final key = md5.convert(utf8.encode(url)).toString();
    final root = await _storagePath;
    return File("$root/$key");
  }

  Future<void> _write(String url, Uint8List bytes) async {
    final file = await _fileOf(url);
    await file.writeAsBytes(bytes);
  }

  Future<_CacheEntry?> _read(String url) async {
    final file = await _fileOf(url);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return _CacheEntry(
        data: bytes,
        modified: await file.lastModified(),
      );
    }
    return null;
  }

  Future<void> clear() async {
    final root = await _storagePath;
    final directory = Directory(root);
    if (await directory.exists()) {
      await for (final entry in directory.list()) {
        if (entry is File) {
          await entry.delete();
        }
      }
    }
  }

  Future<int> size() async {
    int result = 0;
    final root = await _storagePath;
    final directory = Directory(root);
    if (await directory.exists()) {
      await for (final entry in directory.list()) {
        if (entry is File) {
          result += await entry.length();
        }
      }
    }
    return result;
  }

  Future<String> loadString(String url, Map<String, String>? headers) async {
    final data = await loadBinary(url, headers);
    return utf8.decode(data);
  }

  Future<Map<String, dynamic>> loadJson(
      String url, Map<String, String>? headers) async {
    final bytes = await loadBinary(url, headers);
    dynamic data;
    try {
      data = json.decode(utf8.decode(bytes));
    } on Exception catch (e) {
      throw CacheException(url, 'The response is not a JSON object: $e');
    }
    if (data is! Map<String, dynamic>) {
      throw CacheException(url, 'JSON is not a map');
    }
    return data;
  }

  Future<Uint8List> loadBinary(String url, Map<String, String>? headers) async {
    final entry = await _read(url);
    if (entry != null && DateTime.now().difference(entry.modified) < _ttl) {
      return entry.data;
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await _write(url, bytes);
      return bytes;
    } else {
      throw 'HTTP ${response.statusCode}: ${response.body}';
    }
  }
}
