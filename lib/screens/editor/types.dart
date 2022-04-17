import 'package:every_door/constants.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/models/preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class TypeChooserPage extends ConsumerStatefulWidget {
  final LatLng? creatingLocation;

  const TypeChooserPage({this.creatingLocation});

  @override
  _TypeChooserPageState createState() => _TypeChooserPageState();
}

class _TypeChooserPageState extends ConsumerState<TypeChooserPage> {
  List<Preset> presets = const [];
  DateTime resultsUpdated = DateTime.now();
  final controller = TextEditingController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      updatePresets('');
    });
  }

  updatePresets(String substring) async {
    final prov = ref.read(presetProvider);
    final locale = Localizations.localeOf(context);
    if (substring.length < 2) {
      final editorMode = ref.read(editorModeProvider);
      final defaultList = editorMode == EditorMode.micromapping
          ? kDefaultMicroPresets
          : kDefaultPresets;
      final newPresets = await prov.getPresetsById(defaultList, locale: locale);
      setState(() {
        resultsUpdated = DateTime.now();
        presets = newPresets;
      });
    } else {
      final editorMode = ref.read(editorModeProvider);

      final newPresets = await prov.getPresetsAutocomplete(substring,
          locale: locale,
          location: widget.creatingLocation,
          includeNSI: editorMode == EditorMode.poi);

      // Add a fix me preset for entered string.
      newPresets.add(Preset.fixme(substring.trim()));

      setState(() {
        resultsUpdated = DateTime.now();
        presets = newPresets;
        if (editorMode == EditorMode.poi) updateNSISubtitles(context);
      });
    }
  }

  updateNSISubtitles(BuildContext context) async {
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
              hintText: 'Choose type...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                tooltip: 'Clear',
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
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      preset.subtitle,
                      style: TextStyle(
                          fontSize: 14.0, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                color: !preset.isFixme
                    ? kFieldColor.withOpacity(preset.fromNSI ? 0.4 : 0.2)
                    : Colors.red.withOpacity(0.2),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              ),
              onTap: () {
                if (widget.creatingLocation != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoiEditorPage(
                        location: widget.creatingLocation,
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
