import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/uploader.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class ChangeListPage extends ConsumerStatefulWidget {
  const ChangeListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeListPageState();
}

class ChangeItem {
  final OsmChange? change;
  final OsmNote? note;
  final bool allMapNotes;
  final MultiIcon icon;
  final String title;

  const ChangeItem(
      {this.change,
      this.note,
      this.allMapNotes = false,
      required this.icon,
      required this.title});

  @override
  bool operator ==(other) =>
      other is ChangeItem &&
      other.change == change &&
      other.note == note &&
      other.allMapNotes == allMapNotes;

  @override
  int get hashCode =>
      (change?.hashCode ?? 0) + (note?.hashCode ?? 0) + allMapNotes.hashCode;

  @override
  String toString() {
    if (change != null) return 'ChangeItem(change: $change)';
    if (note != null) return 'ChangeItem(note: $note)';
    if (allMapNotes) return 'ChangeItem(allMapNotes)';
    return 'ChangeItem($title)';
  }
}

class _ChangeListPageState extends ConsumerState {
  List<ChangeItem> _changeList = [];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      buildChangesList();
    });
  }

  String formatTime(String format) {
    final now = DateTime.now();
    final values = {
      'YY': now.year.toString().padLeft(2, '0'),
      'mm': now.month.toString().padLeft(2, '0'),
      'dd': now.day.toString().padLeft(2, '0'),
      'HH': now.hour.toString().padLeft(2, '0'),
      'MM': now.minute.toString().padLeft(2, '0'),
    };
    String result =
        format.replaceFirst('YYYY', now.year.toString().padLeft(4, '0'));
    values.forEach((key, value) {
      result = result.replaceFirst(key, value);
    });
    return result;
  }

  Future<void> downloadChanges(WidgetRef ref) async {
    final changes = ref.watch(changesProvider);
    final changeList = changes.all();
    String changeset =
        ref.read(osmApiProvider).buildOsmChange(changeList, null);
    final tempDir = await getTemporaryDirectory();
    File tmpFile =
        File('${tempDir.path}/everydoor-${formatTime("YYmmdd")}.osc');
    await tmpFile.writeAsString(changeset, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(tmpFile.path, mimeType: 'application/xml')],
        subject:
            '${changeList.length} changes from $kAppTitle on ${formatTime("YYYY-mm-dd HH:MM")}',
      ),
    );
    tmpFile.delete();
  }

  Future<void> buildChangesList() async {
    final loc = AppLocalizations.of(context)!;
    final changes = ref.read(changesProvider);
    final changesList = changes.all();
    changesList.sort((a, b) => b.updated.compareTo(a.updated));

    final items = changesList.map((c) => ChangeItem(
          change: c,
          icon: ElementKind.matchChange(c).icon ??
              MultiIcon(fontIcon: Icons.question_mark),
          title: c.typeAndName,
        ));

    final notes = ref.read(notesProvider.notifier);
    final noteList = await notes.fetchChanges();
    final noteItems = <ChangeItem>[];
    if (noteList.whereType<MapNote>().isNotEmpty ||
        noteList.whereType<MapDrawing>().isNotEmpty) {
      noteItems.add(ChangeItem(
          allMapNotes: true,
          icon: MultiIcon(fontIcon: Icons.draw),
          title: loc.changesMapNotes));
    }
    noteItems.addAll(noteList.whereType<OsmNote>().map((n) => ChangeItem(
        note: n,
        icon: MultiIcon(
            fontIcon: n.deleting
                ? Icons.speaker_notes_off_outlined
                : Icons.speaker_notes_outlined),
        title: loc.changesOsmNote +
            (n.message != null ? ': ' + n.getNoteTitle()! : ''))));

    setState(() {
      _changeList = noteItems + items.toList();
    });
  }

  void _deleteChange(BuildContext context, int index) {
    final loc = AppLocalizations.of(context)!;
    final change = _changeList[index];
    final chProvider = ref.read(changesProvider);
    final nProvider = ref.read(notesProvider.notifier);
    if (change.change != null) {
      chProvider.deleteChange(change.change!);
      ref.read(needMapUpdateProvider).trigger();
    } else if (change.note != null) {
      nProvider.clearChanges(note: change.note!);
    } else if (change.allMapNotes) {
      nProvider.clearChanges(mapOnly: true);
    }
    _changeList.removeAt(index);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(loc.changesDeletedChange(change.title)),
      action: change.change == null && change.note == null
          ? null
          : SnackBarAction(
              label: loc.changesDeletedUndo.toUpperCase(),
              onPressed: () async {
                if (change.change != null) {
                  await chProvider.saveChange(change.change!);
                } else if (change.note != null) {
                  await nProvider.clearChanges(note: change.note!);
                }
                buildChangesList();
              },
            ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final changes = ref.watch(changesProvider);
    final loc = AppLocalizations.of(context)!;

    ref.listen(changesProvider, (previous, next) {
      buildChangesList();
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Fix for cases when the snack bar does not time out.
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.changesCount(_changeList.length)),
          actions: [
            IconButton(
              onPressed: changes.length == 0
                  ? null
                  : () {
                      downloadChanges(ref);
                    },
              icon: Icon(Icons.share),
              tooltip: loc.tagsShare,
            ),
            changes.length == 0 || changes.haveNoErrorChanges()
                ? Container()
                : IconButton(
                    onPressed: () async {
                      final answer = await showOkCancelAlertDialog(
                        context: context,
                        title: loc.changesPurgeTitle,
                        message: loc.changesPurgeMessage,
                        okLabel: loc.buttonYes,
                        cancelLabel: loc.buttonNo,
                      );
                      if (answer == OkCancelResult.ok) {
                        ref
                            .read(changesProvider)
                            .clearChanges(includeErrored: true);
                        ref.read(needMapUpdateProvider).trigger();
                      }
                    },
                    icon: Icon(Icons.delete_forever),
                    tooltip: loc.changesPurge,
                  ),
            IconButton(
              onPressed: ref.watch(apiStatusProvider) != ApiStatus.idle
                  ? null
                  : () {
                      ref.read(uploaderProvider).upload(context);
                    },
              icon: Icon(Icons.upload),
              tooltip: loc.navUpload,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final change = _changeList[index];
                  return ListTile(
                    title: Text(change.title),
                    subtitle: Text(change.change?.error ?? loc.changesPending),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        _deleteChange(context, index);
                      },
                    ),
                    onTap: change.change == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PoiEditorPage(amenity: change.change!),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: _changeList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
