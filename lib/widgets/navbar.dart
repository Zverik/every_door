import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserNavigationBar extends ConsumerWidget {
  final VoidCallback downloadAmenities;

  const BrowserNavigationBar({Key? key, required this.downloadAmenities})
      : super(key: key);

  uploadChanges(BuildContext context, WidgetRef ref) async {
    if (ref.read(authProvider) == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OsmAccountPage()));
      return;
    }

    final loc = AppLocalizations.of(context)!;
    try {
      int count = await ref.read(osmApiProvider).uploadChanges(true);
      AlertController.show(
          loc.changesUploadedTitle,
          loc.changesUploadedMessage(loc.changesCount(count)),
          TypeAlert.success);
    } on Exception catch (e) {
      AlertController.show(
          loc.changesUploadFailedTitle, e.toString(), TypeAlert.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorMode = ref.watch(editorModeProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();

    IconButton dataButton;
    if (!hasChangesToUpload) {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle ? null : downloadAmenities,
        icon: Icon(Icons.download),
        color: Colors.white70,
        disabledColor: Colors.white10,
      );
    } else {
      dataButton = IconButton(
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () async {
                uploadChanges(context, ref);
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
      EditorMode.entrances
    ];

    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    return Container(
      color: Colors.black87,
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
