#!/usr/bin/env python3
"""Prepares the presets.db file from presets and imagery.

The presets.db database is essential for Every Door, and is built
from four parts: fields, presets, name suggestion index, and imagery.
Note that there are no references between same-type records in the database.
These need to be expanded on parsing. Also, since ED deals only with points
and closed areas, presents relating to linear features are skipped.

Note that imagery is added in a separate script, ``add_imagery.py``.
And there is also taginfo data for combo options, see ``add_taginfo.py``.
"""

import json
import os
import re
import requests
import sqlite3
import sys
import unicodedata
from typing import Optional, Final, NewType, Iterator, Any


# Copied from ../lib/helpers/good_tags.dart
MAIN_KEYS: Final[list[str]] = [
    'amenity', 'shop', 'craft', 'tourism', 'historic', 'club',
    'highway', 'railway',
    'office', 'healthcare', 'leisure', 'natural',
    'emergency', 'waterway', 'man_made', 'power', 'aeroway', 'aerialway',
    'marker', 'public_transport', 'traffic_sign', 'hazard', 'telecom',
    'landuse', 'military', 'barrier', 'building', 'entrance', 'boundary',
    'advertising', 'playground', 'traffic_calming', 'attraction',
]

# A global list to keep track of presets with "searchable: false" flags.
non_searchable_presets: list[str] = []

# Just a dictionary of preset -> referenced preset.
ReferenceStorage = NewType('ReferenceStorage', dict[str, Any])


class ReferenceStorageImpl:
    """
    Global map of preset and field references. Stored on reading fields/presets,
    used in reading translations to duplicate them for those.
    """

    def __init__(self):
        self.presets_name: ReferenceStorage = {}
        self.fields_label: ReferenceStorage = {}
        self.fields_placeholder: ReferenceStorage = {}
        self.fields_strings: ReferenceStorage = {}

    @staticmethod
    def _get_reference(value: Optional[str]) -> Optional[str]:
        if value and len(value) >= 3 and value[0] == '{':
            return value[1:-1].strip()
        return None

    def get(self, which: ReferenceStorage, name: str, data: dict[str, dict],
            field: str) -> Optional[str]:
        if name not in which:
            return data[name].get(field)
        return data.get(which[name], {}).get(field) or data[name].get(field)

    def add(self, which: ReferenceStorage, value: Optional[str], name: str) -> None:
        """
        We store the field/preset name in a list for the referenced field/preset.
        When we read translations for *that* field/preset, we also add table
        entries for this one.
        """
        rname = self._get_reference(value)
        if rname:
            which[name] = rname

    @staticmethod
    def fetch(row: dict, field: str, data: dict[str, dict]) -> Optional[str]:
        """
        Some values may reference other fields/presets instead of just stating a string.
        That implies that translations are also referenced. For translations, we store
        them in the ``add`` method, while here we just fetch the referenced value
        from the same file, different field/preset.
        """
        value = row.get(field)
        rname = ReferenceStorageImpl._get_reference(value)
        if rname and rname in data:
            return data[rname].get(field)
        return value


references = ReferenceStorageImpl()


def open_or_download(git_path: Optional[str], filename: str, from_nsi: bool = False) -> dict:
    """
    Either opens the built json file from given git path
    (adding repo name automatically), or downloads the json
    from git. Returns a parsed dict, since all json files
    we use are dicts and not arrays.
    """
    if git_path:
        fullname = os.path.join(git_path, filename)
        if not os.path.exists(fullname):
            if from_nsi:
                git_name = 'name-suggestion-index'
            else:
                git_name = 'id-tagging-schema'
            fullname = os.path.join(git_path, git_name, 'dist', filename)
            if not os.path.exists(fullname):
                print(f'Cannot find {filename} under {git_path}')
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


