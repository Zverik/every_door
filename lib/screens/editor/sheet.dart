// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/last_presets.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor.dart';
import 'package:every_door/widgets/address_form.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class BottomEditorPane extends ConsumerStatefulWidget {
  final OsmChange? element;
  final Preset? preset;
  final LatLng? location;
  final List<String> fields;
  final bool showAddressForm;
  final bool canDelete;

  const BottomEditorPane({
    this.element,
    this.preset,
    this.location,
    required this.fields,
    this.showAddressForm = false,
    this.canDelete = true,
  });

  @override
  ConsumerState<BottomEditorPane> createState() => _BottomEditorPaneState();
}

class _BottomEditorPaneState extends ConsumerState<BottomEditorPane> {
  late OsmChange element;
  List<PresetField> fields = [];
  bool showAddressForm = false;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    saved = false;
    showAddressForm = widget.showAddressForm ||
        widget.fields.firstOrNull?.toLowerCase() == 'address';

    if (widget.element != null) {
      element = widget.element!.copy();
    } else {
      final tags =
          ref.read(lastPresetsProvider).getTagsForPreset(widget.preset!) ??
              widget.preset!.addTags;
      element = OsmChange.create(tags: tags, location: widget.location!);
    }
    element.addListener(onAmenityChange);

    if (widget.fields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final locale = Localizations.localeOf(context);
        resolveFields(locale);
      });
    }
  }

  @override
  dispose() {
    element.removeListener(onAmenityChange);
    super.dispose();
  }

  void onAmenityChange() {
    setState(() {});
  }

  Future<void> resolveFields(Locale locale) async {
    final fieldsCopy = List.of(widget.fields);
    if (fieldsCopy.firstOrNull?.toLowerCase() == 'address') {
      fieldsCopy.removeAt(0);
    }

    final resolved =
        await ref.read(presetProvider).getFieldsByName(fieldsCopy, locale);
    fields =
        fieldsCopy.map((n) => resolved[n]).whereType<PresetField>().toList();
    setState(() {});
  }

  void saveAndClose([bool pop = true]) {
    final fullTags = element.getFullTags();
    // Setting the mark automatically.
    if (ElementKind.needsCheck.matchesTags(fullTags)) element.check();
    // Store the preset when an object was saved, to track used ones.
    if (widget.preset != null) {
      ref.read(lastPresetsProvider).registerPreset(widget.preset!, fullTags);
    }
    // Save changes and close.
    final changes = ref.read(changesProvider);
    changes.saveChange(element);
    saved = true;
    ref.read(needMapUpdateProvider).trigger();
    if (pop) Navigator.pop(context);
  }

  void deleteAndClose() {
    if (widget.element != null) {
      // No use deleting an amenity that just have been created.
      final changes = ref.read(changesProvider);
      if (element.isNew) {
        changes.deleteChange(element);
      } else {
        element.isDeleted = true;
        changes.saveChange(element);
      }
      saved = true;
      ref.read(needMapUpdateProvider).trigger();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
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
            children: [
              if (widget.showAddressForm)
                AddressForm(
                  location: element.location,
                  initialAddress: StreetAddress.fromTags(element.getFullTags()),
                  autoFocus: false,
                  onChange: (addr) {
                    addr.forceTags(element);
                  },
                ),
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(110.0),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (final field in fields)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(field.label, style: kFieldTextStyle),
                        ),
                        field.buildWidget(element),
                      ],
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoiEditorPage(
                            amenity: element,
                            preset: widget.preset,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Text(loc.buildingMoreButton.toUpperCase() + '...'),
                  ),
                  if (widget.element != null &&
                      element.canDelete &&
                      widget.canDelete)
                    TextButton(
                      child: Text(loc.editorDeleteButton.toUpperCase()),
                      onPressed: () async {
                        final answer = await showOkCancelAlertDialog(
                          context: context,
                          title: loc.editorDeleteTitle(element.typeAndName),
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
                      saved = true;
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
    );
  }
}
