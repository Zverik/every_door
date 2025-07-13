import 'dart:convert' show json;

import 'package:every_door/models/plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles/src/style/uri_mapper.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart'
    show ThemeReader, SpriteIndexReader;

/// This class redefines [StyleReader] to support reading definitions and
/// layers from plugins.
class EdStyleReader {
  static final _logger = Logger('EdStyleReader');

  final String url;
  final String? apiKey;
  final Plugin? plugin;
  final Map<String, String>? httpHeaders;

  EdStyleReader({
    required this.url,
    this.apiKey,
    this.httpHeaders,
    this.plugin,
  });

  Future<Style> read() async {
    final uriMapper = StyleUriMapper(key: apiKey);
    final url = uriMapper.map(this.url);
    final styleText = await _httpGet(url, httpHeaders);
    final style = json.decode(styleText);
    if (style is! Map<String, dynamic>) {
      throw _invalidStyle(url);
    }
    final sources = style['sources'];
    if (sources is! Map) {
      throw _invalidStyle(url);
    }
    final providerByName = await _readProviderByName(sources);

    final spriteUri = style['sprite'];
    SpriteStyle? sprites;
    if (spriteUri is String && spriteUri.trim().isNotEmpty) {
      final spriteUris = uriMapper.mapSprite(this.url, spriteUri);
      for (final spriteUri in spriteUris) {
        dynamic spritesJson;
        try {
          final spritesJsonText = await _httpGet(spriteUri.json, httpHeaders);
          spritesJson = json.decode(spritesJsonText);
        } catch (e) {
          _logger.severe('Error reading sprite uri: ${spriteUri.json}');
          continue;
        }
        sprites = SpriteStyle(
          atlasProvider: () => _loadBinary(spriteUri.image, httpHeaders),
          index: SpriteIndexReader().read(spritesJson),
        );
        break;
      }
    }

    return Style(
      theme: ThemeReader().read(style),
      providers: TileProviders(providerByName),
      sprites: sprites,
    );
  }

  Future<Style> readAssets({String? spritesBase}) async {
    final styleText = await rootBundle.loadString(url);
    final style = json.decode(styleText);
    if (style is! Map<String, dynamic>) {
      throw _invalidStyle(url);
    }
    final sources = style['sources'];
    if (sources is! Map) {
      throw _invalidStyle(url);
    }
    final providerByName = await _readProviderByName(sources);

    SpriteStyle? sprites;
    if (spritesBase != null) {
      for (final suffix in ['', '@2x']) {
        dynamic spritesJson;
        try {
          final spritesJsonText =
              await rootBundle.loadString('$spritesBase$suffix.json');
          spritesJson = json.decode(spritesJsonText);
        } catch (e) {
          _logger.warning('Error reading sprite uri: $spritesBase$suffix.json');
          continue;
        }
        sprites = SpriteStyle(
          atlasProvider: () => _loadBinaryAsset('$spritesBase$suffix.png'),
          index: SpriteIndexReader().read(spritesJson),
        );
        break;
      }
    }

    return Style(
      theme: ThemeReader().read(style),
      providers: TileProviders(providerByName),
      sprites: sprites,
    );
  }

  Future<Map<String, VectorTileProvider>> _readProviderByName(
      Map sources) async {
    final providers = <String, VectorTileProvider>{};
    final sourceEntries = sources.entries.toList();
    for (final entry in sourceEntries) {
      final sourceType = entry.value['type'];
      var type = TileProviderType.values
          .where((e) => e.name.replaceAll('_', '-') == sourceType)
          .firstOrNull;
      if (type == null) continue;
      dynamic source;
      var entryUrl = entry.value['url'] as String?;
      if (entryUrl != null) {
        final sourceUrl = StyleUriMapper(key: apiKey).mapSource(url, entryUrl);
        source = json.decode(await _httpGet(sourceUrl, httpHeaders));
        if (source is! Map) {
          throw _invalidStyle(sourceUrl);
        }
      } else {
        source = entry.value;
      }
      final entryTiles = source['tiles'];
      final maxzoom = source['maxzoom'] as int? ?? 14;
      final minzoom = source['minzoom'] as int? ?? 1;
      if (entryTiles is List && entryTiles.isNotEmpty) {
        final tileUri = entryTiles[0] as String;
        final tileUrl = StyleUriMapper(key: apiKey).mapTiles(tileUri);
        providers[entry.key] = NetworkVectorTileProvider(
            type: type,
            urlTemplate: tileUrl,
            maximumZoom: maxzoom,
            minimumZoom: minzoom,
            httpHeaders: httpHeaders);
      }
    }
    if (providers.isEmpty) {
      throw 'Unexpected response';
    }
    return providers;
  }
}

String _invalidStyle(String url) =>
    'Uri does not appear to be a valid style: $url';

Future<String> _httpGet(String url, Map<String, String>? httpHeaders) async {
  final response = await http.get(Uri.parse(url), headers: httpHeaders);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw 'HTTP ${response.statusCode}: ${response.body}';
  }
}

Future<Uint8List> _loadBinary(
    String url, Map<String, String>? httpHeaders) async {
  final response = await http.get(Uri.parse(url), headers: httpHeaders);
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw 'HTTP ${response.statusCode}: ${response.body}';
  }
}

Future<Uint8List> _loadBinaryAsset(String name) async {
  final data = await rootBundle.load(name);
  return Uint8List.sublistView(data);
}
