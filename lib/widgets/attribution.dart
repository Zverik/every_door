import 'package:every_door/models/imagery.dart';
import 'package:flutter/material.dart';

class AttributionWidget extends StatelessWidget {
  final Imagery? imagery;

  const AttributionWidget(this.imagery, {super.key});

  @override
  Widget build(BuildContext context) {
    final src = imagery?.attribution;
    if (src == null) return Container();
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(src),
      ),
    );
  }
}
