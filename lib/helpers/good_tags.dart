const kMainKeys = <String>[
  'amenity', 'shop', 'craft', 'tourism', 'historic',
  'highway', 'railway',
  'emergency', 'office', 'healthcare', 'leisure', 'natural',
  'waterway', 'man_made', 'power', 'aeroway', 'aerialway',
  'landuse', 'military', 'barrier', 'building', 'entrance', 'boundary',
  'advertising', 'playground', 'traffic_calming',
];
final kMainKeysSet = Set.of(kMainKeys);

const kDisused = 'disused:';
const kDeleted = 'was:';

const kStreetStatusWords = {
  'улица', 'переулок', 'проспект', 'набережная', 'проезд', 'бульвар', 'аллея',
  // TODO: count statistics over all the streets and populate this list.
};

enum SnapTo { nothing, building, highway, railway }

enum ElementKind {
  empty,
  unknown,
  amenity,
  micro,
  building,
  entrance,
}

String? getMainKey(Map<String, String> tags, [bool alsoDisused = true]) {
  for (final k in kMainKeys) {
    if (tags.containsKey(k)) return k;
    if (alsoDisused && tags.containsKey(kDisused + k)) return kDisused + k;
    if (alsoDisused && tags.containsKey(kDeleted + k)) return kDeleted + k;
  }
  return null;
}

ElementKind detectKind(Map<String, String> tags, [Set<ElementKind>? accepted]) {
  const kMetaTags = {'source', 'note'};
  if ((accepted == null || accepted.contains(ElementKind.amenity)) &&
      isAmenityTags(tags)) return ElementKind.amenity;
  if ((accepted == null || accepted.contains(ElementKind.micro)) &&
      isMicroTags(tags)) return ElementKind.micro;
  if ((accepted == null || accepted.contains(ElementKind.entrance)) &&
          tags['entrance'] != null ||
      tags['building'] == 'entrance') return ElementKind.entrance;
  if ((accepted == null || accepted.contains(ElementKind.building)) &&
      tags['building'] != null) return ElementKind.building;
  if (tags.isEmpty || tags.keys.every((element) => kMetaTags.contains(element)))
    return ElementKind.empty;
  return ElementKind.unknown;
}

String _clearPrefix(String key) => key.substring(key.indexOf(':') + 1);

bool isAmenityTags(Map<String, String> tags) {
  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  const kAllGoodKeys = <String>{
    'shop',
    'craft',
    'office',
    'healthcare',
    'club'
  };
  if (kAllGoodKeys.contains(k)) return true;

  final v = tags[key];
  if (k == 'amenity') {
    const wrongAmenities = <String>{
      'parking',
      'bench',
      'parking_space',
      'clothes_dryer',
      'waste_basket',
      'bicycle_parking',
      'shelter',
      'post_box',
      'recycling',
      'drinking_water',
      'hunting_stand',
      'grave_yard',
      'waste_disposal',
      'fountain',
      'parking_entrance',
      'telephone',
      'charging_station',
      'taxi',
      'water_point',
      'bbq',
      'motorcycle_parking',
      'grit_bin',
      'clock',
      'watering_place',
      'public_bookcase',
      'car_sharing',
      'bicycle_repair_station',
      'loading_dock',
      'letter_box',
      'waste_dump_site',
      'compressed_air',
      'sanitary_dump_station',
      'lavoir',
      'waste_transfer_station',
      'boat_storage',
      'weightbridge',
      'feeding_place',
      'game_feeding',
      'trolley_bay',
      'ticket_validator',
      'health_post',
      'kneipp_water_cure',
      'vacuum_cleaner',
      'car_pooling',
      'table',
      'garages',
      'vehicle_ramp',
      'water',
      'yes',
      'chair',
      'nameplate',
    };
    return !wrongAmenities.contains(v);
  } else if (k == 'tourism') {
    if (v == 'information') {
      return <String>{'office', 'visitor_centre'}.contains(tags['information']);
    }
    const wrongTourism = <String>{'attraction', 'viewpoint', 'artwork'};
    return !wrongTourism.contains(v);
  } else if (k == 'leisure') {
    const goodLeisure = <String>{
      'sports_centre',
      'fitness_centre',
      'stadium',
      'golf_course',
      'marina',
      'horse_riding',
      'resort',
      'sauna',
      'water_park',
      'sports_hall',
      'beach_resort',
      'miniature_golf',
      'dance',
      'ice_rink',
      'adult_gaming_centre',
      'bowling_alley',
      'amusement_arcade',
      'tanning_salon',
      'escape_game',
      'hackerspace',
      'climbing',
      'trampoline_park',
      'social_club',
      'club',
      'maze',
      'shooting_ground',
      'spa',
      'trampoline',
      'indoor_play',
      'racetrack',
      'hot_spring',
      'arena',
      'turkish_bath',
      'water_slide',
      'karaoke',
      'bird_hide',
      'wildlife_hide',
    };
    return goodLeisure.contains(v);
  } else if (k == 'emergency') {
    return v == 'ambulance_station';
  } else if (k == 'military') {
    return v == 'office';
  }
  return false;
}