def normalize(s: Optional[str]) -> Optional[str]:
    """Normalizes unicode and lowers case for searching."""
    if not s:
        return s
    return u"".join([c for c in unicodedata.normalize('NFKD', s.lower().strip())
                     if not unicodedata.combining(c)])


def import_fields(cur, path: Optional[str]):
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
        prerequisite text,
        locations text
        )""")

    def build_fields(data: dict[str, dict]) -> Iterator[tuple]:
        bad_types = set([
            'access', 'cycleway', 'roadspeed',
            'wikidata', 'wikipedia', 'restrictions', 'structureRadio',
            'networkCombo', 'onewayCheck', 'manyCombo', 'directionalCombo',
        ])
        for name, row in data.items():
            # Some field types we just do not edit, or have different dedicated editing fields.
            if 'key' not in row or row['type'] in bad_types:
                continue
            # That rules out natural features (e.g. forests), but not buildings.
            if 'geometry' in row and 'point' not in row['geometry']:
                continue
            # check_date is managed manually in the app.
            if name == 'check_date':
                continue

            # The referenced label is often empty, but we need to store the reference
            # for translations. Same for the placeholder.
            flabel = references.fetch(row, 'label', data)
            fplace = references.fetch(row, 'placeholder', data)
            references.add(references.fields_label, row.get('label'), name)
            references.add(references.fields_placeholder, row.get('placeholder'), name)
            # Note that label reference does not imply strings reference.
            references.add(references.fields_strings, row.get('stringsCrossReference'), name)

            yield (
                name,
                row['key'],
                row['type'],
                flabel,
                fplace,
                None if 'options' not in row else json.dumps(row['options']),
                0 if row.get('customValues') is False else 1,
                1 if row.get('universal') else 0,
                1 if row.get('snake_case') else 0,
                row.get('minValue'),
                None if 'prerequisiteTag' not in row else json.dumps(row['prerequisiteTag']),
                None if 'locationSet' not in row else json.dumps(row['locationSet']),
            )

    cur.executemany(
        "insert into fields (name, key, typ, label, placeholder, options, custom_values, "
        "universal, snake_case, min_value, prerequisite, locations) "
        "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", build_fields(data))
    cur.execute("create index fields_uni_idx on fields (universal)")


def import_presets(cur, path: Optional[str]):
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

    def is_point_geometry(row: dict) -> bool:
        return ('geometry' in row and
                ('point' in row['geometry'] or 'vertex' in row['geometry']))

    def skip_preset(name: str, row: dict) -> bool:
        # Skip templates.
        if name[0] == '@':
            return True
        # There are super-generic presets like "relation" with no tags.
        if not row['tags']:
            return True
        # Override geometry check for buildings
        if name.startswith('building'):
            return False
        # Note that we keep presets both for points and vertices (in a line).
        if not is_point_geometry(row):
            return True
        return False

    def build_presets(data: dict[str, dict]) -> Iterator[tuple]:
        for name, row in data.items():
            if skip_preset(name, row):
                continue

            # We don't allow creating entrances from the POI mode, but allow for vacant shops.
            if not row.get('searchable', True) or name.startswith('entrance'):
                if name != 'shop/vacant':
                    non_searchable_presets.append(name)
            # Just in case, if we allowed an area preset, at least forbid searching.
            if not is_point_geometry(row):
                non_searchable_presets.append(name)

            references.add(references.presets_name, row.get('name'), name)
            tags = json.dumps(row['tags'])

            # This is an incredibly complicated formula for sorting presets.
            # Keys earlier in MAIN_KEYS go to the top, presets with less
            # parts in the name also go higher. But ``matchScore`` from the
            # json file is the king.
            name_parts = name.split('/')
            num_steps = len(name_parts)
            try:
                main_index = 50 - MAIN_KEYS.index(name.split('/')[0])
            except ValueError:
                main_index = 90
            match_score = (
                int(row.get('matchScore', 1.0) * 100) * 1000 + num_steps * 100 + main_index)

            yield (
                name,
                1 if 'area' in row['geometry'] else 0,  # not used as of Every Door 3.1.
                tags if 'addTags' not in row else json.dumps(row['addTags']),
                tags if 'removeTags' not in row else json.dumps(row['removeTags']),
                row.get('icon'),
                match_score,
                None if 'locationSet' not in row else json.dumps(row['locationSet']),
            )

    cur.executemany(
        "insert into presets (name, can_area, add_tags, remove_tags, "
        "icon, match_score, locations) "
        "values (?, ?, ?, ?, ?, ?, ?)""", build_presets(data))

    def build_field_list(data: dict[str, dict], name: str, column: str) -> list[str]:
        if name not in data:
            return []
        fields = data[name].get(column, [])
        while not fields and '/' in name:
            # Move up the hierarchy
            name = name.rsplit('/', 1)[0]
            if name in data:
                fields = data[name].get(column, [])

        i = 0
        while i < len(fields):
            if fields[i][0] == '{':
                # Replace e.g. "{building}" with fields from the bulding preset.
                # Note that there can be multiple references, so we continue
                # processing the items.
                # Enclosed references are resolved with recursion.
                ref = fields[i][1:-1]
                new_fields = build_field_list(data, ref, column)
                fields = fields[:i] + new_fields + fields[i + 1:]
                i += len(new_fields)
            else:
                i += 1
        return fields

    def build_fields(data: dict[str, dict]) -> Iterator[tuple]:
        for name in data:
            if skip_preset(name, data[name]):
                continue
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
        """Here we just build initial terms from the preset name."""
        for name, row in data.items():
            if skip_preset(name, row):
                continue
            for term in name.replace('_', '/').split('/')[1:]:
                if term:
                    yield 'tag', term, name, 5
            # Formerly we also added tag values, which seemed logical
            # (e.g. "fuel" for "amenity=fuel"). But that led to additional like 2 MB of data
            # and was of less use, since translations are mostly better for this.

    cur.execute(
        "create table preset_terms (lang text, term text, preset_name text, score integer);")
    cur.executemany(
        "insert into preset_terms (lang, term, preset_name, score) values (?, ?, ?, ?)",
        build_terms(data))
    # We build index later, after parsing translations

    def build_tags(data):
        for name, row in data.items():
            if skip_preset(name, row):
                continue
            for k, v in row.get('tags', {}).items():
                yield k, None if v == '*' else v, name

    cur.execute("create table preset_tags (key text, value text, preset_name text);")
    cur.executemany("insert into preset_tags (key, value, preset_name) values (?, ?, ?)",
                    build_tags(data))
    cur.execute("create index preset_tags_idx on preset_tags (key, value);")


