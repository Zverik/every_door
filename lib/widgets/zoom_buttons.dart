import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class ZoomButtonsOptions extends LayerOptions {
  final Alignment alignment;
  final EdgeInsets padding;

  ZoomButtonsOptions({
    Key? key,
    Stream<Null>? rebuild,
    this.alignment = Alignment.bottomRight,
    required this.padding,
  }) : super(key: key, rebuild: rebuild);
}

class ZoomButtonsPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is ZoomButtonsOptions) {
      return ZoomButtonsLayer(options, mapState);
    }
    throw Exception(
        'Wrong options for ZoomButtonsPlugin: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) => options is ZoomButtonsOptions;
}

class ZoomButtonsLayer extends StatelessWidget {
  final ZoomButtonsOptions _options;
  final MapState _map;

  const ZoomButtonsLayer(this._options, this._map);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      right: _options.alignment.x >= 0 ? 0.0 : null,
      left: _options.alignment.x < 0 ? 0.0 : null,
      child: Padding(
        padding: _options.padding,
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () {
                _map.move(_map.center, _map.zoom + 1,
                    source: MapEventSource.custom);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
                shape: CircleBorder(side: BorderSide()),
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 10.0),
            OutlinedButton(
              onPressed: () {
                _map.move(_map.center, _map.zoom - 1,
                    source: MapEventSource.custom);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.remove,
                  size: 30.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
                shape: CircleBorder(side: BorderSide()),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
