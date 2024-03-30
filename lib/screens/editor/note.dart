import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/notes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteEditorPane extends ConsumerStatefulWidget {
  final BaseNote? note;
  final LatLng location;

  const NoteEditorPane({super.key, this.note, required this.location});

  @override
  ConsumerState<NoteEditorPane> createState() => _NoteEditorPaneState();
}

class _NoteEditorPaneState extends ConsumerState<NoteEditorPane> {
  late bool isOsmNote;
  String message = '';

  @override
  void initState() {
    super.initState();

    // If the last comment is new, pre-fill it for editing.
    isOsmNote = widget.note != null && widget.note is OsmNote;
    if (widget.note != null) {
      if (isOsmNote && widget.note != null) {
        final note = widget.note as OsmNote;
        if (note.comments.isNotEmpty) {
          if (note.comments.last.isNew) {
            message = note.comments.last.message;
          }
        }
      } else {
        final note = widget.note as MapNote;
        message = note.message;
      }
    }
  }

  bool get isChanged => message.isNotEmpty;

  BaseNote? _buildEditedNote() {
    if (widget.note == null) {
      if (message.isEmpty) {
        return null;
      } else if (isOsmNote) {
        return OsmNote(
          location: widget.location,
          comments: [OsmNoteComment(message: message, isNew: true)],
        );
      } else {
        return MapNote(
          location: widget.location,
          message: message,
        );
      }
    }

    // TODO: conversion of notes! isOsmNote is not reliable.
    if (isOsmNote) {
      final note = widget.note as OsmNote;
      if (note.comments.isNotEmpty && note.comments.last.isNew) {
        if (message.isEmpty)
          note.comments.removeLast();
        else
          note.comments.last.message = message;
      } else if (message.isNotEmpty) {
        note.comments.add(OsmNoteComment(message: message, isNew: true));
      }
      return note;
    } else {
      final note = widget.note as MapNote;
      note.message = message; // TODO: check deletion
      return note;
    }
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
        if (note.isNew) {
          ref.read(notesProvider).deleteNote(note);
        } else {
          note.deleting = true;
          ref.read(notesProvider).saveNote(note);
        }
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

  Iterable<OsmNoteComment> getOldComments() {
    if (!isOsmNote || widget.note == null || widget.note is! OsmNote)
      return const [];
    return (widget.note as OsmNote).comments.where((c) => !c.isNew);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat =
        DateFormat.yMMM(Localizations.localeOf(context).toLanguageTag());

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) saveAndClose(false);
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
                for (final OsmNoteComment comment in getOldComments()) ...[
                  SelectableText.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: comment.author ?? loc.notesAnonymous,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ': '),
                      ..._parseLinks(comment.message),
                      TextSpan(
                        text: ' (${dateFormat.format(comment.date)})',
                        style: TextStyle(fontSize: kFieldFontSize - 3),
                      ),
                    ]),
                    style: kFieldTextStyle,
                  ),
                  SizedBox(height: 10.0),
                ],
                TextFormField(
                  autofocus: true,
                  initialValue: message,
                  decoration: InputDecoration(
                    labelText: loc.notesComment,
                  ),
                  style: kFieldTextStyle,
                  onChanged: (value) {
                    message = value.trim();
                  },
                ),
                if (widget.note == null)
                  SwitchListTile(
                    value: isOsmNote,
                    title: Text('Publish to OSM'),
                    onChanged: (value) {
                      setState(() {
                        isOsmNote = !isOsmNote;
                      });
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
                            title: MaterialLocalizations.of(context)
                                .cancelButtonLabel,
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