/// Returns `true` if the object with these tags is to be displayed
/// on the micromapping map.
bool isMicroTags(Map<String, String> tags) {
  if (isAmenityTags(tags)) return false;

  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  // Note that it excludes values accepted by `isAmenityTags`.
  const kAllGoodKeys = <String>{
    'amenity', 'tourism', 'emergency', 'man_made', 'historic',
    'playground', 'advertising', 'power', 'traffic_calming',
  };
  if (kAllGoodKeys.contains(k)) return true;

  final v = tags[key];
  if (k == 'highway') {
    const goodHighway = {
      'street_lamp',
      'speed_camera',
      'emergency_access_point',
      'bus_stop',
      'platform',
      'traffic_mirror',
      'elevator',
      'speed_display'
    };
    return goodHighway.contains(v);
  } else if (k == 'leisure') {
    const goodLeisure = {
      'picnic_table',
      'playground',
      'fitness_station',
      'firepit',
      'fishing',
      'outdoor_seating',
      'dog_park',
      'bathing_place',
      'table',
      'village_swing'
    };
    return goodLeisure.contains(v);
  } else if (k == 'natural') {
    const goodNatural = {
      'tree',
      'rock',
      'shrub',
      'spring',
      'cave_entrance',
      'stone',
      'birds_nest',
      'termite_mound',
      'tree_stump',
      'bush',
      'razed:tree',
      'geyser',
      'plant',
      'anthill'
    };
    return goodNatural.contains(v);
  }
  return false;
}

bool isGoodTags(Map<String, String> tags) {
  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  const kAllGoodKeys = <String>{
    'shop',
    'craft',
    'office',
    'healthcare',
    'tourism',
    'historic',
    'club',
    'emergency',
    'man_made',
    'power',
    'aerialway',
    'aeroway',
    'advertising',
    'playground',
    'entrance',
  };
  if (kAllGoodKeys.contains(k)) return true;

  // Keep all objects with addresses.
  if (tags.containsKey('addr:housenumber') ||
      tags.containsKey('addr:housename')) return true;

  final v = tags[key];
  if (k == 'amenity') {
    const kWrongAmenities = <String>{
      'parking',
      'parking_space',
      'parking_entrance',
      'loading_dock',
      'waste_dump_site',
      'sanitary_dump_station',
      'waste_transfer_station',
    };
    return !kWrongAmenities.contains(v);
  } else if (k == 'leisure') {
    const kWrongLeisure = <String>{
      'park',
      'garden',
      'pitch',
      'nature_reserve',
      'track',
      'common',
      'grass',
    };
    return !kWrongLeisure.contains(v);
  } else if (k == 'highway') {
    const kGoodHighway = <String>{
      'crossing', 'bus_stop', 'street_lamp', 'platform',
      'stop', 'give_way', 'milestone', 'speed_camera',
      'passing_place',
    };
    return kGoodHighway.contains(v);
  } else if (k == 'railway') {
    const kGoodRailway = <String>{
      'station', 'tram_stop', 'halt', 'platform', 'stop', 'signal',
      'crossing', 'milestone', 'tram_crossing',
    };
    return kGoodRailway.contains(v);
  } else if (k == 'natural') {
    return v == 'tree' || v == 'rock' || v == 'spring' || v == 'shrub' || v == 'stone';
  } else if (k == 'building') {
    return v != 'roof';
  }
  return false;
}

bool needsCheckDate(Map<String, String> tags) {
  // Decided that only amenities need checking.
  return isAmenityTags(tags);
}

SnapTo detectSnap(Map<String, String> tags) {
  final k = getMainKey(tags);
  if (k == null) return SnapTo.nothing;

  if (tags.containsKey('entrance') || tags['building'] == 'entrance') {
    return SnapTo.building;
  } else if (k == 'highway') {
    const kSnapHighway = <String>{
      'crossing', 'stop', 'give_way', 'milestone',
      'speed_camera', 'passing_place',
    };
    if (kSnapHighway.contains(tags['highway']!)) return SnapTo.highway;
  } else if (k == 'railway') {
    const kSnapRailway = <String>{
      'halt', 'stop', 'signal', 'crossing', 'milestone',
      'tram_stop', 'tram_crossing',
    };
    if (kSnapRailway.contains(tags['railway']!)) return SnapTo.railway;
  } else if ({'traffic_calming', 'barrier'}.contains(k)) return SnapTo.highway;

  return SnapTo.nothing;
}

bool isSnapTargetTags(Map<String, String> tags, [SnapTo? kind]) {
  if (tags.containsKey('highway') && (kind == null || kind == SnapTo.highway))
    return !{'steps', 'platform', 'services', 'rest_area', 'bus_stop', 'elevator'}
      .contains(tags['highway']);
  if (tags.containsKey('railway') && (kind == null || kind == SnapTo.railway))
    return !{'platform', 'station', 'signal_box', 'platform_edge'}
      .contains(tags['railway']);
  if (tags.containsKey('building') && (kind == null || kind == SnapTo.building))
    return tags['building'] != 'roof';
  return false;
}

bool needsMoreInfo(Map<String, String> tags) {
  if (tags['amenity'] == 'bench') return tags['backrest'] == null;
  if (tags['amenity'] == 'bicycle_parking')
    return tags['bicycle_parking'] == null || tags['capacity'] == null;
  if (tags['amenity'] == 'post_box')
    return tags['collection_times'] == null || tags['ref'] == null;
  if (tags['amenity'] == 'recycling')
    return tags['recycling_type'] == null || !tags.keys.any((k) => k.startsWith('recycling:'));

  if (tags['emergency'] == 'fire_hydrant') return tags['fire_hydrant:type'] == null;
  if (tags['highway'] == 'crossing') return tags['crossing'] == null;
  if (tags['highway'] == 'street_lamp')
    return tags['lamp_type'] == null || tags['lamp_mount'] == null;

  if (tags['man_made'] == 'manhole') return tags['manhole'] == null;
  if (tags['man_made'] == 'street_cabinet') return tags['street_cabinet'] == null;
  if (tags['man_made'] == 'utility_pole') return tags['utility'] == null;

  if (tags['natural'] == 'tree')
    return tags['leaf_type'] == null || tags['leaf_cycle'] == null;

  if (tags['power'] == 'pole') return tags['material'] == null;
  if (tags['power'] == 'tower') return tags['ref'] == null;
  return false;
}