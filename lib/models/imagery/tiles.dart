import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/imagery/tms.dart';
import 'package:every_door/models/imagery/wms.dart';

class TileImageryData {
  final String id;
  final ImageryCategory? category;
  final String? name;
  final MultiIcon? icon;
  final String? attribution;
  final bool best;
  final bool overlay;
  final String url;
  final Map<String, String>? headers;
  final int? minZoom;
  final int? maxZoom;
  final int tileSize;
  final double opacity;

  const TileImageryData({
    required this.id,
    this.category,
    this.name,
    this.icon,
    this.attribution,
    required this.url,
    this.headers,
    this.minZoom,
    this.maxZoom,
    this.overlay = false,
    this.best = false,
    this.tileSize = 256,
    this.opacity = 1.0,
  });
}

abstract class TileImagery extends Imagery {
  final String url;
  final Map<String, String>? headers;
  final int minZoom;
  final int maxZoom;
  final int tileSize;
  final double opacity;

  const TileImagery({
    required super.id,
    super.category,
    super.name,
    super.icon,
    super.attribution,
    required this.url,
    this.headers,
    int? minZoom,
    int? maxZoom,
    super.overlay = false,
    super.best = false,
    this.tileSize = 256,
    this.opacity = 1.0,
  })  : minZoom = minZoom ?? 0,
        maxZoom = maxZoom ?? 20;

  bool get isOpaque => opacity >= 0.99;

  TileImagery.from(TileImageryData data)
      : this(
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
          opacity: data.opacity,
        );

  factory TileImagery.fromJson(Map<String, dynamic> data) {
    final tid = TileImageryData(
      id: data['id'],
      name: data['name'],
      attribution: data['attribution'],
      icon: data['icon'] == null ? null : MultiIcon(imageUrl: data['icon']),
      url: data['url'],
      minZoom: data['min_zoom'],
      maxZoom: data['max_zoom'],
      best: data['best'] == 1,
      tileSize: data['tile_size'] ?? 256,
      opacity: data.containsKey('opacity')
          ? (data['opacity'] as num).toDouble()
          : 1.0,
    );

    if (data['is_wms'] == 1) {
      return WmsImagery.from(tid, wms4326: data['wms_4326'] == 1);
    } else {
      return TmsImagery.from(tid);
    }
  }
}
