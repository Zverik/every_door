#!/usr/bin/env python3
import json
import os
import re
import requests
import sqlite3
import sys
import unicodedata


# Copied from ../lib/helpers/good_tags.dart
MAIN_KEYS = [
    'amenity', 'shop', 'craft', 'tourism', 'historic', 'club',
    'highway', 'railway',
    'office', 'healthcare', 'leisure', 'natural',
    'emergency', 'waterway', 'man_made', 'power', 'aeroway', 'aerialway',
    'landuse', 'military', 'barrier', 'building', 'entrance', 'boundary',
    'advertising', 'playground', 'traffic_calming',
]


def open_or_download(path, filename, from_nsi=False):
    if path:
        fullname = os.path.join(path, filename)
        if not os.path.exists(fullname):
            if from_nsi:
                git_name = 'name-suggestion-index'
            else:
                git_name = 'id-tagging-schema'
            fullname = os.path.join(path, git_name, 'dist', filename)
            if not os.path.exists(fullname):
                print(f'Cannot find {filename} under {path}')
                sys.exit(2)
        with open(fullname, 'r') as f:
            return json.load(f)
    else:
        # Download file
        RAW_GITHUB = 'https://raw.githubusercontent.com/'
        if from_nsi:
            BASE_URL = RAW_GITHUB + 'osmlab/name-suggestion-index/main/dist/'
        else:
            BASE_URL = RAW_GITHUB + 'openstreetmap/id-tagging-schema/main/dist/'
        resp = requests.get(BASE_URL + filename)
        if resp.status_code != 200:
            print(f'Error {resp.status_code} while downloading {filename}')
            sys.exit(2)
        return resp.json()


def normalize(s):
    if not s:
        return s
    return u"".join([c for c in unicodedata.normalize('NFKD', s.lower().strip())
                     if not unicodedata.combining(c)])


def import_fields(cur, path):
    data = open_or_download(path, 'fields.min.json', False)
    cur.execute("""create table fields (
        name text primary key,
        key text,
        typ text,
        label text,
        placeholder text,
        options text,
        custom_values integer default 1,
        universal integer default 0,
        snake_case integer default 1,
        min_value integer,
        prerequisite text
        )""")

    def build_fields(data):
        bad_types = set([
            'access', 'address', 'cycleway', 'roadspeed', 'roadheight',
            'wikidata', 'wikipedia', 'restrictions', 'structureRadio',
            'networkCombo', 'onewayCheck', 'manyCombo',
        ])
        for name, row in data.items():
            if 'key' not in row or row['type'] in bad_types:
                continue
            if 'geometry' in row and 'point' not in row['geometry']:
                continue
            yield (
                name,
                row['key'],
                row['type'],
                row.get('label'),
                row.get('placeholder'),
                None if 'options' not in row else json.dumps(row['options']),
                0 if row.get('customValues') is False else 1,
                1 if row.get('universal') else 0,
                1 if row.get('snake_case') else 0,
                row.get('minValue'),
                None if 'prerequisiteTag' not in row else json.dumps(row['prerequisiteTag']),
            )

    cur.executemany(
        "insert into fields (name, key, typ, label, placeholder, options, custom_values, "
        "universal, snake_case, min_value, prerequisite) "
        "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", build_fields(data))
    cur.execute("create index fields_uni_idx on fields (universal)")


