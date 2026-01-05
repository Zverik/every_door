// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/fields/combo.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/helpers/plugin_context_list.dart';
import 'package:every_door/helpers/plugin_i18n.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/models/plugin.dart';
import 'package:every_door/models/preset.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:trie_search/trie.dart';

/// Manages plugin-installed field and preset definitions.
final pluginPresetsProvider = Provider((ref) => PluginPresetsProvider(ref));

typedef FieldBuilder = PresetField Function(Map<String, dynamic> data);

class PluginPresetsProvider {
  static final _logger = Logger('PluginPresetsProvider');
  final Ref _ref;

  final Map<String, PluginPreset> _presets = {};
  final Trie<String> _terms = Trie<String>();
  final Map<String, PresetField> _fieldsCache = {};
  final Map<String, FieldTemplate> _fields = {};
  final Map<String, Map<String, String?>> _presetTags = {};
  final Map<String, (Plugin, FieldBuilder)> _fieldBuilders = {};
  final PluginContextMap<String, PresetField> _presetFields =
      PluginContextMap({});

  PluginPresetsProvider(this._ref);

  void reset() {
    _terms.clear();
    _presets.clear();
    _fieldsCache.clear();
    _fields.clear();
    _fieldBuilders.clear();
    _presetFields.clear();
  }

