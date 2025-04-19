import 'package:every_door/constants.dart';
import 'package:every_door/helpers/counter.dart';
import 'package:every_door/helpers/equirectangular.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/last_presets.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/models/preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

  
class TypeChooserPage extends ConsumerStatefulWidget {
  final LatLng? location;
  final bool launchEditor;

  const TypeChooserPage({this.location, this.launchEditor = true});

  @override
  ConsumerState createState() => _TypeChooserPageState();
}

class _TypeChooserPageState extends ConsumerState<TypeChooserPage> {
  static const String kOpenAIApiKeyPref = 'openai_api_key';

  List<Preset> presets = const [];
  DateTime resultsUpdated = DateTime.now();
  final controller = TextEditingController();
  int updateMutex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String apiKey = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updatePresets('');
    });
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final storedApiKey = prefs.getString(kOpenAIApiKeyPref) ?? '';
    setState(() {
      apiKey = storedApiKey;
    });
  }

  Future<void> _openCamera() async {
    if (apiKey == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You must configure OpenAI key in Settings first.'),
          ),
        );
    }
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
      maxWidth: 800,   
      maxHeight: 800,
    );
    if (photo != null) {
      setState(() {
        _isLoading = true;
      });

      // Convert the photo to bytes
      final bytes = await photo.readAsBytes();

      // Call OpenAI API with the photo and text
      final response = await _callOpenAI(bytes, '''
        You are experienced OpenStreetMap editor. 
        I will send you a photo of place and you need to return me a JSON with tags which should be assigned to given place.
        Main tags which I require is:
        - type (like shop=beauty or amenity=veterinary)
        - name
        But fill free to to also add other tags if you think they can be useful, BUT only if you are confident it is needed.
        If photo doesn't similar to something what should be mapped in OpenStreetMap don't try to infer tags and just return 
        status=FAILED.
        Format of JSON:
        ```
        {
           "status": ..., // SUCCESS or FAILED
           "tags": {
              "shop": "beauty",
              "name": "Beauty Shop 42"
              // other tags
           },
           "preset_id": "...", // should be based on type, e.g. shop/beauty or amenity/veterinary
           "preset_name": "..." // some name 
        }
        ```

        DO NOT USE MARKDOWN IN OUTPUT. It should be decodable by normal JSON parser.

      ''');

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        if (response['status'] == 'FAILED') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI could not determine tags for the photo.'),
            ),
          );
        } else {
              final tags = Map<String, String>.from(response['tags']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoiEditorPage(
                      location: widget.location,
                      preset: Preset(id: response['preset_id'] as String, addTags: tags, name: response['preset_name'] as String),
                    ),
                  ),
              );
          print('OpenAI Response: $response');
          // Handle the JSON response here
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to communicate with AI service.'),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _callOpenAI(
    Uint8List photoBytes,
    String prompt,
  ) async {
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    // Build the data‑URL for a JPEG
    final String base64Image = base64Encode(photoBytes);
    final String dataUrl = 'data:image/jpeg;base64,$base64Image';

    final Map<String, dynamic> body = {
      'model': 'gpt-4.1',
      'messages': [
        {
          'role': 'user',
          'content': [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {
                "url": dataUrl
              }
            }
          ]
        }
      ],
    };

    try {
      final encodedBody = jsonEncode(body);
      final byteSize = utf8.encode(encodedBody).length;
      print('Body size in characters: ${encodedBody.length}');
      print('Body size in bytes: $byteSize');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode(body),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        print('Response: ${responseBody}');

        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        return jsonDecode(jsonResponse['choices'][0]['message']['content']);
      } else {
        print('Failed [${response.statusCode}]: ${responseBody}');
        return null;
      }
    } catch (e) {
      print('Exception while calling OpenAI: $e');
      return null;
    }
  }

  Future<List<Preset>> _getPresetsAround(LatLng location,
      [int count = 3]) async {
    final locale = Localizations.localeOf(context);
    final editorMode = ref.read(editorModeProvider);
    var data = await ref
        .read(osmDataProvider)
        .getElements(location, kVisibilityRadius);
    data = data.where((e) {
      switch (e.kind) {
        case ElementKind.amenity:
          return editorMode == EditorMode.poi;
        case ElementKind.micro:
          return editorMode == EditorMode.micromapping;
        default:
          return false;
      }
    }).toList();
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

  updatePresets(String substring) async {
    final mutex = DateTime.now().millisecondsSinceEpoch;
    updateMutex = mutex;

    final prov = ref.read(presetProvider);
    final locale = Localizations.localeOf(context);
    if (substring.length < 2 && !reCJK.hasMatch(substring)) {
      final editorMode = ref.read(editorModeProvider);
      final defaultList = editorMode == EditorMode.micromapping
          ? kDefaultMicroPresets
          : kDefaultPresets;
      final newPresets = await prov.getPresetsById(defaultList, locale: locale);

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
      for (final p in presetsToAdd) newPresets.remove(p);
      if ((presetsToAdd.length + presetsAround.length) % 2 != 0) {
        if (presetsAround.isNotEmpty)
          presetsAround.removeLast();
        else if (presetsToAdd.length > 2)
          presetsToAdd.removeLast();
      }
      presetsToAdd.addAll(presetsAround);

      // Filter newPresets and check that we add no more than 4 items.
      newPresets.removeWhere((p) => !newPresets.contains(p));
      if (presetsToAdd.length + newPresets.length - defaultList.length > 4)
        presetsToAdd.removeRange(4, presetsToAdd.length);

      if (mounted && updateMutex == mutex) {
        setState(() {
          resultsUpdated = DateTime.now();
          presets = presetsToAdd + newPresets;
        });
      }
    } else {
      final editorMode = ref.read(editorModeProvider);

      final newPresets = await prov.getPresetsAutocomplete(substring,
          locale: locale,
          location: widget.location,
          nsi: editorMode == EditorMode.poi
              ? NsiQueryType.amenities
              : NsiQueryType.micromapping);

      // Add a fix me preset for entered string.
      newPresets.add(Preset.fixme(substring.trim()));

      if (mounted && updateMutex == mutex) {
        setState(() {
          resultsUpdated = DateTime.now();
          presets = newPresets;
          if (editorMode == EditorMode.poi) updateNSISubtitles(context);
        });
      }
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
    final loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Scaffold(
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
                        ? (preset.fromNSI
                            ? Colors.grey.withOpacity(0.2)
                            : kFieldColor.withOpacity(0.2))
                        : Colors.red.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  ),
                  onTap: () {
                    if (widget.launchEditor) {
                      print('Preset: ${preset}');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoiEditorPage(
                            location: widget.location,
                            preset: preset
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCamera,
            tooltip: 'AI',
            label: Text('AI'),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
