#!/usr/bin/env python3
import sqlite3
import sys
import re


MAX_WIDTH = 78


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.stderr.write('Prints most common keys from taginfo\n')
        sys.stderr.write('Usage: {} <taginfo-db.db> [<count>]\n'.format(sys.argv[0]))
        sys.exit(1)

    taginfo = sqlite3.connect(sys.argv[1])
    cur = taginfo.cursor()
    cur.execute(
        "select key from keys order by count_all desc limit ?",
        (5000 if len(sys.argv) < 3 else int(sys.argv[2]),))
    s = '  '
    RE_KEY = re.compile(r'^[a-z][a-z0-9_:-]+$')
    print('const kCommonKeys = <String>{')
    for row in cur:
        k = row[0]
        if (k.startswith('source:') or k.startswith('tiger') or k.startswith('massgis') or
                k.startswith('KSJ2') or k.startswith('gns') or k.startswith('naptan') or
                '_1' in k or '_2' in k or not RE_KEY.match(k)):
            continue
        if len(s) + len(k) + 4 > MAX_WIDTH:
            print(s.rstrip())
            s = '  '
        s += f"'{k}', "
    if s:
        print(s.rstrip())
    print('};')
