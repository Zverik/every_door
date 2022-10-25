import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/uploader.dart';
import 'package:every_door/screens/settings/changeset_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserNavigationBar extends ConsumerWidget {
  final Function(BuildContext) downloadAmenities;

  const BrowserNavigationBar({Key? key, required this.downloadAmenities})
      : super(key: key);

  Future<bool> _showChangesetPane(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => ChangesetSheetPane(),
    );
    return result != false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorMode = ref.watch(editorModeProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasNotesToUpload = ref.watch(notesProvider).haveChanges;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final bool haveHashtags =
        ref.watch(changesetTagsProvider).getHashtags().isNotEmpty;
    final loc = AppLocalizations.of(context)!;

    IconButton dataButton;
    if (!hasChangesToUpload && !hasNotesToUpload) {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () {
                downloadAmenities(context);
              },
        icon: Icon(Icons.download),
        tooltip: loc.navDownload,
        color: Colors.white70,
        disabledColor: Colors.white10,
      );
    } else {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () async {
                final review = ref.read(editorSettingsProvider).changesetReview;
                bool needAsk = review == ChangesetReview.always ||
                    (haveHashtags && review == ChangesetReview.withTags);
                bool upload = true;
                if (needAsk) {
                  if (!await _showChangesetPane(context)) upload = false;
                }
                // We won't lose the context here.
                // ignore: use_build_context_synchronously
                if (upload) ref.read(uploaderProvider).upload(context);
              },
        icon: Stack(children: [
          Icon(Icons.upload),
          if (haveHashtags)
            Positioned(
              child: Text(
                '#',
                style: TextStyle(color: Colors.yellow, fontSize: 10.0),
              ),
              right: 0.0,
              top: 0.0,
            ),
        ]),
        tooltip: loc.navUpload,
        color: Colors.yellow,
        disabledColor: Colors.yellow.withOpacity(0.2),
      );
    }

    final isNavigation = ref.watch(navigationModeProvider);
    IconButton imageryButton = IconButton(
      onPressed: isNavigation
          ? null
          : () {
              ref.read(selectedImageryProvider.notifier).toggle();
            },
      icon: Icon(ref.watch(selectedImageryProvider) == kOSMImagery
          ? Icons.map_outlined
          : Icons.map),
      tooltip: loc.navImagery,
      color: Colors.white70,
    );

    const kEditorModes = [
      EditorMode.micromapping,
      EditorMode.poi,
      EditorMode.entrances,
      EditorMode.notes,
    ];

    final editorModeTooltips = {
      EditorMode.micromapping: loc.navMicromappingMode,
      EditorMode.poi: loc.navPoiMode,
      EditorMode.entrances: loc.navEntrancesMode,
      EditorMode.notes: loc.navNotesMode,
    };

    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(child: leftHand ? imageryButton : dataButton),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.black,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                for (final mode in kEditorModes)
                  IconButton(
                    icon: Icon(editorMode == mode
                        ? kEditorModeIcons[mode]!
                        : kEditorModeIconsOutlined[mode]!),
                    tooltip: editorModeTooltips[mode],
                    color: editorMode == mode ? Colors.yellow : Colors.white70,
                    onPressed: () {
                      ref.read(editorModeProvider.notifier).set(mode);
                    },
                  ),
              ],
            ),
          ),
          Expanded(child: !leftHand ? imageryButton : dataButton),
        ],
      ),
    );
  }
}
