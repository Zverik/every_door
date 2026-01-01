import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/located.dart';
import 'package:flutter/material.dart';

/// Description generator for POI tiles. Instances of this interface
/// are passed to [PoiTile] so it can provide all the information
/// needed to assess the correctness of the data.
@Bind(bridge: true, wrap: true)
abstract class PoiDescriber {
  TextSpan describe(Located element);
}

/// Simple describer returns the [OsmChange.typeAndName] and nothing else.
/// It will be crossed out if disused.
@Bind()
class SimpleDescriber implements PoiDescriber {
  @override
  TextSpan describe(Located element) {
    if (element is! OsmChange) return TextSpan(text: '???');

    return TextSpan(
      text: element.typeAndName,
      style: !element.isDisused
          ? null
          : TextStyle(decoration: TextDecoration.lineThrough),
    );
  }
}
