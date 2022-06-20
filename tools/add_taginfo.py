#!/usr/bin/env python3
import sqlite3
import sys
from collections import defaultdict


KEEP_SEMICOLON = set(['voltage', 'flashing_lights'])
MORE_VALUES = set(['payment:', 'craft'])
JOIN_CHAR = '\\'


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Prefills combobox values from taginfo')
        print('Usage: {} <presets.db> <taginfo-db.db>'.format(sys.argv[0]))
        sys.exit(1)

    conn = sqlite3.connect(sys.argv[1])
    cur = conn.cursor()
    taginfo = sqlite3.connect(sys.argv[2])
    tcur = taginfo.cursor()
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

    taginfo.close()
    conn.commit()
    conn.close()
