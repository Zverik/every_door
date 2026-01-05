import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/plugin_context_list.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef EditorButtonsList = PluginContextList<EditorButton>;

/// Stored buttons for the editor pane, along with plugin identifiers
/// that added them.
final editorButtonsProvider =
    NotifierProvider<EditorButtonsController, EditorButtonsList>(
        EditorButtonsController.new);

/// A container representing a button on the editor pane.
@Bind(bridge: true)
abstract class EditorButton {
  /// Returns true if the button should be displayed. Note that this
  /// should rely on a general property and not some easily changed state,
  /// for example, on an [ElementKind]. You can use the
  /// [MaterialButton.enabled] flag instead.
  bool shouldDisplay(OsmChange amenity);

  /// Builds the button. Properties to override are usually title, onPressed,
  /// color, and textColor.
  MaterialButton build(BuildContext context, OsmChange amenity);
}

/// The button that has been on the editor panel from the beginning,
/// to mark the object disused (or not).
class MarkDisusedButton implements EditorButton {
  final Ref _ref;

  MarkDisusedButton(this._ref);

  @override
  bool shouldDisplay(OsmChange amenity) =>
      ElementKind.amenity.matchesChange(amenity);

  @override
  MaterialButton build(BuildContext context, OsmChange amenity) =>
      MaterialButton(
        color: amenity.isDisused ? Colors.brown : Colors.orange,
        textColor: Colors.white,
        child: Text(amenity.isDisused
            ? _ref.read(localizationsProvider).editorMarkActive
            : _ref.read(localizationsProvider).editorMarkDefunct),
        onPressed: () {
          amenity.toggleDisused();
        },
      );
}

class EditorButtonsController extends Notifier<EditorButtonsList> {
  @override
  EditorButtonsList build() => initial();

  EditorButtonsList initial() =>
      EditorButtonsList.from(null, [MarkDisusedButton(ref)]);

  void reset() {
    state = initial();
  }

  void add(String? pluginId, EditorButton button) {
    state = state.add(pluginId, button);
  }

  void replace(String? pluginId, List<EditorButton> buttons) {
    state = EditorButtonsList.from(pluginId, buttons);
  }

  void removeFor(String pluginId) {
    state = state.removeFor(pluginId);
  }
}
