#!/usr/bin/env python3
import sys
import json
import sqlite3
from shapely.geometry import shape
from polygon_geohasher.polygon_geohasher import polygon_to_geohashes


def download_imagery():
    import requests
    resp = requests.get('https://osmlab.github.io/editor-layer-index/imagery.geojson')
    if resp.status_code != 200:
        raise IOError('Failed to download imagery.geojson')
    return resp.json()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Adds imagery index to the Every Door database')
        print('Usage: {} <presets.db> [<imagery.geojson>]'.format(sys.argv[0]))
        sys.exit(1)

    json_path = None if len(sys.argv) <= 2 else sys.argv[2]

    conn = sqlite3.connect(sys.argv[1])
    cur = conn.cursor()
    cur.execute(
        """
        create table imagery (
            imagery_id integer,
            id text,
            is_wms integer,
            name text,
            url text,
            icon text,
            attribution text,
            min_zoom integer,
            max_zoom integer,
            tile_size integer,
            wms_4326 integer,
            is_default integer,
            is_best integer,
            is_world integer
        )""")
    cur.execute("create table imagery_lookup (imagery_id integer, geohash text)")

    if not json_path:
        data = download_imagery()
    else:
        with open(json_path, 'r') as f:
            data = json.load(f)

    iid = 1
    for feature in data['features']:
        imagery = feature['properties']
        if imagery.get('overlay'):
            continue
        if imagery['type'] not in ('tms', 'wms'):
            continue
        if imagery.get('category') not in (None, 'photo', 'map'):
            continue
        if imagery.get('country_code') == 'AQ':
            continue
        attribution = imagery.get('attribution', {}).get('text')
        if attribution and 'openstreetmap' in attribution.lower():
            continue

        crs = imagery.get('available_projections', [])
        need_4326 = False
        if imagery['type'] == 'wms':
            if 'EPSG:3857' not in crs:
                if 'EPSG:4326' in crs:
                    need_4326 = True
                else:
                    # Does not support neither 3857 nor 4326
                    continue

        # Store imagery data
        values = [
            iid, imagery['id'], imagery['type'] == 'wms', imagery['name'],
            imagery['url'], imagery.get('icon'), attribution,
            imagery.get('min_zoom'),
            imagery.get('max_zoom'),
            imagery.get('tile_size'),
            1 if need_4326 else 0,
            1 if imagery.get('default') else 0,
            1 if imagery.get('best') else 0,
            1 if not feature['geometry'] else 0,
        ]
        cur.execute(
            "insert into imagery (imagery_id, id, is_wms, name, url, icon, attribution, "
            "min_zoom, max_zoom, tile_size, wms_4326, is_default, is_best, is_world) "
            "values ({})".format(
                ','.join(['?'] * len(values))),
            values)

        # Populate geohash index
        if feature['geometry']:
            try:
                geohashes = polygon_to_geohashes(shape(feature['geometry']), 4, False)

                cur.executemany(
                    "insert into imagery_lookup (imagery_id, geohash) values (?, ?)",
                    [(iid, geohash) for geohash in geohashes])
            except Exception as e:
                print(f"failed with {e}: {imagery['id']}")

        iid += 1

    cur.execute("create index imagery_lookup_idx on imagery_lookup (geohash)")
    conn.commit()
    conn.close()