  void addPreset(String key, Map<String, dynamic> data, Plugin plugin,
      PluginLocalizationsBranch loc) {
    MapEntry<String, String?> parseTagValue(String key, dynamic raw) {
      String? value;
      if (raw == null)
        value = null;
      else if (raw is String)
        value = raw == '*' ? null : raw;
      else if (raw is bool)
        value = raw ? 'yes' : 'no';
      else
        value = raw.toString();
      return MapEntry(key, value);
    }

    final id =
        key; // '$key-${plugin.id}' does not work, since referenced in plugins
    if (!data.containsKey('name'))
      throw Exception('Preset $key should have "name" attribute');
    if (!data.containsKey('tags'))
      throw Exception('Preset $key should have tags listed');

    final String name = data['name'];
    final Map<String, String?> tags =
        (data['tags'] as Map<String, dynamic>).map(parseTagValue);
    final Map<String, String> addTags =
        ((data['addTags'] ?? data['tags']) as Map<String, dynamic>)
            .map(parseTagValue)
            .cast();
    addTags.removeWhere((k, v) => v == '*');
    final Map<String, String?>? removeTags =
        (data['removeTags'] as Map<String, dynamic>?)?.map(parseTagValue);
    final onArea = (data['area'] as bool?) ?? true;
    final noStandard = (data['standard'] as bool?) == false;

    final String? iconStr = data['icon'];
    MultiIcon? iconImg;
    if (iconStr != null) {
      if (iconStr.startsWith('http://') || iconStr.startsWith('https://')) {
        iconImg = MultiIcon(imageUrl: iconStr, tooltip: name);
      } else {
        iconImg = plugin.loadIcon(iconStr);
      }
    }

    final fieldsData = {
      'fields': (data['fields'] as List<dynamic>?)?.whereType<String>() ?? [],
      'more': (data['moreFields'] as List<dynamic>?)?.whereType<String>() ?? [],
    };

    // Add the preset itself.
    final fromNSI = !data.containsKey('fields');
    _presets[id] = PluginPreset(
      id: id,
      name: name,
      addTags: addTags,
      removeTags: removeTags ?? const {},
      onArea: onArea,
      icon: iconImg,
      type: fromNSI ? PresetType.nsi : PresetType.normal,
      fieldData: fieldsData,
      noStandard: noStandard,
      localizations: loc,
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

  void addField(String id, Map<String, dynamic> data, Plugin plugin,
      PluginLocalizationsBranch loc) {
    if (!data.containsKey('key'))
      throw Exception('Field $id should have "key" attribute');
    _fields[id] = FieldTemplate(data, loc, plugin);
    _fieldsCache.remove(id);
  }

  void registerFieldType(String fieldType, Plugin plugin, FieldBuilder build) {
    _fieldBuilders[fieldType] = (plugin, build);
  }

  void registerPresetField(String fieldId, Plugin plugin, PresetField field) {
    _presetFields.set(plugin.id, fieldId, field);
  }

  void removeFieldsForPlugin(String pluginId) {
    final fieldIds = _fields.entries
        .where((f) => f.value.pluginId == pluginId)
        .map((e) => e.key);
    _fieldBuilders.removeWhere((k, v) => v.$1.id == pluginId);
    _presetFields.removeFor(pluginId);
    for (final id in fieldIds) {
      _fieldsCache.remove(id);
      _fields.remove(id);
    }
  }

  PresetField? getField(String id, Locale? locale) {
    if (_presetFields.containsKey(id)) return _presetFields[id];
    if (!_fieldsCache.containsKey(id)) {
      final field = _fields[id];
      if (field == null) return null;
      // Since a builder is usually added after a field definition,
      // we're fetching it here, when the field is being built.
      final fieldType = field.data['type'] ?? field.data['typ'];
      final builder = _fieldBuilders[fieldType]?.$2;
      _fieldsCache[id] = field.build(locale, builder);
    }
    return _fieldsCache[id];
  }

  List<Preset> getAutocomplete({
    required Iterable<String> terms,
    bool nsi = false,
    bool isArea = false,
    Locale? locale,
  }) {
    final presets = <String>{};
    for (final term in terms) {
      presets.addAll(_terms.getDetailsWithPrefix(term));
    }
    final type = nsi ? PresetType.nsi : PresetType.normal;

    return presets
        .map((id) => _presets[id])
        .whereType<PluginPreset>()
        .where((p) => p.type == type)
        .where((p) => !isArea || p.onArea)
        .map((p) => p.withLocale(locale))
        .toList();
  }

  Preset? getPresetForTags(Map<String, String> tags,
      {bool isArea = false, Locale? locale}) {
    int matched = 0;
    PluginPreset? best;
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
    return best?.withLocale(locale);
  }

  Map<String, Preset> getById(List<String> ids, Locale? locale) {
    // I failed to write it in one line :(
    Map<String, Preset> result = {};
    for (final id in ids) {
      final p = _presets[id];
      if (p != null) result[id] = p.withLocale(locale);
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
        final field = getField(name, locale);
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
          final field = getField(name, locale);
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

class PluginPreset extends Preset {
  final PluginLocalizationsBranch localizations;

  PluginPreset({
    required super.id,
    super.fields = const [],
    super.moreFields = const [],
    super.onArea = true,
    required super.addTags,
    super.removeTags = const {},
    required super.name,
    super.subtitle,
    super.icon,
    super.locationSet,
    super.fieldData,
    super.type = PresetType.normal,
    super.noStandard = false,
    required this.localizations,
  });

  Preset withLocale(Locale? locale) {
    return Preset(
      id: id,
      fields: fields,
      moreFields: moreFields,
      fieldData: fieldData,
      onArea: onArea,
      addTags: addTags,
      removeTags: removeTags,
      name: locale == null ? name : localizations.translate(locale, 'name'),
      subtitle: subtitle,
      icon: icon,
      type: type,
      noStandard: noStandard,
    );
  }
}

class FieldTemplate {
  final Map<String, dynamic> data;
  late final List<ComboOption> options;
  final PluginLocalizationsBranch localizations;
  final String pluginId;

  FieldTemplate(this.data, this.localizations, Plugin plugin)
      : pluginId = plugin.id {
    options = _buildComboOptions(plugin);
  }

  List<ComboOption> _buildComboOptions(Plugin plugin) {
    List<ComboOption> options = [];
    final dataOptions = data['options'];
    if (dataOptions != null && dataOptions is List) {
      final kReExtension = RegExp(r'\.[a-z]+$');
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
    return options;
  }

  PresetField build(Locale? locale, FieldBuilder? builder) {
    final copy = Map.of(data);
    final newOptions = List.of(options);
    if (locale != null) {
      for (final k in ['label', 'placeholder']) {
        if (copy.containsKey(k)) copy[k] = localizations.translate(locale, k);
      }
      if (options.isNotEmpty) {
        final labels = localizations.translateList(locale, 'labels');
        for (int i = 0; i < newOptions.length; i++) {
          if (labels.length > i) {
            newOptions[i] = newOptions[i].withLabel(labels[i]);
          }
        }
      }
    }

    return builder?.call(copy) ?? fieldFromJson(copy, options: newOptions);
  }
}
