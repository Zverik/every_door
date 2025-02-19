import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/fields/payment.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/widgets/pin_marker.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/last_presets.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/screens/editor/tags.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:every_door/screens/editor/versions.dart';
import 'package:every_door/widgets/duplicate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';

class PoiEditorPage extends ConsumerStatefulWidget {
  final OsmChange? amenity;
  final Preset? preset;
  final LatLng? location;

  const PoiEditorPage({this.amenity, this.preset, this.location});

  @override
  ConsumerState createState() => _PoiEditorPageState();
}

class _PoiEditorPageState extends ConsumerState<PoiEditorPage> {
  static final _logger = Logger('PoiEditorPage');
  late OsmChange amenity;
  Preset? preset;
  List<PresetField> fields = []; // actual fields
  List<PresetField> moreFields = [];
  List<PresetField> stdFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.amenity != null) {
      amenity = widget.amenity!.copy();
    } else {
      final tags =
          ref.read(lastPresetsProvider).getTagsForPreset(widget.preset!) ??
              widget.preset!.addTags;
      amenity = OsmChange.create(location: widget.location!, tags: tags);
    }
    amenity.addListener(onAmenityChange);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final locale = Localizations.localeOf(context);
      if (widget.preset == null) {
        updatePreset(locale, true);
      } else {
        // Preset and location should not be null
        preset = widget.preset!;
        updatePreset(locale, preset!.fromNSI);
      }
    });
  }

  @override
  dispose() {
    amenity.removeListener(onAmenityChange);
    super.dispose();
  }

  onAmenityChange() {
    setState(() {});
  }

  /// Whether we should display address and floor fields in the editor.
  bool needsAddress(Map<String, String> tags) {
    final kind = ElementKind.match(tags);
    if ({ElementKind.amenity, ElementKind.building, ElementKind.address}
        .contains(kind)) return true;
    const kAmenityLoc = {'atm', 'vending_machine', 'parcel_locker'};
    return kAmenityLoc.contains(tags['amenity']);
  }

  updatePreset(Locale locale, [bool detect = false]) async {
    await Future.delayed(Duration.zero); // to disconnect from initState
    final presets = ref.read(presetProvider);
    if (preset == null) detect = true;
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
      if (needsAddress(amenity.getFullTags())) {
        final bool needsStdFields =
            preset!.fields.length <= 1 || needsStandardFields();
        stdFields = await presets.getStandardFields(locale, needsStdFields);
        // Remove the field for level if the object is a building.
        if (amenity['building'] != null) {
          stdFields.removeWhere((e) => e.key == 'level');
        }

        // Move some fields to stdFields if present.
        if (!needsStdFields) {
          final hasStdFields = stdFields.map((e) => e.key).toSet();
          for (final f in preset!.fields) {
            if (PresetProvider.kStandardPoiFields.contains(f.key) &&
                !hasStdFields.contains(f.key)) {
              stdFields.add(f);
            }
            // Also move payment_multi.
            if (f.key == 'payment:' && !hasStdFields.contains('payment')) {
              stdFields.add(PaymentPresetField(label: 'Accept cards'));
            }
          }
        }

        // Add postcode to fields for buildings, moreFields for others.
        // The reason for this hack is that our addresses don't transfer postcodes.
        // But the addresses in the presets are indivisible, so we can't choose.
        final postcodeString =
            mounted ? AppLocalizations.of(context)?.buildingPostCode : null;
        final postcodeField = TextPresetField(
          key: "addr:postcode",
          label: postcodeString ?? "Postcode",
          keyboardType: TextInputType.visiblePassword,
          capitalize: TextFieldCapitalize.all,
        );
        final postcodeFirst = ElementKind.matchChange(
                amenity, [ElementKind.building, ElementKind.address]) !=
            ElementKind.unknown;
        if (postcodeFirst)
          preset!.fields.add(postcodeField);
        else {
          preset!.moreFields.insert(0, postcodeField);
        }

        // Add opening_hours to moreFields if it's not anywhere.
        if (!preset!.fields.any((field) => field.key == 'opening_hours') &&
            !preset!.moreFields.any((field) => field.key == 'opening_hours')) {
          final hoursField = await presets.getField('opening_hours', locale);
          preset!.moreFields.insert(0, hoursField);
        }
      } else {
        stdFields = [];
      }
      needRefresh = true;
    }
    if (needRefresh) {
      setState(() {
        extractFields();
      });
    }
  }

  bool needsStandardFields() {
    if (preset!.isFixme) return true;
    Set<String> allFields =
        (preset!.fields + preset!.moreFields).map((e) => e.key).toSet();
    return allFields.contains('opening_hours') && allFields.contains('phone');
  }

  extractFields() {
    final hasStdFields = stdFields.map((e) => e.key).toSet();
    hasStdFields.remove('internet_access');
    try {
      fields =
          preset!.fields.where((f) => !hasStdFields.contains(f.key)).toList();
    } on StateError {
      fields = [];
    }
    final tags = amenity.getFullTags();
    for (final f in preset!.moreFields) {
      if (hasStdFields.contains(f.key)) continue;
      if (f.hasRelevantKey(tags) || f.meetsPrerequisite(tags)) {
        fields.add(f);
      } else {
        moreFields.add(f);
      }
    }
  }

  changeType() async {
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
      fields = [];
      moreFields = [];
      stdFields = [];
    });
    // if disused, remove disused: prefix before removing tags
    // otherwise we may end up with disused:<old_mainKey>=* + <new_mainKey>=*
    if (amenity.isDisused) amenity.toggleDisused();
    oldPreset?.doRemoveTags(amenity);
    preset = newPreset;
    preset!.doAddTags(amenity);
    updatePreset(locale, preset!.fromNSI);
  }

  saveAndClose() {
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
    Navigator.pop(context);
    ref.read(needMapUpdateProvider).trigger();
  }

  deleteAndClose() {
    if (widget.amenity != null) {
      // No use deleting an amenity that just have been created.
      final changes = ref.read(changesProvider);
      if (amenity.isNew) {
        changes.deleteChange(amenity);
      } else {
        amenity.deleted = true;
        changes.saveChange(amenity);
      }
      ref.read(needMapUpdateProvider).trigger();
    }
    Navigator.pop(context);
  }

  deletionDialog(AppLocalizations loc) async {
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
      for (final k in amenity.getFullTags().keys)
        if (!k.startsWith('addr:') || k == 'addr:floor') amenity.removeTag(k);
      saveAndClose();
    }
  }

  confirmDisused(BuildContext context) async {
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
    final bool modified = widget.amenity == null || amenity != widget.amenity;
    final bool needsCheck = amenity.age >= kOldAmenityDaysEditor &&
        ElementKind.needsCheck.matchesChange(amenity);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

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
          title: GestureDetector(
            child: Text(preset?.name ?? amenity.name ?? 'Editor'),
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
                      child: ListView(
                        children: [
                          buildMap(context),
                          DuplicateWarning(amenity: amenity),
                          if (stdFields.isNotEmpty) ...[
                            buildFields(stdFields, 50),
                          ],
                          if (fields.isNotEmpty) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(),
                            ),
                            buildFields(fields),
                          ],
                          SizedBox(height: 20.0),
                          buildTopButtons(context),
                          SizedBox(height: 10.0),
                          if (moreFields.isNotEmpty) ...[
                            ExpansionTile(
                              title: Text(loc.editorMoreFields),
                              initiallyExpanded: false,
                              children: [
                                buildFields(moreFields),
                              ],
                            ),
                            SizedBox(height: 30.0),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
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
                              padding: EdgeInsets.only(
                                  top: 13.0, bottom: 13.0 + bottomPadding),
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
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildTopButtons(context) {
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
            child: Text(amenity.deleted
                ? loc.editorRestore
                : kind == ElementKind.building
                    ? loc.editorDeleteBuilding
                    : loc.editorMissing),
            onPressed: () async {
              if (amenity.deleted) {
                setState(() {
                  amenity.deleted = false;
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
                TileLayerOptions(kOSMImagery).buildTileLayer(),
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

  Widget buildFields(List<PresetField> fields, [double labelWidth = 150]) {
    final List<Widget> rows = [];
    final tags = amenity.getFullTags();
    const kMandatoryKeys = {
      'opening_hours',
      'level',
      'addr',
      'internet_access',
      'wheelchair',
      'phone',
      'payment'
    };
    for (final field in fields) {
      bool hasTags = field.hasRelevantKey(tags);
      bool isMandatory = kMandatoryKeys.contains(field.key);
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
                  ? Text(field.label)
                  : Icon(
                      field.icon ?? Icons.sms,
                      color: !isMandatory
                          ? null
                          : (hasTags ? Colors.green : Colors.red.shade800),
                    ),
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
}
