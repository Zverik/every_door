import 'package:country_coder/country_coder.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/fields/address.dart';
import 'package:every_door/fields/combo.dart';
import 'package:every_door/fields/payment.dart';
import 'package:every_door/fields/room.dart';
import 'package:every_door/fields/text.dart';
import 'package:every_door/fields/wifi.dart';
import 'package:every_door/helpers/normalizer.dart';
import 'package:every_door/models/field.dart';
import 'package:every_door/helpers/nsi_features.dart';
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

final presetProvider = Provider((_) => PresetProvider());

class PresetProvider {
  static const kDbVersion = "dbVersion";
  static final _logger = Logger('PresetProvider');

  Database? _db;
  late final LocationMatcher locationMatcher;
  bool ready = false;

  PresetProvider() {
    initMatcher();
    initDatabase();
  }

  initMatcher() {
    final data = JsonDecoder().convert(nsiFeaturesRaw);
    locationMatcher = LocationMatcher({
      'features': data['features'].whereType<Map<String, dynamic>>().toList()
    });
  }

  initDatabase() async {
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

  Future<List<Preset>> _getNSIAutocomplete(String query) async {
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
    final results = await _db!.rawQuery(sql, [query + '%']);
    return results.map((e) => Preset.fromNSIJson(e)).toList();
  }

  List<Preset> _filterByLocation(List<Preset> presets, LatLng location) {
    return presets
        .where((p) =>
            p.locationSet == null ||
            locationMatcher(
                location.longitude, location.latitude, p.locationSet!))
        .toList();
  }

  Future<List<Preset>> fillNSIPresetNames(List<Preset> suggested,
      {Locale? locale}) async {
    final List<Preset> results = [];
    for (final nsi in suggested) {
      if (nsi.fromNSI) {
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
      bool includeNSI = true,
      Locale? locale,
      LatLng? location}) async {
    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    final isAreaClause = isArea ? 'where can_area = 1' : '';
    final sql = '''
    with $langCTE
    , found as (
      select preset_name, max(score) as score
      from preset_terms
      where term like ?
      and lang in (select lang from langs)
      group by preset_name
      order by score desc, min(length(term))
    )
    select p.*, t.name as loc_name, lscore
    from presets p
    inner join found on found.preset_name = p.name
    left join preset_tran t on t.preset_name = p.name
    inner join langs on langs.lang = t.lang
    $isAreaClause
    order by score desc, lscore;
    ''';
    final results = await _db!.rawQuery(sql, [normalizeString(query) + '%']);
    final presets = <Preset>[];
    if (includeNSI) {
      List<Preset> nsiResults = await _getNSIAutocomplete(normalizeString(query));
      if (location != null) {
        nsiResults = _filterByLocation(nsiResults, location);
      }
      if (nsiResults.length > kMaxNSIPresets) {
        nsiResults.removeRange(kMaxNSIPresets, nsiResults.length);
      }
      presets.addAll(nsiResults);
    }

    final seenPresets = <String>[];
    for (final row in results) {
      if (seenPresets.contains(row['name'])) continue;
      seenPresets.add(row['name'] as String);
      presets.add(Preset.fromJson(row));
      if (presets.length >= kMaxShownPresets) break;
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
    if (results.isEmpty) {
      return Preset.defaultPreset;
    }
    return Preset.fromJson(results.first);
  }

  Future<List<Preset>> getPresetsById(List<String> ids,
      {Locale? locale}) async {
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
    final presets = <String, Preset>{};
    final seenFields = <String>{};
    for (final row in results) {
      final String name = row['name'] as String;
      if (seenFields.contains(name)) continue;
      seenFields.add(name);
      presets[name] = Preset.fromJson(row);
    }
    if (presets.length != ids.length) {
      _logger.warning(
          'getPresetsById fail: for ${ids.length} ids got ${results.length} results.');
    }
    return ids.map((e) => presets[e]).whereType<Preset>().toList();
  }

  Future<List<ComboOption>> _getComboOptions(Map<String, dynamic> field) async {
    final String typ = (field['typ']) as String;
    bool needed = typ.endsWith("ombo") || typ == 'radio';
    if (!needed) return const [];

    final loc = field['loc_options'] != null
        ? jsonDecode(field['loc_options'])
        : <String, String>{};
    final List<String> options = [];
    if (field['options'] != null) {
      options.addAll((jsonDecode(field['options']) as List).cast<String>());
    }

    // Get options from taginfo
    final results =
        await _db!.query('combos', where: 'key = ?', whereArgs: [field['key']]);
    if (results.isNotEmpty) {
      final existing = Set.of(options);
      options.addAll((results.first['options'] as String)
          .split('\\')
          .where((v) => !existing.contains(v)));
    }
    return options.map((e) => ComboOption(e, loc[e])).toList();
  }

  Future<Preset> getFields(Preset preset, {Locale? locale}) async {
    if (preset.isFixme)
      return preset.withFields(
          [TextPresetField(key: 'fixme:type', label: 'Fixme type')], []);

    if (!ready) await _waitUntilReady();
    final langCTE = _localeCTE(locale);
    // TODO: fix row_number()
    final sql = '''
    with $langCTE
    , pfields as (
      select field, required, pos
      from preset_fields where preset_name = ?
      union all
      select name as field, 0, 100
      from fields where universal = 1
    )
    select f.*, t.label as loc_label,
      t.placeholder as loc_placeholder,
      t.options as loc_options,
      pf.pos, pf.required,
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
    final seenFields = <String>{};
    for (final row in results) {
      if (seenFields.contains(row['name'])) continue;
      if (row['name'] == 'opening_hours/covid19') continue;
      seenFields.add(row['name'] as String);
      final options = await _getComboOptions(row);
      final field = fieldFromJson(row, options: options);
      // query options if needed
      if (row['required'] == 1) {
        fields.add(field);
      } else {
        moreFields.add(field);
      }
    }
    return preset.withFields(fields, moreFields);
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
    return results.isEmpty ? null : results.first['label'] as String;
  }

  Future<Map<String, PresetField>> _getFields(
      List<String> names, Locale? locale) async {
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
    final results = await _db!.rawQuery(sql, names);
    Map<String, PresetField> fields = {};
    final seenFields = <String>{};
    for (final row in results) {
      if (seenFields.contains(row['name'])) continue;
      seenFields.add(row['name'] as String);
      final options = await _getComboOptions(row);
      final field = fieldFromJson(row, options: options);
      fields[row['name'] as String] = field;
    }
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
    final fields = await _getFields(stdFields, locale);
    fields['address'] = AddressField(
        label: await _getFieldLabel('address', locale) ?? 'Address');
    fields['wifi'] = WifiPresetField(
        label: await _getFieldLabel('internet_access', locale) ?? 'Wifi');
    fields['payment'] = PaymentPresetField(
        label: await _getFieldLabel('payment_multi', locale) ?? 'Accept cards');
    fields['addr_door'] = RoomPresetField();
    return stdFields.map((e) => fields[e]).whereType<PresetField>().toList();
  }

  Future<PresetField> getField(String fieldName, [Locale? locale]) async {
    final fields = await _getFields([fieldName], locale);
    final result = fields[fieldName];
    if (result == null) throw ArgumentError('Missing field $fieldName');
    return result;
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
