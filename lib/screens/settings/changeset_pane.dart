import 'package:every_door/constants.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class ChangesetPane extends ConsumerStatefulWidget {

  ChangesetPane({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangesetPaneState();
}

class _ChangesetPaneState extends ConsumerState<ConsumerStatefulWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref
        .read(changesetTagsProvider.notifier)
        .getHashtags(clearHashes: true));
  }

  void _saveHashtags(String value) {
    ref.read(changesetTagsProvider.notifier).saveHashtags(value);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextFormField(
            controller: _controller,
            onChanged: _saveHashtags,
            style: kFieldTextStyle,
            autofocus: true,
            decoration: InputDecoration(
              label: Text(loc.hashtagsLabel),
              prefixIcon: Icon(Icons.tag),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                tooltip: loc.chooseTypeClear,
                onPressed: () {
                  _controller.clear();
                  _saveHashtags('');
                },
              ),
            ),
          ),
        ),
        SwitchListTile(
          title: Text(loc.hashtagsConfirm),
          value: ref.watch(editorSettingsProvider).changesetReview ==
              ChangesetReview.withTags,
          onChanged: (value) {
            ref.read(editorSettingsProvider.notifier).setChangesetReview(
                value ? ChangesetReview.withTags : ChangesetReview.never);
          },
        ),
      ],
    );
  }
}

class ChangesetSettingsPage extends StatelessWidget {
  const ChangesetSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsHashtags),
      ),
      body: ChangesetPane(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ChangesetSheetPane extends StatelessWidget {
  const ChangesetSheetPane({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              ChangesetPane(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child:
                        Text(MaterialLocalizations.of(context).continueButtonLabel),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
