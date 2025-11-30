import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/payment.dart';
import 'package:every_door/fields/room.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/fields/wifi.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/helpers/nsi_features.dart';
import 'package:every_door/providers/add_presets.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/models/preset.dart';
import 'package:logging/logging.dart';
import 'dart:io' as io;
import 'dart:ui' show Locale;
import 'dart:convert' show JsonDecoder, jsonDecode;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

final presetProvider = Provider((ref) => PresetProvider(ref));

enum NsiQueryType { none, amenities, micromapping }

class PresetProvider {
  static const kDbVersion = "dbVersion";
  static final _logger = Logger('PresetProvider');

  Database? _db;
  late final LocationMatcher locationMatcher;
  bool ready = false;
  bool processingCombos = false;
  final Ref _ref;
  final Map<String, PresetField> _fieldCache = {};

  PresetProvider(this._ref) {
    initMatcher();
    initDatabase();
  }

  void initMatcher() {
    final data = JsonDecoder().convert(nsiFeaturesRaw);
    locationMatcher = LocationMatcher({
      'features': data['features'].whereType<Map<String, dynamic>>().toList()
    });
  }

  Future<void> initDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbFile = io.File(path.join(appDir.path, 'presets.db'));
    final prefs = await SharedPreferences.getInstance();

    var needCopy = true;
    if (!kOverwritePresets || !kDebugMode) {
      if (await dbFile.exists()) {
        final lastVersion = prefs.getString(kDbVersion);
        if (lastVersion == kAppVersion) {
          needCopy = false;
        }
      }
    }

    if (needCopy) {
      final data = await rootBundle.load('assets/presets.db');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // final unpacked = io.GZipCodec().decode(bytes);
      await dbFile.writeAsBytes(bytes, flush: true);
      prefs.setString(kDbVersion, kAppVersion);
      await clearComboCache();
    }

