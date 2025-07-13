import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:flutter/widgets.dart' show Widget, protected;

/// Imagery category, a subset of the Editor Layer Index categories.
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
  /// Package name to send to servers.
  @protected
  final String kUserAgentPackageName = 'info.zverev.ilya.every_door';

  /// Identifier of the imagery. Should be unique for every layer.
  final String id;

  /// Imagery category. Not really used anywhere.
  final ImageryCategory? category;

  /// Display name, shown in lists when choosing an imagery layer.
  final String? name;

  /// Icon to display.
  final MultiIcon? icon;

  /// Imagery attribution. Displayed in a corner for most maps.
  final String? attribution;

  /// Whether this imagery is the best imagery for the region.
  /// Might affect sorting.
  final bool best;

  /// Whether this imagery is an overlay. Not used currently.
  final bool overlay;

  /// Create a new instance of imagery.
  const Imagery({
    required this.id,
    this.category,
    this.name,
    this.icon,
    this.attribution,
    this.best = false,
    this.overlay = false,
  });

  /// Initialize layer state. May be useful when needed to make some async
  /// request, e.g. to download data from an URL. Executed by [imageryProvider]
  /// when the layer is chosen.
  Future<void> initialize() async {}

  /// Builds the widgets to add to the [FlutterMap]. Note that this method
  /// is called on every widget rebuild, which can happen like 60 times a second.
  /// Do cache things.
  Widget buildLayer({bool reset = false});

  @override
  String toString() => 'Imagery(id: $id, name: $name, category: $category)';

  @override
  bool operator ==(Object other) => other is Imagery && other.id == id;

  @override
  int get hashCode => Object.hash(id, name);
}
