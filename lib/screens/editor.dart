// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'dart:async';

import 'package:eval_annotation/eval_annotation.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/editor_builder.dart';
import 'package:every_door/helpers/editor_fields.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/providers/cur_imagery.dart';
import 'package:every_door/providers/language.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/overlays.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/widgets/pin_marker.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/last_presets.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/editor/tags.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/editor/versions.dart';
import 'package:every_door/widgets/duplicate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:logging/logging.dart';

/// An object editor page. Expects an OSM-like sourced object, that is,
/// an [OsmChange]. In particular, the object needs to have tags that
/// behave in accordance with OSM model, e.g. for lifecycle prefixes.
/// For editing [Located] you would need to create your own pages.
@Bind()
class PoiEditorPage extends ConsumerStatefulWidget {
  /// The object to edit. Set to null and fill [preset] and [location]
  /// if creating a new one.
  final OsmChange? amenity;

  /// For new objects, a preset from which to fill the tags and get field list.
  /// Should be specified (for new objects). Needs to have both [Preset.addTags]
  /// and [Preset.fields] non-empty. When the preset type is [PresetType.nsi],
  /// the actual preset is detected based on [Preset.addTags].
  final Preset? preset;

  /// The location for a new object.
  final LatLng? location;

  /// Set to true if the object has been modified externally without saving
  /// to the internal database. For example, when the object has been edited
  /// in a bottom sheet, but then this editor page has been called with it.
  final bool isModified;

  const PoiEditorPage({
    this.amenity,
    this.preset,
    this.location,
    this.isModified = false,
  });

  @override
  ConsumerState createState() => _PoiEditorPageState();
}

class _PoiEditorPageState extends ConsumerState<PoiEditorPage> {
  static final _logger = Logger('PoiEditorPage');
  late OsmChange amenity;
  Preset? preset;
  List<EditorFields> fieldGroups = [];

  @override
  void initState() {
    super.initState();
    if (widget.amenity != null) {
      amenity = widget.amenity!.copy();
    } else {
      final tags =
          ref.read(lastPresetsProvider).getTagsForPreset(widget.preset!) ??
              widget.preset!.addTags;
      // TODO: source should be configurable. Probably from the current main data provider.
      amenity = OsmChange.create(
          location: widget.location!, tags: tags, source: 'osm');
    }
    amenity.addListener(onAmenityChange);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.amenity == null &&
          ElementKind.amenity.matchesChange(amenity)) {
        // For new amenities, add a floor and address from the filter.
        final filter = ref.read(poiFilterProvider);
        filter.address?.setTags(amenity);
        if (filter.floor != null) {
          MultiFloor([filter.floor!]).setTags(amenity);
        }
      }