def import_presets(cur, path):
    data = open_or_download(path, 'presets.min.json', False)
    cur.execute("""create table presets (
        name text primary key,
        can_area integer,
        add_tags text,
        remove_tags text,
        icon text,
        match_score integer,
        locations text
        )""")

    def build_presets(data):
        for name, row in data.items():
            if ('geometry' not in row or
                    ('point' not in row['geometry'] and 'vertex' not in row['geometry'])):
                continue
            if not row['tags']:
                continue
            tags = json.dumps(row['tags'])
            name_parts = name.split('/')
            num_steps = len(name_parts)
            try:
                main_index = 50 - MAIN_KEYS.index(name.split('/')[0])
            except ValueError:
                main_index = 90
            yield (
                name,
                1 if 'area' in row['geometry'] else 1,
                tags if 'addTags' not in row else json.dumps(row['addTags']),
                tags if 'removeTags' not in row else json.dumps(row['removeTags']),
                row.get('icon'),
                int(row.get('matchScore', 1.0) * 100) * 1000 + num_steps * 100 + main_index,
                None if 'locationSet' not in row else json.dumps(row['locationSet']),
            )

    cur.executemany(
        "insert into presets (name, can_area, add_tags, remove_tags, "
        "icon, match_score, locations) "
        "values (?, ?, ?, ?, ?, ?, ?)""", build_presets(data))

    def build_field_list(data, name, column):
        if name not in data:
            return []
        fields = data[name].get(column, [])
        while not fields and '/' in name:
            # Move up the hierarchy
            name = name.rsplit('/', 1)[0]
            if name in data:
                fields = data[name].get(column, [])

        for i in range(len(fields)):
            if fields[i][0] == '{':
                # Replace e.g. "{building}" with fields from the bulding preset
                ref = fields[i][1:-1]
                fields = fields[:i] + build_field_list(data, ref, column) + fields[i + 1:]
                break
        return fields

    def build_fields(data):
        for name in data:
            for i, field in enumerate(build_field_list(data, name, 'fields')):
                yield name, field, 1, i
            for i, field in enumerate(build_field_list(data, name, 'moreFields')):
                yield name, field, 0, i

    cur.execute(
        "create table preset_fields (preset_name text, field text, required integer, pos integer)")
    cur.executemany(
        "insert into preset_fields (preset_name, field, required, pos) values (?, ?, ?, ?)",
        build_fields(data))
    cur.execute("create index preset_fields_idx on preset_fields (preset_name)")

    def build_terms(data):
        for name, row in data.items():
            for term in name.replace('_', '/').split('/')[1:]:
                if term:
                    yield 'tag', term, name, 5
            # for k, v in row.get('tags', {}).items():
            #     if v is not None and len(v) > 2 and v != 'yes':
            #         yield 'tag', v, name, 6

    cur.execute(
        "create table preset_terms (lang text, term text, preset_name text, score integer);")
    cur.executemany(
        "insert into preset_terms (lang, term, preset_name, score) values (?, ?, ?, ?)",
        build_terms(data))
    # We build index later, after parsing translations

    def build_tags(data):
        for name, row in data.items():
            for k, v in row.get('tags', {}).items():
                yield k, None if v == '*' else v, name

    cur.execute("create table preset_tags (key text, value text, preset_name text);")
    cur.executemany("insert into preset_tags (key, value, preset_name) values (?, ?, ?)",
                    build_tags(data))
    cur.execute("create index preset_tags_idx on preset_tags (key, value);")


