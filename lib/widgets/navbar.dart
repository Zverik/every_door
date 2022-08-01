import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrowserNavigationBar extends ConsumerWidget {
  final Function(BuildContext) downloadAmenities;

  const BrowserNavigationBar({Key? key, required this.downloadAmenities})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorMode = ref.watch(editorModeProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasNotesToUpload = ref.watch(notesProvider).haveChanges;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    IconButton dataButton;
    if (!hasChangesToUpload && !hasNotesToUpload) {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () {
                downloadAmenities(context);
              },
        icon: Icon(Icons.download),
        color: Colors.white70,
        disabledColor: Colors.white10,
      );
    } else {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () async {
                ref.read(uploaderProvider).upload(context);
              },
        icon: Icon(Icons.upload),
        color: Colors.yellow,
        disabledColor: Colors.yellow.withOpacity(0.2),
      );
    }

    IconButton imageryButton = IconButton(
      onPressed: () {
        ref.read(selectedImageryProvider.notifier).toggle();
      },
      icon: Icon(ref.watch(selectedImageryProvider) == kOSMImagery
          ? Icons.map_outlined
          : Icons.map),
      color: Colors.white70,
    );

    const kEditorModes = [
      EditorMode.micromapping,
      EditorMode.poi,
      EditorMode.entrances,
      EditorMode.notes,
    ];

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
