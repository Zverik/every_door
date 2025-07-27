import 'package:encrypt/encrypt.dart';
import 'package:every_door/helpers/tile_caches.dart';
import 'package:every_door/models/imagery/tiles.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:flutter/material.dart' show Widget;
import 'package:flutter_map/flutter_map.dart' show TileLayer, TileProvider;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart' show Logger;

class TmsImagery extends TileImagery {
  static final _logger = Logger('TmsImagery');
  final bool encrypted;
  final TileProvider _tileProvider;

  TmsImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required super.url,
    super.headers,
    super.minZoom,
    super.maxZoom,
    super.overlay = false,
    super.best = false,
    super.tileSize = 256,
    this.encrypted = false,
    String cachingStore = kTileCacheImagery,
  }) : _tileProvider = FMTCTileProvider(
          stores: {cachingStore: BrowseStoreStrategy.readUpdateCreate},
          headers: headers,
          httpClient: IOClient(),
        );

  TmsImagery.from(
    TileImageryData data, {
    bool encrypted = false,
    String cachingStore = kTileCacheImagery,
  }) : this(
          id: data.id,
          category: data.category,
          name: data.name,
          icon: data.icon,
          attribution: data.attribution,
          overlay: data.overlay,
          best: data.best,
          url: data.url,
          headers: data.headers,
          minZoom: data.minZoom,
          maxZoom: data.maxZoom,
          tileSize: data.tileSize,
          encrypted: encrypted,
          cachingStore: cachingStore,
        );

  TmsImagery copyWith({
    String? url,
    int? tileSize,
    String? attribution,
    int? minZoom,
    int? maxZoom,
  }) {
    return TmsImagery(
      id: id,
      category: category,
      name: name,
      attribution: attribution ?? this.attribution,
      icon: icon,
      url: url ?? this.url,
      headers: headers,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      best: best,
      tileSize: tileSize ?? this.tileSize,
    );
  }

  TmsImagery decrypt() {
    if (!encrypted) return this;
    const kDefaultAesKey = '+p08T46G5YGKftKBHUeg0A==';
    final encrypter = Encrypter(
      AES(Key.fromBase64(kDefaultAesKey), mode: AESMode.ctr),
    );
    try {
      final decrypted = encrypter.decrypt(
        Encrypted.fromBase64(url),
        iv: IV.allZerosOfLength(16),
      );
      return copyWith(url: decrypted);
    } catch (e) {
      _logger.severe('Failed to decrypt an URL "$url": $e');
      return this;
    }
  }

  TileProvider getTileProvider() => _tileProvider;

  String prepareUrl() => url;

  @override
  Widget buildLayer({bool reset = false}) {
    String url = prepareUrl().replaceAll('{zoom}', '{z}');

    if (url.contains('MapServer')) {
      // For ArcGIS Rest API, add a flag to produce 404 error on missing tiles.
      final reArcGIS = RegExp(r'(/MapServer/tile/\{z\}/\{y\}/\{x\})(\?.+)?$');
      final m = reArcGIS.firstMatch(url);
      if (m != null) {
        if (m.group(2)?.isEmpty ?? true) {
          url += '?blankTile=false';
        } else {
          url += '&blankTile=false';
        }
      }
    }

    bool tms = false;
    if (url.contains('{-y}')) {
      url = url.replaceFirst('{-y}', '{y}');
      tms = true;
    }

    final List<String> subdomains = [];
    if (url.contains('{switch:')) {
      final match = RegExp(r'\{switch:([^}]+)\}').firstMatch(url)!;
      subdomains.addAll(match.group(1)!.split(',').map((e) => e.trim()));
      url = url.substring(0, match.start) + '{s}' + url.substring(match.end);
    }

    return TileLayer(
      urlTemplate: url,
      tileProvider: getTileProvider(),
      minNativeZoom: minZoom,
      maxNativeZoom: maxZoom,
      maxZoom: 22,
      tileDimension: tileSize,
      tms: tms,
      subdomains: subdomains,
      userAgentPackageName: kUserAgentPackageName,
      reset: reset ? tileResetController.stream : null,
    );
  }
}