      final locale = Localizations.localeOf(context);
      preset = widget.preset;
      updatePreset(locale, preset?.type);
    });
  }

  @override
  dispose() {
    amenity.removeListener(onAmenityChange);
    super.dispose();
  }

  void onAmenityChange() {
    setState(() {});
  }

  Future<void> updatePreset(Locale locale, [PresetType? presetType]) async {
    await Future.delayed(Duration.zero); // to disconnect from initState

    final presets = ref.read(presetProvider);
    bool detect = presetType == PresetType.nsi || preset == null;
    bool needRefresh = false;
    if (detect) {
      final newPreset = await presets.getPresetForTags(
        amenity.getFullTags(true),
        isArea: amenity.isArea,
        locale: locale,
      );
      if (preset == null || preset?.id != newPreset.id) {
        preset = newPreset;
        needRefresh = true;
      }
    }

    _logger.info('Detected ($detect) preset $preset');
    if (preset!.fields.isEmpty) {
      preset = await presets.getFields(preset!,
          locale: locale, location: amenity.location);
      needRefresh = true;
    }

    if (needRefresh) {
      await updateFieldGroups(locale);
      setState(() {});
    }
  }

  Future<void> updateFieldGroups(Locale locale) async {
    final AppLocalizations loc =
        (mounted ? AppLocalizations.of(context) : null) ??
            ref.read(localizationsProvider);
    // TODO: how to substitute one with a plugin?
    fieldGroups =
        await StandardEditorFieldsBuilder(ref.read(presetProvider), locale, loc)
            .sortFields(amenity, preset!);
  }

  Future<void> changeType() async {
    final kind = ElementKind.matchChange(amenity);
    if (kind == ElementKind.building || kind == ElementKind.address) {
      return;
    }

    final locale = Localizations.localeOf(context);
    final newPreset = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TypeChooserPage(
                location: amenity.location,
                launchEditor: false,
              )),
    );
    if (newPreset == null) return;
    final oldPreset = preset;
    setState(() {
      preset = null;
      fieldGroups = [];
    });
    // if disused, remove disused: prefix before removing tags
    // otherwise we may end up with disused:<old_mainKey>=* + <new_mainKey>=*
    if (amenity.isDisused) amenity.toggleDisused();
    oldPreset?.doRemoveTags(amenity);
    preset = newPreset;
    preset!.doAddTags(amenity);
    updatePreset(locale, preset!.type);
  }

  void saveAndClose() {
    if (amenity.isFixmeNote()) {
      // Convert fix me amenity to an OSM note.
      // 1. create a note
      final note = OsmNote(
        location: amenity.location,
        comments: [
          OsmNoteComment(
            message: "Amenity described as \"${amenity['fixme:type']}\""
                " with name \"${amenity['name'] ?? ''}\".",
            isNew: true,
          )
        ],
      );
      ref.read(notesProvider.notifier).saveNote(note);
      // 2. remove the amenity
      if (widget.amenity != null) {
        // It's new by [OsmChange.isFixmeNote] definition.
        ref.read(changesProvider).deleteChange(amenity);
      }
    } else {
      final fullTags = amenity.getFullTags();
      // Setting the mark automatically.
      if (ElementKind.needsCheck.matchesTags(fullTags)) amenity.check();
      // Remove opening_hours:signed if needed.
      amenity.removeOpeningHoursSigned();
      // Store the preset when an object was saved, to track used ones.
      if (widget.preset != null) {
        ref.read(lastPresetsProvider).registerPreset(widget.preset!, fullTags);
      }
      // Save changes and close.
      final changes = ref.read(changesProvider);
      changes.saveChange(amenity);
      if (amenity.hasTag('addr:floor'))
        ref.read(osmDataProvider).updateFloorNumbering(amenity.location);
    }
    Navigator.pop(context);
    ref.read(needMapUpdateProvider).trigger();
  }

  void deleteAndClose() {
    if (widget.amenity != null) {
      // No use deleting an amenity that just have been created.
      final changes = ref.read(changesProvider);
      if (amenity.isNew) {
        changes.deleteChange(amenity);
      } else {
        amenity.isDeleted = true;
        changes.saveChange(amenity);
      }
      ref.read(needMapUpdateProvider).trigger();
    }
    Navigator.pop(context);
  }

  Future<void> deletionDialog(AppLocalizations loc) async {
    // Check that the address is important.
    bool importantAddress = false;
    final tags = amenity.getFullTags();
    final addr = StreetAddress.fromTags(tags);
    if (addr.isNotEmpty) {
      final osmData = ref.read(osmDataProvider);
      importantAddress = await osmData.isUniqueAddress(addr, amenity.location);
    }

    if (!mounted) return;

    const int kCancel = 0;
    const int kDelete = 1;
    const int kKeepAddress = 2;
    int? answer;

    // Since AdaptiveDialog adds a cancel button on iOS, we need to hide it there.
    // This line copies the clause directly.
    bool addCancel =
        AdaptiveDialog.instance.defaultStyle.isMaterial(Theme.of(context));

    if (importantAddress) {
      answer = await showModalActionSheet<int>(
        context: context,
        title: loc.editorDeleteTitle(amenity.typeAndName),
        actions: [
          SheetAction(
            key: kKeepAddress,
            label: loc.editorDeleteKeepAddressButton,
            isDefaultAction: true,
            icon: Icons.delete_outline,
          ),
          SheetAction(
            key: kDelete,
            label: loc.editorDeleteButton,
            icon: Icons.delete_forever,
          ),
          if (addCancel)
            SheetAction(
              key: kCancel,
              label: MaterialLocalizations.of(context).cancelButtonLabel,
              icon: Icons.arrow_back,
            ),
        ],
      );
    } else {
      answer = await showModalActionSheet<int>(
        context: context,
        title: loc.editorDeleteTitle(amenity.typeAndName),
        actions: [
          SheetAction(
            key: kDelete,
            label: loc.editorDeleteButton,
            isDestructiveAction: true,
            isDefaultAction: true,
            icon: Icons.delete_forever,
          ),
          if (addCancel)
            SheetAction(
              key: kCancel,
              label: MaterialLocalizations.of(context).cancelButtonLabel,
              icon: Icons.arrow_back,
            ),
        ],
      );
    }

    if (answer == kDelete) {
      deleteAndClose();
    } else if (answer == kKeepAddress) {
      // Delete all tags except address.
      for (final k in amenity.getFullTags().keys) {
        if (!k.startsWith('building') &&
            (!k.startsWith('addr:') || k == 'addr:floor')) amenity.removeTag(k);
      }
      saveAndClose();
    }
  }

  Future<void> confirmDisused(BuildContext context) async {
    String oldMainKey = getMainKey(amenity.element?.tags ?? {}) ?? '';
    if (amenity.isDisused && oldMainKey.startsWith(kDisused)) {
      final loc = AppLocalizations.of(context)!;
      final result = await showOkCancelAlertDialog(
        context: context,
        title: loc.editorRestoreTitle,
        message: loc.editorRestoreMessage(amenity.typeAndName),
        okLabel: loc.buttonYes,
        cancelLabel: loc.buttonNo,
      );
      if (result == OkCancelResult.ok) amenity.toggleDisused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset = this.preset;
    final bool modified = widget.amenity == null ||
        widget.isModified ||
        amenity != widget.amenity ||
        amenity.isFixmeNote();

    final loc = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !modified,
      onPopInvokedWithResult: (didPop, res) async {
        if (didPop) return;

        final navigator = Navigator.of(context);
        bool canPop = true;
        if (modified) {
          final result = await showOkCancelAlertDialog(
            context: context,
            isDestructiveAction: true,
            title: loc.editorCloseTitle,
            message: loc.editorCloseMessage,
          );
          canPop = result == OkCancelResult.ok;
        }
        if (canPop) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: GestureDetector(
            child: Stack(children: [
              // Text(preset?.name ?? amenity.name ?? 'Editor'),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.white38,
                        width: 1.5,
                        style: BorderStyle.solid),
                  ),
                ),
                child: Text(preset?.name ?? amenity.name ?? 'Editor'),
              ),
            ]),
            onTap: changeType,
          ),
          actions: [
            if (!amenity.isNew)
              IconButton(
                icon: Icon(Icons.history),
                tooltip: loc.editorHistory,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VersionsPage(amenity),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(Icons.view_list),
              tooltip: loc.editorTags,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TagEditorPage(amenity)));
                // Expect the amenity to change.
                setState(() {});
              },
            ),
          ],
        ),
        body: preset == null
            ? Center(child: Text(loc.editorLoadingPreset))
            : Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: ListView(children: buildBlocks(context)),
                    ),
                  ),
                  buildSaveButtons(context, modified),
                ],
              ),
      ),
    );
  }

  List<Widget> buildBlocks(BuildContext context) {
    final blocks = <Widget>[
      buildMap(context),
      DuplicateWarning(amenity: amenity),
    ];
    bool hadButtons = false;
    for (final group in fieldGroups) {
      if (group.fields.isEmpty) continue;
      if (group.title != null) {
        if (group.collapsed && !hadButtons) {
          blocks.addAll([
            buildTopButtons(context),
            SizedBox(height: 10.0),
          ]);
          hadButtons = true;
        }
        blocks.add(ExpansionTile(
          title: Text(group.title!),
          initiallyExpanded: !group.collapsed,
          children: [buildFields(group)],
        ));
      } else {
        blocks.addAll([
          buildFields(group),
          SizedBox(height: 20),
        ]);
      }
    }
    if (!hadButtons)
      blocks.addAll([
        buildTopButtons(context),
        SizedBox(height: 20.0),
      ]);
    return blocks;
  }

  Widget buildTopButtons(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final kind = ElementKind.matchChange(amenity);

    return Container(
      padding: EdgeInsets.only(right: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Display "closed" button just for amenities.
          if (kind == ElementKind.amenity)
            MaterialButton(
              color: amenity.isDisused ? Colors.brown : Colors.orange,
              textColor: Colors.white,
              child: Text(amenity.isDisused
                  ? loc.editorMarkActive
                  : loc.editorMarkDefunct),
              onPressed: () {
                setState(() {
                  amenity.toggleDisused();
                });
              },
            ),
          SizedBox(width: 10.0),
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text(amenity.isDeleted
                ? loc.editorRestore
                : kind == ElementKind.building
                    ? loc.editorDeleteBuilding
                    : loc.editorMissing),
            onPressed: () async {
              if (amenity.isDeleted) {
                setState(() {
                  amenity.isDeleted = false;
                });
              } else {
                if (kind != ElementKind.building)
                  deletionDialog(loc);
                else
                  deleteAndClose();
              }
            },
          ),
        ],
      ),
    );
  }

  final MapController mapController = MapController();

  Widget buildMap(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.location_pin),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 100.0,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: amenity.location,
                initialZoom: 17,
                initialRotation: ref.watch(rotationProvider),
                interactionOptions:
                    InteractionOptions(flags: InteractiveFlag.none),
                keepAlive:
                    true, // see https://github.com/fleaflet/flutter_map/issues/1892
                onTap: !amenity.canMove
                    ? null
                    : (pos, center) async {
                        final newLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MapChooserPage(location: amenity.location),
                          ),
                        );
                        if (newLocation != null) {
                          setState(() {
                            amenity.location = newLocation;
                          });
                          mapController.move(
                              newLocation, mapController.camera.zoom);
                        }
                      },
              ),
              children: [
                ref.watch(baseImageryProvider).buildLayer(),
                ...ref.watch(overlayImageryProvider).map((i) => i.buildLayer()),
                MarkerLayer(
                  markers: [
                    if (amenity.canMove)
                      Marker(
                        point: amenity.location,
                        rotate: true,
                        alignment: Alignment(0.84, -0.7),
                        width: 150.0,
                        height: 30.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_pin),
                            SizedBox(width: 2.0),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text(loc.editorMove),
                            ),
                          ],
                        ),
                      ),
                    if (!amenity.canMove)
                      PinMarker(amenity.location,
                          color: Colors.red.shade900, blend: false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFields(EditorFields fields) {
    double labelWidth = fields.iconLabels ? 50 : 150;
    final List<Widget> rows = [];
    final tags = amenity.getFullTags();
    for (final field in fields.fields) {
      bool isMandatory = fields.mandatoryKeys.contains(field.key);
      final color = !isMandatory
          ? null
          : (field.hasRelevantKey(tags) ? Colors.green : Colors.red.shade800);

      rows.add(Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flexible(fit: FlexFit.loose, flex: 2, child: Text(fields[index].label)),
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: labelWidth >= 100
                  ? Text(field.label, style: TextStyle(color: color))
                  : Icon(field.icon ?? Icons.sms, color: color),
            ),
          ),
          // SizedBox(width: 5.0),
          Expanded(
            flex: 3,
            child: field.buildWidget(amenity),
          ),
        ],
      ));
    }

    return Column(children: rows);
  }

  Widget buildSaveButtons(BuildContext context, bool modified) {
    final loc = AppLocalizations.of(context)!;
    final bool needsCheck = amenity.age >= kOldAmenityDaysEditor &&
        ElementKind.needsCheck.matchesChange(amenity);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // padding: EdgeInsets.only(bottom: bottomPadding),
      color: modified ? Colors.green : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              disabledColor: Colors.white,
              disabledTextColor: Colors.grey,
              child: Padding(
                child: Text(
                  loc.editorSave,
                  style: TextStyle(fontSize: 20.0),
                ),
                padding:
                    EdgeInsets.only(top: 13.0, bottom: 13.0 + bottomPadding),
              ),
              onPressed: !modified
                  ? null
                  : () async {
                      await confirmDisused(context);
                      saveAndClose();
                    },
            ),
          ),
          if (!modified && needsCheck)
            Container(
              color: Colors.green,
              child: IconButton(
                icon: Icon(Icons.check),
                tooltip: loc.editorMarkChecked,
                color: Colors.white,
                iconSize: 30.0,
                onPressed: saveAndClose,
              ),
            ),
        ],
      ),
    );
  }
}
