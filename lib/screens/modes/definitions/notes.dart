import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/plugins/interface.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_map/flutter_map.dart';

@Bind(bridge: true, implicitSupers: true)
abstract class NotesModeDefinition extends BaseModeDefinition {
  List<BaseNote> notes = [];

  NotesModeDefinition(super.ref);

  NotesModeDefinition.fromPlugin(EveryDoorApp app): this(app.ref);

  @override
  MultiIcon getIcon(BuildContext context, bool outlined) {
    final loc = AppLocalizations.of(context)!;
    return MultiIcon(
      fontIcon: !outlined ? Icons.note_alt : Icons.note_alt_outlined,
      tooltip: loc.navNotesMode,
    );
  }

  @override
  Future<void> updateNearest(LatLngBounds bounds) async {
    final notes =
        await ref.read(notesProvider.notifier).fetchAllNotes(bounds: bounds);
    this.notes = notes.where((n) => !n.deleting).toList();
    notifyListeners();
  }

  @override
  void updateFromJson(Map<String, dynamic> data, Plugin plugin) {
    if (data.containsKey('locked')) {
      ref.read(drawingLockedProvider.notifier).state = data['locked']!;
    }
  }
}

class DefaultNotesModeDefinition extends NotesModeDefinition {
  DefaultNotesModeDefinition(super.ref);

  @override
  String get name => "notes";
}
