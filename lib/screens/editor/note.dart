import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/notes.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditorPane extends ConsumerStatefulWidget {
  final OsmNote? note;
  final LatLng location;

  const NoteEditorPane({Key? key, this.note, required this.location})
      : super(key: key);

  @override
  ConsumerState<NoteEditorPane> createState() => _NoteEditorPaneState();
}

class _NoteEditorPaneState extends ConsumerState<NoteEditorPane> {
  String message = '';

  @override
  void initState() {
    super.initState();

    // If the last comment is new, pre-fill it for editing.
    final note = widget.note;
    if (note != null && note.comments.isNotEmpty) {
      if (note.comments.last.isNew) {
        message = note.comments.last.message;
      }
    }
  }

  bool get isChanged => message.isNotEmpty;

  OsmNote? _buildEditedNote() {
    final note = widget.note;
    if (note == null) {
      return message.isEmpty
          ? null
          : OsmNote(
              location: widget.location,
              comments: [OsmNoteComment(message: message, isNew: true)],
            );
    }

    if (note.comments.isNotEmpty && note.comments.last.isNew) {
      if (message.isEmpty)
        note.comments.removeLast();
      else
        note.comments.last.message = message;
    } else if (message.isNotEmpty) {
      note.comments.add(OsmNoteComment(message: message, isNew: true));
    }
    return note;
  }

  saveAndClose([bool pop = true]) {
    if (isChanged) {
      final note = _buildEditedNote();
      if (note != null) {
        ref.read(notesProvider).saveNote(note);
      }
    }
    if (pop) Navigator.pop(context);
  }

  deleteAndClose() {
    if (widget.note != null) {
      final note = _buildEditedNote();
      if (note != null) {
        note.deleting = true;
        ref.read(notesProvider).saveNote(note);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        saveAndClose(false);
        return true;
      },
      child: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: 6.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: style comments
                for (final OsmNoteComment comment
                    in widget.note?.comments ?? const []) ...[
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: comment.author ?? 'Anonymous', // TODO: localize
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ': ${comment.message}'),
                    ]),
                    style: kFieldTextStyle,
                  ),
                  SizedBox(height: 10.0),
                ],
                TextFormField(
                  autofocus: true,
                  initialValue: message,
                  decoration: InputDecoration(
                    labelText: 'Your comment',
                  ),
                  style: kFieldTextStyle,
                  onChanged: (value) {
                    message = value.trim();
                  },
                ),
                Row(
                  children: [
                    if (widget.note != null)
                      TextButton(
                        child: Text(loc.editorDeleteButton.toUpperCase()),
                        onPressed: () async {
                          final answer = await showOkCancelAlertDialog(
                            context: context,
                            title: loc
                                .editorDeleteTitle('note'), // TODO: better msg
                            okLabel: loc.editorDeleteButton,
                            isDestructiveAction: true,
                          );
                          if (answer == OkCancelResult.ok) {
                            deleteAndClose();
                          }
                        },
                      ),
                    Expanded(child: Container()),
                    TextButton(
                      child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child:
                          Text(MaterialLocalizations.of(context).okButtonLabel),
                      onPressed: () {
                        saveAndClose();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
