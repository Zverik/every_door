#!/usr/bin/env python3
import sys
import sqlite3

sql = """
with langs (lang, lscore) as (
  values ('ru', 2), ('en', 1)
)
,tags (skey, svalue) as (
  values
  ('building', 'yes'),
  ('tourism', 'information'),
  ('information', 'office'),
  ('name', 'Инфопункт'),
  ('opening_hours', '24/7')
)
,matches as (
  select preset_name, count(*) as tag_count, count(skey) as match_count
  from preset_tags
  left join tags on key = skey and (value is null or value = svalue)
  group by preset_name
)
select p.name, t.name, icon, fields, match_score, match_count
from presets p
  inner join matches m on p.name = m.preset_name and tag_count = match_count
  cross join langs
  left join preset_tran t on p.name = t.preset_name and langs.lang = t.lang
where t.name is not null
order by match_count desc, length(p.name) desc, match_score desc, langs.lscore desc, p.name
limit 10
"""

sql = """
with langs (lang, lscore) as (
  values ('ru', 1), ('en', 2)
)
,tags (tkey, tvalue) as (
  values
  ('building', 'roof'),
  ('name', 'Olerex'),
  ('amenity', 'fuel'),
  ('building:levels', '1'),
  ('addr:housenumber', '155'),
  ('addr:street', 'Oismae tee'),
  ('opening_hours', '24/7')
)
,matches as (
  select preset_name, count(*) as tag_count, count(tkey) as match_count
  from preset_tags
  left join tags on key = tkey and (value is null or value = tvalue)
  group by preset_name
),
found as (
  select name
  from presets
    inner join matches on name = preset_name and tag_count = match_count
  where can_area =1
  order by match_count desc, length(name) desc, match_score desc, name
)
select p.*, t.name as loc_name
from found f
left join presets p on f.name = p.name
left join preset_tran t on t.preset_name = f.name
inner join langs on langs.lang = t.lang
order by lscore limit 10
"""

sql = """
with langs (lang, lscore) as (values ('ru', 1),('ru', 2),('en', 3)),
tags (tkey, tvalue) as (values
  ('shop', 'florist'),
  ('entrance', 'main'),
  ('name','Olerex'),
  ('opening_hours', '24/7')
)
,matches as (
  select preset_name, count(*) as tag_count, count(tkey) as match_count
  from preset_tags
  left join tags on key = tkey and (value is null or value = tvalue)
  group by preset_name
),
found as (
  select name, match_count, length(name), match_score
  from presets
    inner join matches on name = preset_name and tag_count = match_count
  where can_area = 1
  order by match_count desc, match_score desc, length(name) desc, name
  --limit 1
)
select * from found
--select p.*, t.name as loc_name
--from found f
--left join presets p on f.name = p.name
--left join preset_tran t on t.preset_name = f.name
--inner join langs on langs.lang = t.lang
--order by lscore limit 1
"""

term_sql = """
select preset_name, max(score) as score
from preset_terms
where term like 'пари%'
group by preset_name
order by score desc, min(length(term));
"""

std_sql = """
with langs (lang, lscore) as (values ('ru', 1),('ru', 2),('en', 3))
select f.*, t.label as loc_label,
  t.placeholder as loc_placeholder,
  t.options as loc_options,
  lscore
from fields f
left join field_tran t on t.field_name = f.name
inner join langs on langs.lang = t.lang
where f.name in (?,?,?,?,?,?,?,?,?,?,?)
order by lscore
limit 10
"""
std_fields = [
    'name', 'address', 'level', 'opening_hours', 'operator', 'email',
    'payment_multi', 'website', 'wheelchair', 'internet_access', 'description'
]

stop_tags1 = "('bus','yes'),('highway','bus_stop'),('public_transport','platform')"
stop_tags2 = "('highway','bus_stop'),('public_transport','platform')"
stop_sql = """
with tags (tkey, tvalue) as (values {tags})
, matches as (
select preset_name, count(*) as tag_count, count(tkey) as match_count, count(value) as full_tag_count
from preset_tags
left join tags on key = tkey and (value is null or value = tvalue)
group by preset_name
having match_count > 0
)
select name, match_count, full_tag_count, match_score from presets
inner join matches on name = preset_name and tag_count = match_count
order by match_count desc, full_tag_count desc, match_score desc, length(name) desc, name
"""

conn = sqlite3.connect(sys.argv[1] if len(sys.argv) > 1 else '../assets/presets.db')
cur = conn.cursor()
print('Searching by tags:')
cur.execute(sql)
for row in cur:
    print(row)
print()
print('Searching by terms:')
cur.execute(term_sql)
for row in cur:
    print(row)
print()
print('Standard fields')
cur.execute(std_sql, std_fields)
for row in cur:
    print(row)
print()
print('Bus stop fail')
print('name, match_count, full_tag_count, match_score')
for tags in (stop_tags1, stop_tags2):
    print('--> ' + tags)
    cur.execute(stop_sql.format(tags=stop_tags1))
    for row in cur:
        print(row)
