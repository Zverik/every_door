import 'package:every_door/providers/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkPathPolyline extends ConsumerWidget {
  const WalkPathPolyline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkPath = ref.watch(pathProvider);

    return PolylineLayer(polylines: [
      Polyline(
        points: walkPath,
        color: Colors.blue,
        isDotted: true,
        strokeWidth: 3.0,
        borderColor: Colors.black38,
        borderStrokeWidth: 3.0,
      ),
    ]);
  }
}