def import_translations(cur, path):
    cur.execute("""create table field_tran (
        lang text,
        field_name text,
        label text,
        placeholder text,
        options text
        )""")
    cur.execute("""create table preset_tran (
        lang text,
        preset_name text,
        name text
        )""")
    index = open_or_download(path, 'translations/index.min.json', False)
    for lang, langv in index.items():
        if langv['pct'] < 0.04:
            continue
        data = open_or_download(path, f'translations/{lang}.min.json', False)

        def build_fields(lang, data):
            for name, row in data.items():
                options = row.get('options', {})
                for k in options:
                    if isinstance(k, dict):
                        options[k] = options[k]['title']
                yield (
                    lang, name,
                    row.get('label'),
                    row.get('placeholder'),
                    None if not options else json.dumps(options, ensure_ascii=False),
                )

        cur.executemany(
            "insert into field_tran (lang, field_name, label, placeholder, options) "
            "values (?, ?, ?, ?, ?)", build_fields(lang, data[lang]['presets']['fields']))
        presets = data[lang]['presets']['presets']
        cur.executemany("insert into preset_tran (lang, preset_name, name) values (?, ?, ?)",
                        ((lang, name, r['name']) for name, r in presets.items() if 'name' in r))

        def build_terms(lang, data):
            for name, row in data.items():
                terms = [normalize(s) for s in re.split(r'\W+', row.get('terms', '')) if s]
                nameterms = [normalize(s) for s in re.split(r'\W+', row.get('name', '')) if s]
                # First words have higher priority
                tfirst = None if not terms else terms[0]
                ntfirst = None if not nameterms else nameterms[0]
                # Convert to sets to deduplicate
                nameterms = set(nameterms)
                terms = set(terms) - nameterms
                for term in terms:
                    if term:
                        yield lang, term, name, 1 if term == tfirst else 2
                for term in nameterms:
                    if term:
                        yield lang, term, name, 3 if term == ntfirst else 4

        cur.executemany(
            "insert into preset_terms (lang, term, preset_name, score) values (?, ?, ?, ?)",
            build_terms(lang, presets))

    # Clean up indices - commented out since it removes e.g. restaurants.
    # cur.execute(
    #     "with t as (select lang, term from preset_terms group by 1, 2 having count(*) > 20) "
    #     "delete from preset_terms as p "
    #     "where exists (select * from t where p.lang = t.lang and p.term = t.term) "
    #     "or (lang not in ('ja', 'zh-CN', 'zh-TW', 'zh-HK') and length(term) <= 2)"
    # )

    cur.execute("create index field_tran_idx on field_tran (field_name)")
    cur.execute("create index preset_tran_idx on preset_tran (preset_name)")
    cur.execute("create index preset_terms_idx on preset_terms (term collate nocase)")


def import_nsi(cur, path):
    data = open_or_download(path, 'nsi.min.json', True)
    cur.execute("""create table nsi (
        id text primary key,
        name text,
        locations text,
        tags text,
        preserve_name integer
        )""")

    def build_nsi(data):
        for typ, vals in data['nsi'].items():
            preserve_value = vals['properties'].get('preserveTags', [])
            preserve = '^name' in preserve_value
            for item in vals['items']:
                preserve_value = item.get('preserveTags', [])
                yield (
                    item['id'],
                    item['displayName'],
                    None if 'locationSet' not in item else json.dumps(item['locationSet']),
                    json.dumps(item['tags'], ensure_ascii=False),
                    1 if preserve or '^name' in preserve_value else 0,
                )

    cur.executemany("insert into nsi (id, name, locations, tags, preserve_name) "
                    "values (?, ?, ?, ?, ?)", build_nsi(data))

    cur.execute("""create table nsi_terms (
        term text,
        nsi_id text
        )""")

    def build_terms(data):
        term_keys = set(['name', 'operator', 'brand', 'network'])
        for typ, vals in data['nsi'].items():
            for item in vals['items']:
                terms = set([normalize(item['displayName'])])
                for k, v in item['tags'].items():
                    if (k in term_keys or (':' in k and 'wiki' not in k and
                                           k[:k.index(':')] in term_keys)):
                        terms.add(normalize(v))
                for term in terms:
                    yield (term, item['id'])

    cur.executemany("insert into nsi_terms (term, nsi_id) values (?, ?)", build_terms(data))
    cur.execute("create index nsi_terms_idx on nsi_terms (term collate nocase);")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Converts JSON from various iD projects to an Every Door database')
        print('Usage: {} <output.db> [<path_to_git>]'.format(sys.argv[0]))
        print('Please clone id-tagging-schema and name-suggestion-index to the git path.')
        sys.exit(1)

    if os.path.exists(sys.argv[1]):
        print('Please specify a new file for the database.')
        sys.exit(3)

    git_path = None if len(sys.argv) <= 2 else sys.argv[2]

    db = sqlite3.connect(sys.argv[1])
    cur = db.cursor()
    import_fields(cur, git_path)
    import_presets(cur, git_path)
    import_translations(cur, git_path)
    import_nsi(cur, git_path)
    db.commit()
    cur.execute('vacuum')
    db.commit()
    db.close()
