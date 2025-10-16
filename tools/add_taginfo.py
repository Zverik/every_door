#!/usr/bin/env python3
import sqlite3
import sys
import os.path
from collections import defaultdict
from typing import Generator


KEEP_SEMICOLON = set(['voltage'])
MORE_VALUES = set(['payment:', 'craft'])
JOIN_CHAR = '\\'
POI_KEYS = [
    # See ../lib/helpers/tags/element_kind_std.dart
    'shop', 'craft', 'office', 'healthcare', 'club',
    'amenity', 'tourism',
    # Micromapping:
    'man_made', 'emergency', 'hazard', 'historic', 'leisure',
    'marker', 'natural', 'tourism',
]


def prepare_combos(cur, tcur):
    cur.execute("create table combos (key text primary key, options text)")

    # 1. Values for keys
    cur.execute(
        "select distinct key from fields where typ in ('combo', 'typeCombo', 'semiCombo')")
    keys = [row[0] for row in cur]
    # Querying for all keys at once: we've got around 240, and sqlite supports up to 999.
    tcur.execute(
        """select key, value, count_nodes + count_ways from tags
        where key in ({}) and count_all >= 30"""
        .format(','.join('?' * len(keys))), keys)
    values = defaultdict(dict)  # key: {value: count}
    for row in tcur:
        if row[0] in KEEP_SEMICOLON:
            values[row[0]][row[1]] = row[2]
        else:
            for v in row[1].split(';'):
                if ' ' not in v:
                    values[row[0]][v] = values[row[0]].get(v, 0) + row[2]

    to_store = []
    for k, v in values.items():
        items = [i[0] for i in sorted(v.items(), key=lambda i: i[1], reverse=True)]
        limit = 250 if k in MORE_VALUES else 50
        to_store.append((k, JOIN_CHAR.join(items[:limit])))
    cur.executemany("insert into combos (key, options) values (?, ?)", to_store)

    # 2. Key parts (e.g. currency:EUR)
    cur.execute(
        "select distinct key from fields where typ = 'multiCombo'")
    keys = [row[0] for row in cur if row[0][-1] == ':']
    for key in keys:
        # No way to do this in bulk
        limit = 250 if key in MORE_VALUES else 50
        tcur.execute(
            "select key from tags where key like ? and value = 'yes' and count_all >= 10 "
            f"order by count_all desc limit {limit}", (key + '%',))
        cur.execute(
            "insert into combos (key, options) values (?, ?)",
            (key, JOIN_CHAR.join(r[0][len(key):] for r in tcur)))
    cur.execute("create index combox_key_idx on combos (key)")


def prepare_tag_lists(cur, tcur, wcur):
    def build_rows(tags: set[str], usage: dict[str, int]) -> Generator[tuple]:
        # We duplicate rows for multi-word values.
        for kv in tags:
            count = usage[kv]
            k, v = kv.split('=', 1)
            words = v.split('_')
            for i, word in enumerate(words):
                yield (word.lower(), k, v, count if i == 0 else count // 2)

    # Query all tags for POI keys with enough usage.
    ph = ','.join('?' * len(POI_KEYS))
    tcur.execute(
        "select key, value, count_all from tags "
        f"where key in ({ph}) and count_nodes >= 100 "
        "and value not in ('yes', 'no', 'fixme')",
        POI_KEYS)
    # Under 1000 results, no point in memory management.
    usage = {f'{row[0]}={row[1]}': row[2] for row in tcur}
    tags = set(usage.keys())

    # We can skip the wikipedia step.
    if wcur:
        # Query pages and leave in tags only what we have found.
        wcur.execute(
            f"select key, value from wikipages_tags where key in ({ph}) "
            "and approval_status not in ('deprecated', 'imported', 'obsolete')",
            POI_KEYS)
        # Again, around 1000 results as of 2025.
        wtags = set(f'{row[0]}={row[1]}' for row in wcur)
        tags = tags & wtags

    # Now fill the table.
    cur.execute("create table taglist (term text, key text, value text, usage integer)")
    cur.executemany(
        "insert into taglist (term, key, value, usage) values (?, ?, ?, ?)",
        build_rows(tags, usage))
    cur.execute(
        "delete from taglist where exists "
        "(select 1 from preset_tags p where "
        "p.key = taglist.key and p.value = taglist.value)")

    cur.execute("create index taglist_term_idx on taglist (term)")


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Prefills combobox values and a tag list from taginfo')
        print('Usage: {} <presets.db> <path_to_taginfo_db>'.format(sys.argv[0]))
        sys.exit(1)

    conn = sqlite3.connect(sys.argv[1])
    cur = conn.cursor()
    taginfo = sqlite3.connect(os.path.join(sys.argv[2], 'taginfo-db.db'))
    tcur = taginfo.cursor()

    wiki_path = os.path.join(sys.argv[2], 'taginfo-wiki.db')
    tagwiki: sqlite3.Connection | None = None
    if os.path.exists(wiki_path):
        tagwiki = sqlite3.connect(wiki_path)
        wcur: sqlite3.Cursor | None = tagwiki.cursor()
    else:
        wcur = None

    prepare_combos(cur, tcur)
    prepare_tag_lists(cur, tcur, wcur)

    if tagwiki:
        tagwiki.close()
    taginfo.close()
    conn.commit()
    cur.execute('vacuum')
    conn.commit()
    conn.close()
