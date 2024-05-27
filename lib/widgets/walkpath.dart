import 'package:every_door/providers/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkPathPolyline extends ConsumerWidget {
  final bool faint;

  const WalkPathPolyline({super.key, this.faint = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkPath = ref.watch(pathProvider);

    return PolylineLayer(polylines: [
      Polyline(
        points: walkPath,
        color: Colors.blue.withOpacity(0.5),
        pattern: StrokePattern.dotted(spacingFactor: 3.0),
        strokeWidth: 3.0,
        borderColor: Colors.black26,
        borderStrokeWidth: faint ? 0.0 : 3.0,
      ),
    ]);
  }
}
