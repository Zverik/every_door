// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:ui' show Color;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jovial_svg/jovial_svg.dart';

class CachedSvgSource extends ScalableImageSource {
  final String url;
  final bool compact;
  final bool bigFloats;
  final Color? currentColor;
  final Map<String, String>? headers;
  final String? cacheKey;

  CachedSvgSource(
    this.url, {
    this.compact = false,
    this.bigFloats = false,
    this.currentColor,
    this.headers,
    this.cacheKey,
  });

  CacheManager get _cacheManager => DefaultCacheManager();

  @override
  Future<ScalableImage> createSI() async {
    final file =
        await _cacheManager.getSingleFile(url, headers: headers, key: cacheKey);

    return ScalableImage.fromSvgString(
      await file.readAsString(),
      compact: compact,
      bigFloats: bigFloats,
      currentColor: currentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! CachedSvgSource) return false;
    return other.url == url &&
        other.currentColor == currentColor &&
        other.headers == headers &&
        other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => Object.hash(url, currentColor, cacheKey, headers);
}