def remove_generic_terms(cur):
    """
    Remove terms that address presets we do not want to set for new objects. That includes:

    - Presets with ``searchable: false``.
    - Generic presets like ``shop=*``.
    - Anything related to ``amenity=parking``.
    """
    global non_searchable_presets
    preset_names = set(non_searchable_presets)

    cur.execute("select name, add_tags from presets where add_tags like '%\"*\"%'")
    for row in cur:
        tags = json.loads(row[1])
        if not tags or all(v == '*' for v in tags.values()):
            preset_names.add(row[0])

    cur.execute("select name, add_tags from presets where add_tags like '%\"parking\"%'")
    for row in cur:
        tags = json.loads(row[1])
        if tags and tags.get('amenity') == 'parking':
            preset_names.add(row[0])

    nq = ','.join('?' for n in preset_names)
    cur.execute(f"delete from preset_terms where preset_name in ({nq})", list(preset_names))


def import_translations(cur, path: Optional[str]):
    """
    This just reads all translation field for fields and presets (stored in the same file),
    and prepares two tables from them + preset search terms.
    What's tricky is also adding referenced translations.
    """
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

        def build_fields(lang: str, data: dict[str, dict]) -> Iterator[tuple]:
            for name in data:
                label = references.get(references.fields_label, name, data, 'label')
                placeholder = references.get(
                    references.fields_placeholder, name, data, 'placeholder')
                options = references.get(references.fields_strings, name, data, 'options') or {}
                for k in list(options):
                    if isinstance(options[k], dict):
                        if 'title' not in options[k]:
                            del options[k]
                        else:
                            options[k] = options[k]['title']
                if not label and not placeholder and not options:
                    continue
                yield (
                    lang, name, label, placeholder,
                    None if not options else json.dumps(options, ensure_ascii=False),
                )

        def build_presets(lang: str, data: dict[str, dict]) -> Iterator[tuple]:
            for name in data:
                pname = references.get(references.presets_name, name, data, 'name')
                if pname:
                    yield (lang, name, pname)

        fields = data[lang]['presets']['fields']
        cur.executemany(
            "insert into field_tran (lang, field_name, label, placeholder, options) "
            "values (?, ?, ?, ?, ?)", build_fields(lang, fields))
        presets = data[lang]['presets']['presets']
        cur.executemany(
            "insert into preset_tran (lang, preset_name, name) "
            "values (?, ?, ?)", build_presets(lang, presets))

        def build_terms(lang: str, data: dict[str, dict]) -> Iterator[tuple]:
            for name in data:
                name_src = references.get(references.presets_name, name, data, 'name')
                terms_src = references.get(references.presets_name, name, data, 'terms')
                aliases = data[name].get('aliases')

                terms = [normalize(s) for s in re.split(r'\W+', terms_src or '') if s]
                nameterms = [normalize(s) for s in re.split(r'\W+', name_src or '') if s]
                aliasterms = [normalize(s) for s in re.split(r'\W+', aliases or '') if s]

                # First words have higher priority
                tfirst = None if not terms else terms[0]
                ntfirst = None if not nameterms else nameterms[0]

                # Convert to sets to deduplicate
                nameterms = set(nameterms)
                terms = (set(terms) | set(aliasterms)) - nameterms
                for term in terms:
                    if term:
                        yield lang, term, name, 2 if term == tfirst else 1
                for term in nameterms:
                    if term:
                        yield lang, term, name, 4 if term == ntfirst else 3

        cur.executemany(
            "insert into preset_terms (lang, term, preset_name, score) values (?, ?, ?, ?)",
            build_terms(lang, presets))

    remove_generic_terms(cur)

    cur.execute("create index field_tran_idx on field_tran (field_name)")
    cur.execute("create index preset_tran_idx on preset_tran (preset_name)")
    cur.execute("create index preset_terms_idx on preset_terms (term collate nocase)")


def import_nsi(cur, path: Optional[str]):
    # True means ``from_nsi``, so it's a different github repo.
    data = open_or_download(path, 'nsi.min.json', True)
    cur.execute("""create table nsi (
        id text primary key,
        name text,
        locations text,
        tags text,
        preserve_name integer
        )""")

    def build_nsi(data: dict[str, dict]) -> Iterator[tuple]:
        for typ, vals in data.items():
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
                    "values (?, ?, ?, ?, ?)", build_nsi(data['nsi']))

    cur.execute("""create table nsi_terms (
        term text,
        nsi_id text
        )""")

    def build_terms(data: dict[str, dict]) -> Iterator[tuple]:
        term_keys = set(['name', 'operator', 'brand', 'network'])
        for typ, vals in data.items():
            for item in vals['items']:
                terms = set([normalize(item['displayName'])])
                for k, v in item['tags'].items():
                    if (k in term_keys or (':' in k and 'wiki' not in k and
                                           k[:k.index(':')] in term_keys)):
                        terms.add(normalize(v))
                for term in terms:
                    yield (term, item['id'])

    cur.executemany("insert into nsi_terms (term, nsi_id) values (?, ?)", build_terms(data['nsi']))
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
