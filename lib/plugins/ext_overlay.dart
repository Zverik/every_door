// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

@Bind()
class ExtOverlay extends Imagery {
  final Widget Function(BuildContext context, dynamic data) build;
  final int updateInMeters;
  final Future<dynamic> Function(LatLngBounds)? update;

  ExtOverlay({
    required super.id,
    super.attribution,
    this.updateInMeters = 0,
    required this.build,
    this.update,
  }) : super(overlay: true);

  @override
  Widget buildLayer({bool reset = false}) => ExtOverlayLayer(
        build: build,
        updateInMeters: updateInMeters,
        update: update,
      );
}

class ExtOverlayLayer extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, dynamic data) build;
  final int updateInMeters;
  final Future<dynamic> Function(LatLngBounds bounds)? update;

  const ExtOverlayLayer({
    super.key,
    required this.build,
    required this.updateInMeters,
    required this.update,
  });

  @override
  ConsumerState<ExtOverlayLayer> createState() => _ExtOverlayLayerState();
}

class _ExtOverlayLayerState extends ConsumerState<ExtOverlayLayer> {
  dynamic _data;
  LatLng _lastUpdate = LatLng(0, 0);
  final _distance = DistanceEquirectangular();
  bool needUpdate = true;

  Future<void> _update(BuildContext context) async {
    final bounds = MapCamera.maybeOf(context)?.visibleBounds;
    if (bounds == null || widget.update == null) return;
    needUpdate = false;
    _data = await widget.update!(bounds);
    if (context.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (needUpdate) _update(context);

    ref.listen(effectiveLocationProvider, ((o, n) {
      if (_distance.distance(_lastUpdate, n) >= widget.updateInMeters) {
        _lastUpdate = n;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          needUpdate = true;
        });
      }
    }));

    return widget.build(context, _data);
  }
}
