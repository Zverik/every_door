#!/usr/bin/env python3
import csv
import sqlite3
import re
import sys


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print('Takes a CSV extracted from Simple English Wikipedia '
              'with columns lang_name, native_name, iso_code and '
              'prepares a file for Every Door.')
        print('Usage: {} <input.csv> <taginfo-db.db> <lang_data.dart>'.format(sys.argv[0]))
        sys.exit(1)

    result = []
    taginfo = sqlite3.connect(sys.argv[2])
    tcur = taginfo.cursor()
    with open(sys.argv[1], 'r') as f:
        for row in csv.reader(f):
            name_en = row[0].strip()
            name_loc = row[1].strip()
            iso_code = row[2].strip()
            if ',' in name_loc:
                name_loc = name_loc[:name_loc.index(',')].strip()
            if ',' in name_en:
                name_en = name_en[:name_en.index(',')].strip()
            tcur.execute("select count_all from keys where key = ?", ('name:' + iso_code,))
            row = tcur.fetchone()
            count = 0 if not row else row[0]
            result.append('|'.join([iso_code, name_en, name_loc, str(count)]))

    dart = open(sys.argv[3], 'r').read()
    repl_str = '\\n'.join(result).replace("'", "\\'")
    dart = re.sub(r"(_kLanguageData =\s+')[^;]*;",
                  lambda m: m.group(1) + repl_str + "';", dart)
    with open(sys.argv[3], 'w') as f:
        f.write(dart)
