#!/usr/bin/env python3
import sqlite3
import sys
import re
from collections import Counter


RE_START = re.compile(r'(?:^|Mo|Tu|We|Th|Fr|Sa|Su|;)\s*(\d?\d:\d\d)-')
RE_END = re.compile(r'-(\d?\d:\d\d)(?:$|;)')
RE_BREAK = re.compile(r'-(\d?\d:\d\d),\s*(\d?\d:\d\d)-')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Find the most common opening_hours parts.')
        print('Usage: {} <path_to_taginfo.db>'.format(sys.argv[0]))
        sys.exit(1)

    conn = sqlite3.connect(sys.argv[1])
    cur = conn.cursor()
    cur.execute("select value, count_all from tags where key = 'opening_hours' and count_all >= 5")

    starts = Counter()
    ends = Counter()
    breaks = Counter()
    break_starts = Counter()
    break_ends = Counter()
    for row in cur:
        for start in RE_START.finditer(row[0]):
            starts[start.group(1).zfill(5)] += row[1]
        for end in RE_END.finditer(row[0]):
            ends[end.group(1).zfill(5)] += row[1]
        for _break in RE_BREAK.finditer(row[0]):
            breaks[_break.group(1).zfill(5) + '-' + _break.group(2).zfill(5)] += row[1]
            break_starts[_break.group(1).zfill(5)] += row[1]
            break_ends[_break.group(2).zfill(5)] += row[1]

    print('Starts:')
    for v in starts.most_common(14):
        print(f'  {v[0]} {v[1]}')
    print('')
    print('Ends:')
    for v in ends.most_common(14):
        print(f'  {v[0]} {v[1]}')
    print('')
    print('Breaks:')
    for v in breaks.most_common(6):
        print(f'  {v[0]} {v[1]}')
    print('')
    print('Break starts:')
    for v in break_starts.most_common(6):
        print(f'  {v[0]} {v[1]}')
    print('')
    print('Break ends:')
    for v in break_ends.most_common(6):
        print(f'  {v[0]} {v[1]}')
