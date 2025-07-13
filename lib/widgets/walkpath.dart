import 'package:every_door/providers/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A polyline for a [FlutterMap] that displays the recently
/// walked path.
class WalkPathPolyline extends ConsumerWidget {
  final bool faint;

  const WalkPathPolyline({super.key, this.faint = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkPath = ref.watch(pathProvider);

    if (walkPath.isEmpty) return Container();

    return PolylineLayer(polylines: [
      Polyline(
        points: walkPath,
        color: Colors.blue.withValues(alpha: 0.5),
        pattern: StrokePattern.dotted(spacingFactor: faint ? 2.0 : 2.5),
        strokeWidth: faint ? 5.0 : 4.0,
        borderColor: Colors.black26,
        borderStrokeWidth: faint ? 0.0 : 3.0,
      ),
    ]);
  }
}