    _db = await openDatabase(dbFile.path);
    ready = true;
  }

  Future _waitUntilReady() async {
    await Future.doWhile(
        () => Future.delayed(Duration(milliseconds: 100)).then((_) => !ready));
  }

  String _toSqlString(String s) => "'" + s.replaceAll("'", "''") + "'";

  String _localeCTE(Locale? locale) {
    final langs = <String>[];
    if (locale != null) {
      langs.add(locale.toLanguageTag());
      langs.add(locale.languageCode);
    }
    langs.add('en');
    langs.add('tag'); // Special marker for tag values
    final values = <String>[];
    for (int i = 0; i < langs.length; i++)
      values.add("(${_toSqlString(langs[i])}, ${i + 1})");
    return "langs (lang, lscore) as (values ${values.join(',')})";
  }

  Future<List<Preset>> getNSIAutocomplete(String query,
      {LatLng? location,
      ElementKindImpl? filter,
      int limit = kMaxNSIPresets}) async {
    // Check for the plugin presets.
    final fromPlugins = _ref
        .read(pluginPresetsProvider)
        .getAutocomplete(terms: [normalizeString(query)], nsi: true);

    // Considering database loaded at this point.
    const sql = '''
    with matches as (
      select nsi_id, min(length(term)) as term_len
      from nsi_terms
      where term like ?
      group by nsi_id
    )
    select nsi.* from nsi
    inner join matches on nsi.id = nsi_id
    order by term_len, locations is null
    ''';

    // Query the database.
    final results = await _db!.rawQuery(sql, [normalizeString(query) + '%']);
    Iterable<Preset> nsiResults =
        fromPlugins.followedBy(results.map((e) => Preset.fromNSIJson(e)));

    // Filter by location.
    if (location != null) {
      nsiResults = nsiResults.where((p) =>
          p.locationSet == null ||
          locationMatcher(
              location.longitude, location.latitude, p.locationSet!));
    }

    // Filter by type.
    if (filter != null) {
      nsiResults = nsiResults.where((p) => filter.matchesTags(p.addTags));
    }

    return nsiResults.take(limit).toList();
  }

  Future<List<Preset>> fillNSIPresetNames(List<Preset> suggested,
      {Locale? locale}) async {
    final List<Preset> results = [];
    for (final nsi in suggested) {
      if (nsi.type == PresetType.nsi) {
        final preset = await getPresetForTags(nsi.addTags, locale: locale);
        results.add(preset == Preset.defaultPreset
            ? nsi
            : nsi.withSubtitle(preset.name));
      } else
        results.add(nsi);
    }
    return results;
  }

  Future<List<Preset>> getPresetsAutocomplete(String query,
      {bool isArea = false,
      Locale? locale,
      LatLng? location,
      int limit = kMaxShownPresets}) async {
    final terms = query
        .split(' ')
        .where((s) => s.length >= 2)
        .take(3)
        .map((s) => normalizeString(s));
    if (terms.isEmpty) return [];

    // Query the plugin presets.
    final fromPlugins = _ref
        .read(pluginPresetsProvider)
        .getAutocomplete(terms: terms, nsi: false, locale: locale);

    // Do the big database query.
    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    final isAreaClause = isArea ? 'where can_area = 1' : '';
    final termsClause = terms.map((_) => 'term like ?').join(' or ');
    final sql = '''
    with $langCTE
    , found as (
      select preset_name, max(score) as score, group_concat(term) as terms
      from preset_terms
      where ($termsClause)
      and lang in (select lang from langs)
      group by preset_name
    )
    select p.*, t.name as loc_name, lscore, terms
    from presets p
    inner join found on found.preset_name = p.name
    left join preset_tran t on t.preset_name = p.name
    inner join langs on langs.lang = t.lang
    $isAreaClause
    order by score desc, lscore;
    ''';
    final results = await _db!.rawQuery(sql, terms.map((t) => '$t%').toList());

    final presets = fromPlugins; // no need to copy
    final seenPresets = presets.map((p) => p.id).toList();
    for (final row in results) {
      // Check that both terms are present.
      final foundTerms = (row['terms'] as String).split(',');
      if (!terms.every(
          (term) => foundTerms.any((element) => element.startsWith(term))))
        continue;

      if (seenPresets.contains(row['name'])) continue;
      seenPresets.add(row['name'] as String);

      final preset = Preset.fromJson(row);
      if (location != null && preset.locationSet != null) {
        // Test that the location is correct.
        if (!locationMatcher(
            location.longitude, location.latitude, preset.locationSet!))
          continue;
      }

      presets.add(preset);
      if (presets.length >= limit) break;
    }
    return presets;
  }

  Future<List<Preset>> getTagNamePresets(String query,
      {ElementKindImpl? filter, int limit = kMaxShownPresets}) async {
    filter ??= ElementKind.everything;
    final terms = query
        .split(' ')
        .where((s) => s.length >= 2)
        .take(3)
        .map((s) => normalizeString(s));
    if (terms.isEmpty) return [];

    if (!ready) await _waitUntilReady();
    final termsClause = terms.map((_) => 'term like ?').join(' or ');

    final sql = '''
    select key, value, max(usage) as usage, group_concat(term) as terms
    from taglist where ($termsClause) group by 1, 2
    ''';
    final results = [
      // We're creating a mutable list from a read-only one.
      ...await _db!.rawQuery(sql, terms.map((t) => '$t%').toList())
    ];

    // Sort by usage, descending.
    results.sort((a, b) => (b['usage'] as int).compareTo(a['usage'] as int));

    final presets = <Preset>[];
    for (final row in results) {
      // Check that both terms are present.
      final foundTerms = (row['terms'] as String).split(',');
      if (!terms.every(
          (term) => foundTerms.any((element) => element.startsWith(term))))
        continue;

      // Skip if we don't support this tag.
      final k = row['key'] as String;
      final v = row['value'] as String;
      if (!filter.matchesTags({k: v})) continue;

      presets.add(Preset.poi(row));
      if (presets.length >= limit) break;
    }
    return presets;
  }

  Future<Preset> getPresetForTags(Map<String, String> tags,
      {bool isArea = false, Locale? locale}) async {
    if (tags.isEmpty) {
      return Preset.defaultPreset;
    }
    // Accommodate for fix me preset
    if (tags['amenity'] == 'fixme') {
      return Preset.fixme(tags['fixme:type'] ?? 'unknown');
    }

    // Check the plugin presets.
    final fromPlugins = _ref
        .read(pluginPresetsProvider)
        .getPresetForTags(tags, isArea: isArea, locale: locale);
    if (fromPlugins != null) return fromPlugins;

    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    final tagValues = tags.entries
        .map((e) => "(${_toSqlString(e.key)},${_toSqlString(e.value)})")
        .join(',');
    final tagCTE = "tags (tkey, tvalue) as (values $tagValues)";
    final isAreaClause = isArea ? 'where can_area = 1' : '';
    final sql = '''
    with $langCTE, $tagCTE
    ,matches as (
      select preset_name, count(*) as tag_count, count(tkey) as match_count,
        count(value) as full_tag_count
      from preset_tags
      left join tags on key = tkey and (value is null or value = tvalue)
      group by preset_name
      having match_count > 0
    ),
    found as (
      select name
      from presets
        inner join matches on name = preset_name and tag_count = match_count
      $isAreaClause
      order by match_count desc, full_tag_count desc, match_score desc,
        length(name) desc, name
      limit 1
    )
    select p.*, t.name as loc_name
    from found f
    left join presets p on f.name = p.name
    left join preset_tran t on t.preset_name = f.name
    inner join langs on langs.lang = t.lang
    order by lscore limit 1
    ''';
    final results = await _db!.rawQuery(sql);
    Preset preset =
        results.isEmpty ? Preset.defaultPreset : Preset.fromJson(results.first);

    if (preset.isGeneric) {
      // If the first result is generic (amenity=*), look in the taglist table.
      final tagSql = '''
      with $tagCTE
      select key, value
      from taglist inner join tags on tkey = key and tvalue = value
      order by usage desc limit 1
      ''';
      final results2 = await _db!.rawQuery(tagSql);
      if (results2.isNotEmpty) {
        preset = Preset.poi(results2.first);
      }
    }

    return preset;
  }

  Future<List<Preset>> getPresetsById(List<String> ids,
      {Locale? locale, bool plugins = true}) async {
    if (ids.isEmpty) return [];
    final Map<String, Preset> fromPlugins =
        plugins ? _ref.read(pluginPresetsProvider).getById(ids, locale) : {};

    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    final questions = List.filled(ids.length, '?').join(',');
    // TODO: fix row_number()
    final sql = '''
    with $langCTE
      select p.*, t.name as loc_name
      from presets p
      left join preset_tran t on t.preset_name = p.name
      inner join langs on langs.lang = t.lang
      where p.name in ($questions)
      order by lscore
    ''';
    final results = await _db!.rawQuery(sql, ids);
    final presets = fromPlugins; // no point in copying
    final seenPresets = Set.of(presets.keys);
    for (final row in results) {
      final String name = row['name'] as String;
      if (seenPresets.contains(name)) continue;
      seenPresets.add(name);
      presets[name] = Preset.fromJson(row);
    }
    if (presets.length != ids.length) {
      _logger.warning(
          'getPresetsById fail: for ${ids.length} ids got ${presets.length} results.');
    }
    return ids.map((e) => presets[e]).whereType<Preset>().toList();
  }

  static const kCachedCombosTableName = 'cached_combos';

  Future<void> clearComboCache() async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(kCachedCombosTableName);
  }

  Future<void> _updateComboCache(String key, Iterable<String> options) async {
    final database = await _ref.read(databaseProvider).database;
    await database.insert(
      kCachedCombosTableName,
      {'key': key, 'options': options.join('\\')},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>?> _fetchComboCache(String key) async {
    final database = await _ref.read(databaseProvider).database;
    final result = await database
        .query(kCachedCombosTableName, where: 'key = ?', whereArgs: [key]);
    return result.isEmpty
        ? null
        : (result.first['options'] as String).split('\\');
  }

  /// For each combo key, get and sort values according to downloaded data.
  Future<void> cacheComboOptions() async {
    if (processingCombos) return;
    _logger.fine('Starting global combo values caching');
    final timeStart = DateTime.now().millisecondsSinceEpoch;
    processingCombos = true;
    // Most used fields to be processed first.
    const kMostUsedFields = [
      'wheelchair',
      'level',
      'internet_access',
      'internet_access/fee',
      'payment_multi',
      'currency_multi',
      'stroller',
      'smoking',
      'second_hand',
      'access_simple',
      'material',
      'manufacturer',
      'payment_multi_fee',
      'baby_feeding',
      'building',
      'product',
      'operator/type',
      'diet/multi',
      'cuisine',
      'reservation',
      'takeaway',
    ];

    // Get all fields with type like "combo".
    final List<Map<String, dynamic>> fieldsReadOnly = await _db!.query(
      'fields',
      where: "typ = 'radio' or typ like '%ombo'",
      columns: ['name', 'typ', 'key', 'options'],
    );

    // Sort by inclusion in the most used fields list.
    final fields = List.of(fieldsReadOnly);
    fields.sort((a, b) => (kMostUsedFields.contains(a['name']) ? 0 : 1)
        .compareTo(kMostUsedFields.contains(b['name']) ? 0 : 1));

    // For each field, refresh the cache.
    for (final field in fields) {
      await _getComboOptions(field, useCache: false);
    }
    processingCombos = false;

    final timeTook =
        ((DateTime.now().millisecondsSinceEpoch - timeStart) / 1000).round();
    _logger.fine('Finished processing combo options, took $timeTook seconds');
  }

  Future<List<ComboOption>> _getComboOptions(Map<String, dynamic> field,
      {bool useCache = true, bool presetOnly = false}) async {
    final String typ = (field['typ']) as String;
    bool needed =
        typ.endsWith("ombo") || typ == 'radio' || typ == 'defaultCheck';
    if (!needed) return const [];
    if (typ == 'defaultCheck') presetOnly = true;

    final loc = field['loc_options'] != null
        ? jsonDecode(field['loc_options'])
        : <String, String>{};

    // Check in the combo cache.
    if (!presetOnly && useCache) {
      final cached = await _fetchComboCache(field['key']);
      if (cached != null)
        return cached.map((e) => ComboOption(e, label: loc[e])).toList();
    }

    // First add the options from the preset.
    final List<String> options = [];
    if (field['options'] != null) {
      options.addAll((jsonDecode(field['options']) as List).cast<String>());
    }

    if (!presetOnly) {
      // Get options from taginfo.
      // Store them separately to prioritize preset options.
      final tiOptions = <String>[];
      final results = await _db!
          .query('combos', where: 'key = ?', whereArgs: [field['key']]);
      if (results.isNotEmpty) {
        final existing = Set.of(options);
        tiOptions.addAll((results.first['options'] as String)
            .split('\\')
            .where((v) => !existing.contains(v)));
      }

      // Count values on the map.
      final counter =
          await _ref.read(osmDataProvider).getComboOptionsCount(field['key']);
      if (counter.isNotEmpty) {
        mergeSort(options,
            compare: (a, b) => (counter[b] ?? 0).compareTo(counter[a] ?? 0));
        mergeSort(tiOptions,
            compare: (a, b) => (counter[b] ?? 0).compareTo(counter[a] ?? 0));
      }
      options.addAll(tiOptions);

      // Store the result in the cache.
      _updateComboCache(field['key'], options);
    }

    // Return the result wrapped in a ComboOption.
    return options.map((e) => ComboOption(e, label: loc[e])).toList();
  }

  static const kSkipFields = {'opening_hours/covid19', 'not/name', 'shop'};

  Future<Preset> getFields(Preset preset,
      {Locale? locale, LatLng? location, bool plugins = true}) async {
    if (preset.type == PresetType.fixme) {
      // "fixme:type" is in "more fields", because [isFixme] can be set
      // for non-fixme presets, e.g. from the taginfo list.
      return preset.withFields(
          [], [TextPresetField(key: 'fixme:type', label: 'Fixme type')]);
    }

    if (preset.type == PresetType.taginfo) {
      final fields = <String>[];
      if (ElementKind.amenity.matchesTags(preset.addTags)) {
        fields
            .addAll(['name', 'operator', 'opening_hours', 'phone', 'website']);
      } else {
        fields.addAll(['name', 'operator', 'material', 'height', 'direction']);
      }

      final results = await getFieldsByName(fields, locale);
      return preset.withFields(
        fields.map((name) => results[name]).whereType<PresetField>().toList(),
        [],
      );
    }

    if (!ready) await _waitUntilReady();
    if (plugins) {
      final fromPlugin =
          await _ref.read(pluginPresetsProvider).loadFields(preset, locale);
      if (fromPlugin.fields.isNotEmpty) return fromPlugin;
    }

    final langCTE = _localeCTE(locale);
    // TODO: fix row_number()
    final sql = '''
    with $langCTE
    , pfields as (
      select field, required, pos, 0 as universal
      from preset_fields where preset_name = ?
      union all
      select name as field, 0, 100, 1
      from fields where universal = 1
    )
    select f.*, t.label as loc_label,
      t.placeholder as loc_placeholder,
      t.options as loc_options,
      pf.pos, pf.required, pf.universal,
      lscore
    from pfields pf
    inner join fields f on f.name = pf.field
    left join field_tran t on t.field_name = pf.field
    inner join langs on langs.lang = t.lang
    order by pos, lscore
    ''';
    final results = await _db!.rawQuery(sql, [preset.id]);
    if (results.isEmpty) return preset;
    List<PresetField> fields = [];
    List<PresetField> moreFields = [];
    List<PresetField> universalFields = [];
    final seenFields = <String>{};
    for (final row in results) {
      final name = row['name'] as String;
      if (seenFields.contains(name)) continue;
      if (kSkipFields.contains(name)) continue;
      seenFields.add(name);

      // Either build a field, or restore it from a cache.
      PresetField field;
      if (_fieldCache.containsKey(name)) {
        field = _fieldCache[name]!;
      } else {
        final options = await _getComboOptions(row);
        field = fieldFromJson(row, options: options);
        _fieldCache[name] = field;
      }

      // Skip fields that don't fit the location.
      if (field.locationSet != null && location != null) {
        final matches = locationMatcher(
            location.longitude, location.latitude, field.locationSet!);
        if (!matches) continue;
      }

      // query options if needed
      if (row['required'] == 1) {
        fields.add(field);
      } else if (row['universal'] == 1) {
        universalFields.add(field);
      } else {
        moreFields.add(field);
      }
    }
    sortFields(universalFields);
    return preset.withFields(fields, moreFields + universalFields);
  }

  Future<String?> _getFieldLabel(String fieldName, Locale locale) async {
    final langCTE = _localeCTE(locale);
    final sql = '''
    with $langCTE
    select t.label
    from field_tran t
    inner join langs on langs.lang = t.lang
    where t.field_name = ?
    order by lscore
    limit 1
    ''';
    final results = await _db!.rawQuery(sql, [fieldName]);
    return results.isEmpty || results.first['label'] == null
        ? null
        : results.first['label'] as String;
  }

  Future<Map<String, PresetField>> getFieldsByName(
      Iterable<String> names, Locale? locale) async {
    // Run fields by plugins.
    final pluginProvider = _ref.read(pluginPresetsProvider);
    final fromPlugins = {
      for (final name in names) name: pluginProvider.getField(name, locale)
    };
    fromPlugins.removeWhere((k, v) => v == null);

    // There's a chance all the fields were cached.
    final nonCachedNames = names.where((element) =>
        !_fieldCache.containsKey(element) && !fromPlugins.containsKey(element));
    if (nonCachedNames.isEmpty)
      return {
        for (final name in names) name: _fieldCache[name] ?? fromPlugins[name]!
      };

    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    final params = List.filled(names.length, '?').join(',');
    // TODO: fix row_number()
    final sql = '''
    with $langCTE
    select f.*, t.label as loc_label,
      t.placeholder as loc_placeholder,
      t.options as loc_options,
      lscore
    from fields f
    left join field_tran t on t.field_name = f.name
    inner join langs on langs.lang = t.lang
    where f.name in ($params)
    order by lscore
    ''';
    final results = await _db!.rawQuery(sql, names.toList());

    Map<String, PresetField> fields = {};
    final seenFields = <String>{};
    for (final row in results) {
      final name = row['name'] as String;
      if (seenFields.contains(name)) continue;
      seenFields.add(name);

      // Either build a field, or restore it from a cache.
      PresetField field;
      if (_fieldCache.containsKey(name)) {
        field = _fieldCache[name]!;
      } else {
        final options = await _getComboOptions(row);
        field = fieldFromJson(row, options: options);
        _fieldCache[name] = field;
      }

      fields[name] = field;
    }

    // Add back the plugin fields.
    fromPlugins.forEach((k, v) {
      if (v != null) fields[k] = v;
    });
    return fields;
  }

  static const kStandardPoiFields = [
    'name',
    'address',
    'level',
    'opening_hours',
    'wheelchair',
    'wifi',
    'payment',
    'phone',
    'website',
    'email',
    'operator',
    'addr_door',
    'description',
  ];

  Future<List<PresetField>> getStandardFields(Locale locale, bool isPOI) async {
    final List<String> stdFields =
        isPOI ? kStandardPoiFields : ['address', 'level'];
    final fields = await getFieldsByName(stdFields, locale);
    fields['wifi'] = WifiPresetField(
        label: await _getFieldLabel('internet_access', locale) ?? 'Wifi');
    fields['payment'] = PaymentPresetField(
        label: await _getFieldLabel('payment_multi', locale) ?? 'Accept cards');
    fields['addr_door'] = RoomPresetField(
        label:
            await _getFieldLabel('ref_room_number', locale) ?? 'Room Number');
    return stdFields.map((e) => fields[e]).whereType<PresetField>().toList();
  }

  Future<PresetField> getField(String fieldName, [Locale? locale]) async {
    final fields = await getFieldsByName([fieldName], locale);
    final result = fields[fieldName];
    if (result == null) throw ArgumentError('Missing field $fieldName');
    return result;
  }

  static final _kPreferredFields = [
    'website',
    'description',
    'fixme',
    'note',
    'start_date',
    'short_name',
    'loc_name',
    'alt_name',
    'reg_name',
    'official_name',
    'nat_name',
    'name',
    'wikimedia_commons',
    'panoramax',
    'mapillary',
    'image',
    'ele',
    'ref:linz:place_id',
  ].asMap().map((i, key) => MapEntry(key, i));

  void sortFields(List<PresetField> fields) {
    mergeSort(fields,
        compare: (a, b) => (_kPreferredFields[a.key] ?? 100)
            .compareTo(_kPreferredFields[b.key] ?? 100));
  }

  void clearFieldCache() {
    _fieldCache.clear();
  }

  Future<List<Map<String, dynamic>>> imageryQuery(String geohash) async {
    if (!ready) await _waitUntilReady();
    const sql = """
    with im_ids as (
      select imagery_id, (
        select count(*) from imagery_lookup ll
        where ll.imagery_id = l.imagery_id
      ) as imagery_size
      from imagery_lookup l
      where geohash = ?
      union all
      select imagery_id, 10000 as imagery_size from imagery
      where is_default = 1 or is_world = 1
    )
    select * from imagery
    inner join im_ids on im_ids.imagery_id = imagery.imagery_id
    order by is_default, is_world, is_best desc, imagery_size, imagery_id
    """;
    return await _db!.rawQuery(sql, [geohash]);
  }

  Future<Map<String, dynamic>?> singleImageryQuery(String id) async {
    if (!ready) await _waitUntilReady();
    const sql = "select * from imagery where id = ?";
    final rows = await _db!.rawQuery(sql, [id]);
    return rows.isEmpty ? null : rows.first;
  }
}
