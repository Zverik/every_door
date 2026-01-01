// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/screens/editor/note.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

@Bind(bridge: true, implicitSupers: true)
abstract class NotesModeDefinition extends BaseModeDefinition {
  LatLng? newLocation;
  List<DrawingStyle> palette;

  NotesModeDefinition(super.ref) : palette = kDefaultTools;

  NotesModeDefinition.fromPlugin(EveryDoorApp app) : this(app.ref);

  @override
  MultiIcon getIcon(BuildContext context, bool active) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon: active ? Icons.note_alt : Icons.note_alt_outlined,
      tooltip: loc.navNotesMode,
    );
  }

  @override
  Future<void> updateNearest(LatLngBounds bounds) async {
    final notes =
        await ref.read(notesProvider.notifier).fetchAllNotes(bounds: bounds);
    nearest = notes.where((n) => !n.isDeleted).toList();
    notifyListeners();
  }

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {
    if (data.containsKey('locked')) {
      ref.read(drawingLockedProvider.notifier).state = data['locked']!;
    }
  }

  @override
  Future<void> openEditor({
    required BuildContext context,
    Located? element,
    LatLng? location,
  }) async {
    if (element is MapDrawing) return;

    if (location != null) {
      newLocation = location;
      notifyListeners();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => NoteEditorPane(
        note: element as BaseNote?,
        location: location ?? element!.location,
      ),
    );
    newLocation = null;
    notifyListeners();
  }
}

class DefaultNotesModeDefinition extends NotesModeDefinition {
  DefaultNotesModeDefinition(super.ref);

  @override
  String get name => "notes";
}
