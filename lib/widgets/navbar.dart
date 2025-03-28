import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/uploader.dart';
import 'package:every_door/screens/modes/definitions/base.dart';
import 'package:every_door/screens/settings/changeset_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserNavigationBar extends ConsumerWidget {
  const BrowserNavigationBar({super.key});

  Future<bool> _showChangesetPane(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChangesetSheetPane(),
    );
    return result != false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasNotesToUpload = ref.watch(notesProvider).haveChanges;
    final bool haveHashtags =
        ref.watch(changesetTagsProvider).getHashtags().isNotEmpty;
    final leftHand = ref.watch(editorSettingsProvider).leftHand;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
        left: 15,
        right: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSideButton(
              context,
              ref,
              leftHand
                  ? _buildImageryButton(context, ref)
                  : _buildDataButton(context, ref, hasChangesToUpload,
                      hasNotesToUpload, haveHashtags, apiStatus)),
          _buildModeSelectorPanel(context, ref),
          _buildSideButton(
              context,
              ref,
              !leftHand
                  ? _buildImageryButton(context, ref)
                  : _buildDataButton(context, ref, hasChangesToUpload,
                      hasNotesToUpload, haveHashtags, apiStatus)),
        ],
      ),
    );
  }

  Widget _buildSideButton(BuildContext context, WidgetRef ref, Widget button) {
    return Expanded(
      child: Center(child: button),
    );
  }

  Widget _buildDataButton(
      BuildContext context,
      WidgetRef ref,
      bool hasChangesToUpload,
      bool hasNotesToUpload,
      bool haveHashtags,
      ApiStatus apiStatus) {
    final loc = AppLocalizations.of(context)!;

    if (!hasChangesToUpload && !hasNotesToUpload) {
      return _buildIconButtonWithGradient(
        icon: Icons.download,
        onPressed: apiStatus != ApiStatus.idle
            ? null
            : () => ref.read(uploaderProvider).download(context),
        tooltip: loc.navDownload,
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
        ),
      );
    }

    return _buildIconButtonWithGradient(
      icon: Icons.upload,
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
      tooltip: loc.navUpload,
      gradient: LinearGradient(
        colors: [Colors.yellow.shade300, Colors.yellow.shade600],
      ),
      child: haveHashtags
          ? Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildImageryButton(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isNavigation = ref.watch(navigationModeProvider);
    final isDefaultImagery =
        ref.watch(selectedImageryProvider) == ref.watch(baseImageryProvider);

    return _buildIconButtonWithGradient(
      icon: isDefaultImagery ? Icons.map_outlined : Icons.map,
      onPressed: isNavigation
          ? null
          : () => ref.read(selectedImageryProvider.notifier).toggle(),
      tooltip: loc.navImagery,
      gradient: LinearGradient(
        colors: [Colors.green.shade300, Colors.green.shade600],
      ),
    );
  }

  Widget _buildModeSelectorPanel(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in ref.read(editorModeProvider.notifier).modes())
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: ModeIconButton(mode),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButtonWithGradient({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required LinearGradient gradient,
    Widget? child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Stack(
          children: [
            Icon(icon, color: onPressed != null ? Colors.white : Colors.grey),
            if (child != null) child,
          ],
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        color: Colors.white,
        disabledColor: Colors.grey,
      ),
    );
  }
}

class ModeIconButton extends ConsumerWidget {
  final BaseModeDefinition mode;

  const ModeIconButton(this.mode, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(editorModeProvider) == mode;
    final icon = mode.getIcon(context, !isCurrent);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent ? Colors.yellow.withOpacity(0.2) : Colors.transparent,
      ),
      child: IconButton(
        icon: icon.getWidget(
          color: isCurrent ? Colors.yellow : Colors.white70,
        ),
        tooltip: icon.tooltip ?? '?',
        onPressed: () {
          ref.read(editorModeProvider.notifier).set(mode.name);
        },
      ),
    );
  }
}
