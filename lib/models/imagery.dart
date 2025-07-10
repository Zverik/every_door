import 'package:flutter/widgets.dart' show Widget, protected;

enum ImageryCategory {
  photo,
  map,
  other,
}

/// A data container for an imagery layer. Fields are based on the editor
/// layer index, and just the identifier and type are required. This is
/// the super-class for the multitude of implementations, including TMS,
/// WMS, and vector tiles.
abstract class Imagery {
  @protected
  final String kUserAgentPackageName = 'info.zverev.ilya.every_door';

  final String id;
  final ImageryCategory? category;
  final String? name;
  final String? icon;
  final String? attribution;
  final bool best;
  final bool overlay;

  const Imagery({
    required this.id,
    this.category,
    this.name,
    this.icon,
    this.attribution,
    this.best = false,
    this.overlay = false,
  });

  @override
  String toString() => 'Imagery(id: $id, name: $name, category: $category)';

  Widget buildLayer({bool reset = false});
}
