import 'package:every_door/constants.dart';
import 'package:every_door/helpers/counter.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/last_presets.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/models/preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class TypeChooserPage extends ConsumerStatefulWidget {
  final LatLng? location;
  final bool launchEditor;
  final ElementKindImpl? kinds;
  final List<String> defaults;

  const TypeChooserPage({
    this.location,
    this.launchEditor = true,
    this.kinds,
    this.defaults = const [],
  });

  @override
  ConsumerState createState() => _TypeChooserPageState();
}

class _TypeChooserPageState extends ConsumerState<TypeChooserPage> {
  List<Preset> presets = const [];
  DateTime resultsUpdated = DateTime.now();
  final controller = TextEditingController();
  int updateMutex = 0;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updatePresets('');
    });
  }

  Future<List<Preset>> _getPresetsAround(LatLng location,
      [int count = 3]) async {
    final locale = Localizations.localeOf(context);
    List<OsmChange> data = await ref
        .read(osmDataProvider)
        .getElements(location, kVisibilityRadius);
    if (widget.kinds != null) {
      data = data.where((e) => widget.kinds?.matchesChange(e) ?? true).toList();
    }
    if (data.isEmpty) return const [];

    // Sort by distance and trim.
    const distance = DistanceEquirectangular();
    data = data
        .where((element) =>
            distance(location, element.location) <= kVisibilityRadius)
        .toList();
    data.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));
    if (data.length > 10) data = data.sublist(0, 10);

    // Get presets for all elements.
    final presetProv = ref.read(presetProvider);
    final presetsCount = Counter<Preset>();
    for (final element in data) {
      final preset = await presetProv.getPresetForTags(element.getFullTags(),
          locale: locale);
      if (preset != Preset.defaultPreset && !preset.isFixme)
        presetsCount.add(preset);
    }

    // Sort and return most common.
    return presetsCount.mostOccurentItems(count: count).toList();
  }

  /// Regular expression to match Japanese and Chinese hieroglyphs, to allow 1-char search strings for these.
  /// Taken from https://stackoverflow.com/a/43419070
  final reCJK = RegExp(
      '^[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]');

  Future<void> updatePresets(String substring) async {
    final mutex = DateTime.now().millisecondsSinceEpoch;
    updateMutex = mutex;

    final prov = ref.read(presetProvider);
    final locale = Localizations.localeOf(context);
    if (substring.length < 2 && !reCJK.hasMatch(substring)) {
      final newPresets =
          await prov.getPresetsById(widget.defaults, locale: locale);

      // Add last presets.
      final presetsToAdd = <Preset>[];
      presetsToAdd.addAll(ref.read(lastPresetsProvider).getPresets());
      // Add presets from around.
      final presetsAround = <Preset>[];
      if (widget.location != null) {
        final presetsAroundTmp = await _getPresetsAround(widget.location!);
        for (final p in presetsAroundTmp)
          if (!presetsToAdd.contains(p)) presetsAround.add(p);
      }

      // Keep 2 or 4 (or 0) added presets.
      if ((presetsToAdd.length + presetsAround.length) % 2 != 0) {
        if (presetsAround.isNotEmpty)
          presetsAround.removeLast();
        else if (presetsToAdd.length > 2) presetsToAdd.removeLast();
      }
      presetsToAdd.addAll(presetsAround);

      // Filter newPresets and check that we add no more than 4 items.
      newPresets.removeWhere((p) => presetsToAdd.contains(p));
      if (presetsToAdd.length + newPresets.length - widget.defaults.length > 4)
        presetsToAdd.removeRange(4, presetsToAdd.length);

      if (mounted && updateMutex == mutex) {
        setState(() {
          resultsUpdated = DateTime.now();
          presets = presetsToAdd + newPresets;
        });
      }
    } else {
      final nsiPresets = await prov.getNSIAutocomplete(
        substring,
        location: widget.location,
        filter: widget.kinds,
      );
      final dbPresets = await prov.getPresetsAutocomplete(
        substring,
        locale: locale,
        location: widget.location,
      );
      final genPresets = await prov.getTagNamePresets(
        substring,
        filter: widget.kinds,
      );

      final newPresets = nsiPresets
          .take(kMaxNSIPresets)
          .followedBy(dbPresets)
          .followedBy(genPresets)
          .take(kMaxShownPresets)
          .toList();

      // Add a fix me preset for entered string.
      newPresets.add(Preset.fixme(substring.trim()));

      if (mounted && updateMutex == mutex) {
        setState(() {
          resultsUpdated = DateTime.now();
          presets = newPresets;
          if (newPresets.any((p) => p.fromNSI)) updateNSISubtitles(context);
        });
      }
    }
  }

  Future<void> updateNSISubtitles(BuildContext context) async {
    final upd = resultsUpdated;
    final prov = ref.read(presetProvider);
    final locale = Localizations.localeOf(context);
    final updated = await prov.fillNSIPresetNames(presets, locale: locale);
    if (mounted && resultsUpdated == upd) {
      setState(() {
        presets = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: loc.chooseType + '...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                tooltip: loc.chooseTypeClear,
                onPressed: () {
                  controller.clear();
                  updatePresets('');
                },
              ),
            ),
            onChanged: (value) {
              updatePresets(value);
            },
          ),
        ),
      ),
      body: ResponsiveGridList(
        minItemWidth: 170.0,
        horizontalGridSpacing: 5,
        verticalGridSpacing: 5,
        rowMainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final preset in presets)
            GestureDetector(
              child: ClipRect(child: PresetTile(preset)),
              onTap: () {
                if (widget.launchEditor) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoiEditorPage(
                        location: widget.location,
                        preset: preset,
                      ),
                    ),
                  );
                } else {
                  // Editing preset, return the new one.
                  Navigator.pop(context, preset);
                }
              },
            ),
        ],
      ),
    );
  }
}

class PresetTile extends StatelessWidget {
  final Preset preset;

  const PresetTile(this.preset, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (preset.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: preset.icon!.getWidget(icon: false, size: 24.0),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.name,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 4.0),
              Text(
                preset.subtitle,
                style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
      color: !preset.isFixme
          ? (preset.fromNSI
              ? Colors.grey.withValues(alpha: 0.2)
              : kFieldColor.withValues(alpha: 0.2))
          : Colors.red.withValues(alpha: 0.2),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    );
  }
}
