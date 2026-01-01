// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/imagery.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'
    show LatLngBounds, CircleLayer, CircleMarker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Base mode definition that works for all five modes, including Notes.
/// Contains base fields and methods for managing data and preparing
/// various interface elements, e.g. the icon and lists of buttons and layers.
@Bind()
abstract class BaseModeDefinition extends ChangeNotifier {
  /// A riverpod reference to query providers.
  final Ref ref;

  final _buttons = <MapButton>[];
  final _overlays = <Imagery>[];

  /// List of elements we are editing.
  List<Located> nearest = [];

  /// List of elements that are shown on the background for context.
  List<Located> other = [];

  BaseModeDefinition(this.ref);

  /// This constructor should be called only from a plugin.
  /// It shadows the default constructor, because we are not
  /// allowing plugins into Riverpod.
  BaseModeDefinition.fromPlugin(EveryDoorApp plugin) : this(plugin.ref);

  /// The mode name. Should be unique, because currently shown modes
  /// are addresses by it.
  String get name;

  /// A mode icon. Should normally return a filled icon when [active],
  /// and an outlined one when not.
  MultiIcon getIcon(BuildContext context, bool active);

  /// List of mode-specific overlay layers, usually populated by plugins.
  Iterable<Imagery> get overlays => _overlays;

  /// List of mode-specific buttons, usually populated by plugins.
  Iterable<MapButton> get buttons => _buttons;

  /// Add a button for the mode. The [MapButton.id] should be set,
  /// so that [removeMapButton] can be used. Usually called by plugins.
  void addMapButton(MapButton button) {
    _buttons.add(button);
  }

  /// Removed a previously added button for the mode. Usually called by plugins.
  void removeMapButton(String id) {
    _buttons.removeWhere((b) => b.id == id);
  }

  /// Adds an overlay layer. Usually called by plugins.
  void addOverlay(Imagery imagery) {
    _overlays.add(imagery);
  }

  /// A list of element kinds that are editable in this mode.
  /// You don't need to override this method if you don't use the default
  /// implementation for [updateNearest].
  List<ElementKindImpl> ourKinds = [];

  /// A list of element kinds for context dots on the map.
  /// You don't need to override this method if you don't use the default
  /// implementation for [updateNearest].
  List<ElementKindImpl> otherKinds = [];

  /// Requests all changes in the [bounds]. It then sorts those by the distance
  /// from the center, and trims by [maxCount], which has a big enough default.
  Future<List<OsmChange>> getNearestChanges(LatLngBounds bounds,
      {int maxCount = 200}) async {
    final provider = ref.read(osmDataProvider);
    List<OsmChange> data = await provider.getElementsInBox(bounds);

    final LatLng location = bounds.center;
    const distance = DistanceEquirectangular();
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));

    return data.take(maxCount).toList();
  }

  /// Updates [nearest] and [other], as well as other mode-specific fields.
  /// This method is called by a mode on any event that changes the map state.
  /// The default implementation calls [getNearestChanges] and filters
  /// by [ourKinds] and [otherKinds].
  Future<void> updateNearest(LatLngBounds bounds) async {
    final data = await getNearestChanges(bounds);
    nearest = data
        .where(
            (e) => ElementKind.matchChange(e, ourKinds) != ElementKind.unknown)
        .toList();
    other = otherKinds.isEmpty
        ? []
        : data
            .where((e) =>
                ElementKind.matchChange(e, otherKinds) != ElementKind.unknown)
            .toList();
    notifyListeners();
  }

  /// Open an editing panel. If the [element] is null, it should open a new
  /// object form, otherwise an editing form. Usually it calls [Navigator.push]
  /// or [showModalBottomSheet].
  Future<void> openEditor(
      {required BuildContext context, Located? element, LatLng? location});

  /// This method is called when installing a static plugin that modifies
  /// mode properties. It should modify the internal state. Use the [plugin]
  /// to fetch icons and translations.
  void updateFromJson(Map<String, dynamic> data, Plugin plugin);

  /// A helper methods to read `kinds` and `otherKinds` into the lists
  /// this class manages.
  void readKindsFromJson(Map<String, dynamic> data) {
    ourKinds = ElementKind.parseNames(data['kinds']) ??
        ElementKind.parseNames(data['kind']) ??
        ourKinds;
    otherKinds = ElementKind.parseNames(data['otherKinds']) ??
        ElementKind.parseNames(data['otherKind']) ??
        otherKinds;
  }

  /// Returns a color for a context object dot. By default all dots are
  /// semi-transparent black.
  Color getOtherObjectColor(Located object) =>
      Colors.black.withValues(alpha: 0.8);

  /// Prepares a layer with context objects. This method should not be
  /// overridden.
  Widget otherObjectsLayer() => CircleLayer(
        circles: [
          for (final objLocation in other)
            CircleMarker(
              point: objLocation.location,
              color: getOtherObjectColor(objLocation),
              radius: 2.0,
            ),
        ],
      );

  /// Returns a list of non-interactive map layers to be displayed between
  /// the map background and the mode interactive elements.
  @mustCallSuper
  List<Widget> mapLayers() => other.isEmpty ? [] : [otherObjectsLayer()];
}
