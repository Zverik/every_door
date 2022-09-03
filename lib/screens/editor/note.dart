import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/notes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static final kReLink = RegExp(
      r"(https?://|www\.)[a-z0-9.-]+\.\w{2,8}(:\d+)?(/[a-z0-9.,;?'+&%$/\#=~_-]+)?",
      caseSensitive: false);

  List<TextSpan> _parseLinks(String message) {
    final result = <TextSpan>[];
    RegExpMatch? match = kReLink.firstMatch(message);
    while (match != null) {
      if (match.start > 0)
        result.add(TextSpan(text: message.substring(0, match.start)));
      try {
        String url = match.group(0)!;
        if (!url.startsWith('http')) url = 'https://' + url;
        final uri = Uri.parse(url);
        result.add(TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
        ));
      } on FormatException {
        result.add(TextSpan(text: match.group(0)!));
      }
      message = message.substring(match.end);
      match = kReLink.firstMatch(message);
    }
    if (message.isNotEmpty) result.add(TextSpan(text: message));
    return result;
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
                for (final OsmNoteComment comment
                    in widget.note?.comments.where((c) => !c.isNew) ??
                        const []) ...[
                  SelectableText.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: comment.author ?? loc.notesAnonymous,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ': '),
                      ..._parseLinks(comment.message),
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
                        child: Text(
                          loc.notesClose.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        onPressed: () async {
                          final answer = await showOkCancelAlertDialog(
                            context: context,
                            title: loc.notesCloseMessage,
                            okLabel: loc.notesClose,
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
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (message.trim().isNotEmpty) {
                          final answer = await showOkCancelAlertDialog(
                            context: context,
                            title: MaterialLocalizations.of(context).cancelButtonLabel,
                            message: loc.notesCancelMessage,
                            isDestructiveAction: true,
                          );
                          if (answer != OkCancelResult.ok) return;
                        }
                        navigator.pop();
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
