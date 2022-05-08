import 'package:every_door/providers/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackButtonOptions extends LayerOptions {
  final EdgeInsets padding;
  final Alignment alignment;

  TrackButtonOptions({
    Key? key,
    Stream<Null>? rebuild,
    this.alignment = Alignment.topRight,
    required this.padding,
  }) : super(key: key, rebuild: rebuild);
}

class TrackButtonPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is TrackButtonOptions) {
      return TrackButtonLayer(options);
    }
    throw Exception(
        'Wrong options for TrackButtonPlugin: ${options.runtimeType}');
  }

  @override
  bool supportsLayer(LayerOptions options) => options is TrackButtonOptions;
}

class TrackButtonLayer extends ConsumerWidget {
  final TrackButtonOptions _options;

  const TrackButtonLayer(this._options);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(trackingProvider)) return Container();

    return Positioned(
      top: 0.0,
      right: _options.alignment.x >= 0 ? 0.0 : null,
      left: _options.alignment.x < 0 ? 0.0 : null,
      child: Padding(
        padding: _options.padding,
        child: OutlinedButton(
          onPressed: () {
            ref.read(trackingProvider.state).state = true;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.my_location,
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
      ),
    );
  }
}
