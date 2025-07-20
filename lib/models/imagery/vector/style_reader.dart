import 'dart:convert' show json;

import 'package:every_door/models/imagery/vector/style_cache.dart';
import 'package:every_door/models/plugin.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles/src/style/uri_mapper.dart';
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart'
    show ThemeReader, SpriteIndexReader;

class StyleLoadingException implements Exception {
  final String message;

  StyleLoadingException(this.message);
  StyleLoadingException.url(String url)
      : message = 'Error loading style from $url';

  @override
  String toString() => 'StyleLoadingException($message)';
}

extension HttpChecker on String {
  bool isHttp() => startsWith('http://') || startsWith('https://');
}

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
    final style = await _getOrRead(url, plugin, uriMapper.map);

    final sources = style['sources'];
    if (sources is! Map) {
      throw StyleLoadingException.url(url);
    }
    final providerByName = await _readProviderByName(sources);

    final spriteUri = style['sprite'];
    SpriteStyle? sprites;
    if (spriteUri is String && spriteUri.trim().isNotEmpty) {
      final isHttp = spriteUri.isHttp();
      final spriteUris = isHttp
          ? uriMapper.mapSprite(url, spriteUri)
          : _mapSpriteFile(spriteUri);
      for (final spriteUri in spriteUris) {
        sprites = await _readSprites(spriteUri);
        if (sprites != null) break;
      }
    }

    return Style(
      theme: ThemeReader().read(style),
      providers: TileProviders(providerByName),
      sprites: sprites,
    );
  }

  Future<SpriteStyle?> _readSprites(SpriteUri spriteUri) async {
    dynamic spritesJson;
    try {
      spritesJson = await _getOrRead(spriteUri.json, plugin);
    } catch (e) {
      _logger.severe('Error reading sprite uri: ${spriteUri.json}');
      return null;
    }

    final spriteData = SpriteIndexReader().read(spritesJson);
    if (spriteUri.json.isHttp()) {
      return SpriteStyle(
        atlasProvider: () =>
            StyleCache.instance.loadBinary(spriteUri.image, httpHeaders),
        index: spriteData,
      );
    } else {
      final spriteFile = plugin?.resolvePath(spriteUri.image);
      if (spriteFile == null || !spriteFile.existsSync()) {
        _logger.severe('Image for sprite is missing: ${spriteUri.image}');
        return null;
      }
      return SpriteStyle(
        atlasProvider: () => spriteFile.readAsBytes(),
        index: spriteData,
      );
    }
  }

  Future<Map<String, dynamic>> _getOrRead(String url, Plugin? plugin,
      [String Function(String)? mapUrl]) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (mapUrl != null) url = mapUrl(url);
      return await StyleCache.instance.loadJson(url, httpHeaders);
    } else {
      final styleFile = plugin?.resolvePath(url);
      if (styleFile == null || !styleFile.existsSync()) {
        throw StyleLoadingException(
            'Cannot find file in the plugin: $styleFile');
      }
      final data = json.decode(await styleFile.readAsString());
      if (data is! Map<String, dynamic>) {
        throw StyleLoadingException('Style is not a JSON object: $styleFile');
      }
      return data;
    }
  }

  List<SpriteUri> _mapSpriteFile(String spriteBase) {
    final uris = <SpriteUri>[];
    for (final suffix in ['@2x', '']) {
      uris.add(SpriteUri(
          json: '$spriteBase$suffix.json', image: '$spriteBase$suffix.png'));
    }
    return uris;
  }

  Future<Style> readAssets({String? spritesBase}) async {
    final styleText = await rootBundle.loadString(url);
    final style = json.decode(styleText);
    if (style is! Map<String, dynamic>) {
      throw StyleLoadingException.url(url);
    }
    final sources = style['sources'];
    if (sources is! Map) {
      throw StyleLoadingException.url(url);
    }
    final providerByName = await _readProviderByName(sources);

    SpriteStyle? sprites;
    if (spritesBase != null) {
      for (final suffix in ['@2x', '']) {
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
        source = await StyleCache.instance.loadJson(sourceUrl, httpHeaders);
      } else {
        source = entry.value;
      }
      final entryTiles = source['tiles'];
      final maxZoom = source['maxzoom'] as int? ?? 14;
      final minZoom = source['minzoom'] as int? ?? 1;
      if (entryTiles is List && entryTiles.isNotEmpty) {
        final tileUri = entryTiles[0] as String;
        if (tileUri.isHttp()) {
          final tileUrl = StyleUriMapper(key: apiKey).mapTiles(tileUri);
          providers[entry.key] = NetworkVectorTileProvider(
              type: type,
              urlTemplate: tileUrl,
              maximumZoom: maxZoom,
              minimumZoom: minZoom,
              httpHeaders: httpHeaders);
        } else if (tileUri.endsWith('.mbtiles')) {
          final path = plugin?.resolvePath(tileUri);
          if (path == null || !path.existsSync()) {
            throw StyleLoadingException(
                'Cannot file provider ${entry.key} in file $tileUri');
          }
          final needGzip = source['gzip'] as bool? ?? true;
          final mbtiles = MbTiles(mbtilesPath: path.path, gzip: needGzip);
          providers[entry.key] = MbTilesVectorTileProvider(
            mbtiles: mbtiles,
            minimumZoom: minZoom,
            maximumZoom: maxZoom,
          );
        } else {
          throw StyleLoadingException(
              'Cannot understand provider ${entry.key}: $tileUri');
        }
      }
    }
    if (providers.isEmpty) {
      throw StyleLoadingException('No providers found');
    }
    return providers;
  }
}

Future<Uint8List> _loadBinaryAsset(String name) async {
  final data = await rootBundle.load(name);
  return Uint8List.sublistView(data);
}
