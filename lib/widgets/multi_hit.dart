import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class MultiHitMarkerLayerOptions extends LayerOptions {
  final List<Marker> markers;
  final Function(List<Key>)? onTap;

  MultiHitMarkerLayerOptions({
    Key? key,
    this.markers = const [],
    this.onTap,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class MultiHitMarkerLayerPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is MultiHitMarkerLayerOptions) {
      return _MultiHitMarkerLayer(options, mapState, stream);
    }
    throw Exception('Wrong options type: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) =>
      options is MultiHitMarkerLayerOptions;
}

class _MultiHitMarkerLayer extends StatelessWidget {
  final MultiHitMarkerLayerOptions _options;
  final MapState _mapState;
  final Stream<Null>? _stream;

  _MultiHitMarkerLayer(this._options, this._mapState, this._stream)
      : super(key: _options.key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: _stream, // a Stream<int> or null
      builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
        var markers = <Widget>[];
        for (var i = 0; i < _options.markers.length; i++) {
          var marker = _options.markers[i];

          // Decide whether to use cached point or calculate it
          var pxPoint = _mapState.project(marker.point);

          final width = marker.width - marker.anchor.left;
          final height = marker.height - marker.anchor.top;
          var sw = CustomPoint(pxPoint.x + width, pxPoint.y - height);
          var ne = CustomPoint(pxPoint.x - width, pxPoint.y + height);

          if (!_mapState.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
            continue;
          }

          final pos = pxPoint - _mapState.getPixelOrigin();
          final rotatedChild = _mapState.rotation.abs() > 1.0
              ? Transform.rotate(
                  angle: -_mapState.rotationRad,
                  child: marker.builder(context),
                )
              : marker.builder(context);

          markers.add(
            Positioned(
              key: marker.key,
              width: marker.width,
              height: marker.height,
              left: pos.x - width,
              top: pos.y - height,
              child: rotatedChild,
            ),
          );
        }
        return GestureDetector(
          child: Stack(
            children: markers,
          ),
          onTapUp: (details) {
            List<Key> tapped = [];
            for (final m in _options.markers) {
              final key = m.key;
              if (key != null && key is GlobalKey) {
                final renderBox = key.currentContext?.findRenderObject();
                if (renderBox != null && renderBox is RenderBox) {
                  Offset topLeftCorner = renderBox.localToGlobal(Offset.zero);
                  Size size = renderBox.size;
                  Rect rectangle = topLeftCorner & size;
                  if (rectangle.contains(details.globalPosition)) {
                    tapped.add(key);
                  }
                }
              }
            }
            if (tapped.isNotEmpty && _options.onTap != null)
              _options.onTap!(tapped);
          },
        );
      },
    );
  }
}
