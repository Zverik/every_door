import 'package:every_door/fields/combo.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:trie_search/trie.dart';

final pluginPresetsProvider = Provider((ref) => PluginPresetsProvider(ref));

class PluginPresetsProvider {
  static final _logger = Logger('PluginPresetsProvider');
  final Ref _ref;

  final Map<String, Preset> _presets = {};
  final Trie<String> _terms = Trie<String>();
  final Map<String, PresetField> _fields = {};
  final Map<String, Map<String, String?>> _presetTags = {};

  PluginPresetsProvider(this._ref);

  void reset() {
    _terms.clear();
    _presets.clear();
    _fields.clear();
  }

  void addPreset(String key, Map<String, dynamic> data, Plugin plugin) {
    final id =
        key; // '$key-${plugin.id}' does not work, since referenced in plugins
    // TODO: keep all translations?
    final String name = data['name'];
    final Map<String, String?> tags = (data['tags'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()))
        .map((k, v) => MapEntry(k, v == '*' ? null : v));
    final Map<String, String> addTags =
        ((data['addTags'] ?? data['tags']) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v.toString()));
    addTags.removeWhere((k, v) => v == '*');
    final Map<String, String?>? removeTags =
        (data['removeTags'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString()))
            .map((k, v) => MapEntry(k, v == '*' ? null : v));
    final onArea = (data['area'] as bool?) != false;
    final noStandard = (data['standard'] as bool?) == false;
    final String? iconStr = data['icon'];
    String? iconUrl;
    MultiIcon? iconImg;
    if (iconStr != null) {
      if (iconStr.startsWith('http')) {
        iconUrl = iconStr;
      } else {
        // Not supported anywhere currently.
        iconImg = plugin.loadIcon(iconStr);
      }
    }

    final fieldsData = {
      'fields': (data['fields'] as List<dynamic>?)?.whereType<String>() ?? [],
      'more': (data['moreFields'] as List<dynamic>?)?.whereType<String>() ?? [],
    };

    // Add the preset itself.
    final fromNSI = !data.containsKey('fields');
    _presets[id] = Preset(
      id: id,
      name: name,
      addTags: addTags,
      removeTags: removeTags ?? const {},
      onArea: onArea,
      icon: iconUrl,
      fromNSI: fromNSI,
      fieldData: fieldsData,
      noStandard: noStandard,
    );
    if (!fromNSI) _presetTags[id] = tags;

    // Prepare terms for autocomplete.
    final terms = <String>{};
    final nonSpace = RegExp(r'\W+');
    terms.addAll(name.split(nonSpace).map((s) => normalizeString(s)));
    final Iterable<String>? presetTerms =
        (data['terms'] as List<dynamic>?)?.whereType<String>();
    terms.addAll(name.split(nonSpace).map((s) => normalizeString(s)));
    if (presetTerms != null) {
      terms.addAll(terms.map((s) => normalizeString(s)));
    }
    _terms.insertAll(terms.map((t) => MapEntry(t, id)).toList());
    // TODO?
  }

  void removePreset(String key, Plugin plugin) {
    // final id = '$key-${plugin.id}';
    _presets.remove(key);
    // TODO: terms?
  }

  void addField(String id, Map<String, dynamic> data, Plugin plugin) {
    final copy = Map.of(data);
    // TODO: translate labels?
    // TODO: options
    List<ComboOption> options = [];
    final dataOptions = data['options'];
    final kReExtension = RegExp(r'\.[a-z]+$');
    if (dataOptions != null && dataOptions is List) {
      final labels = (data['labels'] as List?)?.whereType<String>().toList();
      for (int i = 0; i < dataOptions.length; i++) {
        final label = labels == null || labels.length <= i ? null : labels[i];
        final icon = label != null && kReExtension.hasMatch(label)
            ? plugin.loadIcon(label)
            : null;
        options.add(ComboOption(
          dataOptions[i].toString(),
          label: icon == null ? (label ?? dataOptions[i].toString()) : null,
          widget: icon?.getWidget(size: 40.0, icon: false),
        ));
      }
    }
    final field = fieldFromPlugin(copy, options: options);
    // TODO?
    _fields[id] = field;
  }

  void removeField(String id) {
    _fields.remove(id);
  }

  PresetField? getField(String id) {
    return _fields[id]; // TODO: locale?
  }

  List<Preset> getAutocomplete({
    required Iterable<String> terms,
    bool nsi = false,
    bool isArea = false,
  }) {
    final presets = <String>{};
    for (final term in terms) {
      presets.addAll(_terms.getDetailsWithPrefix(term));
    }

    return presets
        .map((id) => _presets[id])
        .whereType<Preset>()
        .where((p) => p.fromNSI == nsi)
        .where((p) => !isArea || p.onArea)
        .toList();
  }

  Preset? getPresetForTags(Map<String, String> tags,
      {bool isArea = false, Locale? locale}) {
    int matched = 0;
    Preset? best;
    for (final e in _presetTags.entries) {
      if (e.value.length <= matched) continue;
      bool failed = false;
      for (final tag in e.value.entries) {
        if (tag.value == null && tags.containsKey(tag.key)) continue;
        if (tag.value != null && tags[tag.key] == tag.value) continue;
        failed = true;
        break;
      }
      if (!failed) {
        final newBest = _presets[e.key];
        if (newBest != null && (!isArea || newBest.onArea)) {
          best = newBest;
          matched = e.value.length;
        }
      }
    }
    return best;
  }

  Map<String, Preset> getById(List<String> ids) {
    // I failed to write it in one line :(
    Map<String, Preset> result = {};
    for (final id in ids) {
      final p = _presets[id];
      if (p != null) result[id] = p;
    }
    return result;
  }

  Future<Preset> loadFields(Preset preset, Locale? locale) async {
    final data = preset.fieldData;
    if (data == null) return preset;

    final dataFields = data['fields'] as Iterable<String>;
    final dataMore = data['more'] as Iterable<String>;

    // 1. Get all fields registered in the database, including plugin fields.
    final pprov = _ref.read(presetProvider);
    final fieldMap = await pprov.getFieldsByName(
        dataFields.followedBy(dataMore).where((f) => !f.startsWith('@')),
        locale);

    // This map stores presets we load from the database.
    final cachedPresets = <String, Preset>{};

    // 2. Resolve fields in the first list.
    final fields = <PresetField>[];
    for (final name in dataFields) {
      if (name.startsWith('@')) {
        // If a field name starts with "@", add fields from the preset with this name.
        if (cachedPresets.containsKey(name)) {
          fields.addAll(cachedPresets[name]!.fields);
        } else {
          // Here we do not allow querying plugin presets. Probably not ideal,
          // since you cannot have inter-dependent presets in your plugin.
          // The reason was to avoid an infinite loop when redefining
          // a standard database preset (and it goes to fetch all the
          // fields from the plugin version).
          final presets = await pprov.getPresetsById([name.substring(1)],
              locale: locale, plugins: false);
          if (presets.isNotEmpty) {
            final p = await pprov.getFields(presets.first,
                locale: locale, plugins: false);
            cachedPresets[name] = p;
            fields.addAll(p.fields);
          }
        }
      } else if (fieldMap.containsKey(name)) {
        // If it's a standard field, add it.
        fields.add(fieldMap[name]!);
      } else {
        // Otherwise we hope it's a plugin-defined field.
        final field = getField(name);
        if (field != null) {
          fields.add(field);
        } else {
          _logger.warning('Missing field for preset ${preset.id}: $name');
        }
      }
    }

    // 3. Resolve fields in the "more" list.
    final moreFields = <PresetField>[];
    if (dataMore.isEmpty) {
      // Use more fields from a preset referenced in fields.
      for (final preset in cachedPresets.values) {
        moreFields.addAll(preset.moreFields);
        break;
      }
    } else {
      // Yes, it mostly duplicates the thing above. And can be extracted into
      // a function. But the overhead would be too big, and the entire thing
      // would be less readable than now. I tried.
      for (final name in dataMore) {
        if (name.startsWith('@')) {
          if (cachedPresets.containsKey(name)) {
            moreFields.addAll(cachedPresets[name]!.moreFields);
          } else {
            final presets = await pprov.getPresetsById([name.substring(1)],
                locale: locale, plugins: false);
            if (presets.isNotEmpty) {
              final p = await pprov.getFields(presets.first,
                  locale: locale, plugins: false);
              cachedPresets[name] = p;
              moreFields.addAll(p.moreFields);
            }
          }
        } else if (fieldMap.containsKey(name)) {
          moreFields.add(fieldMap[name]!);
        } else {
          final field = getField(name);
          if (field != null) {
            moreFields.add(field);
          } else {
            _logger.warning('Missing field for preset ${preset.id}: $name');
          }
        }
      }
    }

    return preset.withFields(fields, moreFields);
  }
}
