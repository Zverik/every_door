// DO NOT RE-FORMAT THIS FILE!

/// List of keys to consider when looking for a single main tag, in order of preference.
const kMainKeys = <String>[
  'amenity', 'shop', 'craft', 'tourism', 'historic', 'club',
  'highway', 'railway',
  'office', 'healthcare', 'leisure', 'natural',
  'emergency', 'waterway', 'man_made', 'power', 'aeroway', 'aerialway',
  'marker', 'public_transport', 'traffic_sign', 'hazard', 'telecom',
  'landuse', 'military', 'barrier', 'building', 'entrance', 'boundary',
  'advertising', 'playground', 'traffic_calming',
];
final kMainKeysSet = Set.of(kMainKeys);

const kDisused = 'disused:';
const kDeleted = 'was:';

/// List of highway=* values that can denote a named road.
const kHighwayRoadValues = <String>{
  'service', 'residential', 'pedestrian', 'unclassified', 'tertiary',
  'secondary', 'primary', 'trunk', 'motorway', 'living_street',
};

const kBuildingNeedsAddress = {
  'yes', 'house', 'residential', 'detached', 'apartments',
  'terrace', 'commercial', 'school', 'semidetached_house', 'retail',
  'construction', 'farm', 'church', 'office', 'civic', 'university', 'public',
  'hospital', 'hotel', 'chapel', 'kindergarten', 'mosque', 'dormitory',
  'train_station', 'college', 'semi', 'temple', 'government', 'supermarket',
  'fire_station', 'sports_centre', 'shop', 'stadium', 'religious',
};

/// Type of object to snap an element to.
/// E.g. entrances are snapped to `SnapTo.building`.
enum SnapTo { nothing, building, highway, railway, wall }

/// Kind of element for sorting elements between modes.
enum ElementKind {
  empty,
  unknown,
  amenity,
  micro,
  building,
  entrance,
  address,
}

/// Find the single main key for an object. Also considers lifecycle prefixes.
String? getMainKey(Map<String, String> tags) {
  for (final k in kMainKeys) {
    if (tags[k] == 'no') continue;
    if (tags.containsKey(k)) return k;
    if (tags.containsKey(kDisused + k)) return kDisused + k;
    if (tags.containsKey(kDeleted + k)) return kDeleted + k;
  }
  return null;
}

/// Sorts the element by kind, using its tags and helper functions from this file.
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
  if ((accepted == null || accepted.contains(ElementKind.address)) &&
      getMainKey(tags) == null && (tags.containsKey('addr:housenumber') ||
      tags.containsKey('addr:housename'))) return ElementKind.address;
  if (tags.isEmpty || tags.keys.every((element) => kMetaTags.contains(element)))
    return ElementKind.empty;
  return ElementKind.unknown;
}

/// Removed any prefix for the key, which is before the first `:` character.
String _clearPrefix(String key) => key.substring(key.indexOf(':') + 1);

/// Checks if the object qualifies for an amenity, mostly based on its main tag.
bool isAmenityTags(Map<String, String> tags) {
  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  const kAllGoodKeys = <String>{
    'shop',
    'craft',
    'office',
    'healthcare',
    'club',
  };
  if (kAllGoodKeys.contains(k)) return true;

  final v = tags[key];
  if (k == 'amenity') {
    if (v == 'recycling')
      return tags['recycling_type'] == 'centre';

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
      'lounger',
    };
    return !wrongAmenities.contains(v);
  } else if (k == 'tourism') {
    if (v == 'information') {
      return <String>{'office', 'visitor_centre'}.contains(tags['information']);
    }
    const wrongTourism = <String>{
      'attraction', 'viewpoint', 'artwork', 'picnic_site', 'camp_pitch',
      'wilderness_hut', 'cabin'
    };
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
/// on the micromapping map. Mostly the criteria is "not an amenity".
bool isMicroTags(Map<String, String> tags) {
  if (isAmenityTags(tags)) return false;

  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  // Note that it excludes values accepted by `isAmenityTags`.
  const kAllGoodKeys = <String>{
    'amenity', 'tourism', 'emergency', 'man_made', 'historic',
    'playground', 'advertising', 'power', 'traffic_calming',
    'barrier', 'highway', 'railway', 'natural', 'leisure',
    'marker', 'public_transport', 'hazard', 'traffic_sign',
    'telecom',
  };
  if (kAllGoodKeys.contains(k)) return true;
  return false;
}

/// Returns `true` when an object is editable in this app.
bool isGoodTags(Map<String, String> tags) {
  // Keep all objects with addresses.
  if (tags.containsKey('addr:housenumber') ||
      tags.containsKey('addr:housename')) return true;

  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearPrefix(key);

  const kAllGoodKeys = <String>{
    'shop', 'craft', 'office', 'healthcare', 'tourism', 'historic',
    'club', 'emergency', 'power', 'aerialway', 'aeroway', 'advertising',
    'playground', 'entrance', 'traffic_calming', 'marker',
    'public_transport', 'hazard', 'traffic_sign', 'telecom',
  };
  if (kAllGoodKeys.contains(k)) return true;

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
      'passing_place', 'traffic_signals', 'traffic_mirror',
      'elevator', 'speed_display',
    };
    return kGoodHighway.contains(v);
  } else if (k == 'railway') {
    const kGoodRailway = <String>{
      'station', 'tram_stop', 'halt', 'platform', 'stop', 'signal',
      'crossing', 'milestone', 'tram_crossing', 'subway_entrance',
    };
    return kGoodRailway.contains(v);
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
  } else if (k == 'building') {
    return v != 'roof';
  } else if (k == 'barrier') {
    const kGoodBarriers = <String>{
      'gate', 'bollard', 'lift_gate', 'kerb', 'block',
      'cycle_barrier', 'stile', 'entrance', 'swing_gate',
      'cattle_grid', 'toll_booth', 'kissing_gate', 'chain',
      'turnstile', 'height_restrictor', 'sliding_gate', 'border_control',
    };
    return kGoodBarriers.contains(v);
  } else if (k == 'man_made') {
    const kWrongManMade = <String>{
      'bridge', 'works', 'clearcut', 'pier', 'wastewater_plant',
      'cutline', 'pipeline', 'embankment', 'breakwater',
      'groyne', 'reservoir_covered', 'water_works', 'courtyard', 'dyke',
    };
    return !kWrongManMade.contains(v);
  }
  return false;
}

/// Whether we should set `check_date` on an object.
/// Currently returns `isAmenityTags(tags)`.
bool needsCheckDate(Map<String, String> tags) {
  // Decided that only amenities need checking.
  return isAmenityTags(tags);
}

/// Whether we should display address and floor fields in the editor.
bool needsAddress(Map<String, String> tags) {
  if (isAmenityTags(tags)) return true;
  const kAmenityLoc = {'atm', 'vending_machine', 'parcel_locker'};
  return kAmenityLoc.contains(tags['amenity']);
}

/// What kind of objects should we snap this element to?
/// Does not support multiple types, so barriers are snapped only to roads.
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
  else if (k == 'historic' && {'plaque', 'blue_plaque'}.contains(tags['memorial']))
    return SnapTo.building;

  return SnapTo.nothing;
}

/// Is this a kind of a way to which we can snap an object?
bool isSnapTargetTags(Map<String, String> tags, [SnapTo? kind]) {
  if (tags.containsKey('highway') && (kind == null || kind == SnapTo.highway))
    return !{'steps', 'platform', 'services', 'rest_area', 'bus_stop', 'elevator'}
      .contains(tags['highway']);
  if (tags.containsKey('railway') && (kind == null || kind == SnapTo.railway))
    return !{'platform', 'station', 'signal_box', 'platform_edge'}
      .contains(tags['railway']);
  if (tags.containsKey('building') && (kind == null || kind == SnapTo.building))
    return tags['building'] != 'roof';
  if (tags.containsKey('barrier') && (kind == null || kind == SnapTo.wall))
    return {'wall', 'fence'}.contains(tags['barrier']);
  return false;
}

/// Checks whether some selected secondary tags are empty. We display this
/// information in the micromapping mode.
bool needsMoreInfo(Map<String, String> tags) {
  if (tags['amenity'] == 'bench')
    return tags['backrest'] == null || tags['material'] == null;
  if (tags['amenity'] == 'bicycle_parking')
    return tags['bicycle_parking'] == null || tags['capacity'] == null;
  if (tags['amenity'] == 'post_box')
    return tags['collection_times'] == null || tags['ref'] == null;
  if (tags['amenity'] == 'recycling')
    return tags['recycling_type'] == null || !tags.keys.any((k) => k.startsWith('recycling:'));
  if (tags['amenity'] == 'waste_disposal') return tags['waste'] == null;

  if (tags['emergency'] == 'fire_hydrant') return tags['fire_hydrant:type'] == null;

  if (tags['highway'] == 'crossing') return tags['crossing'] == null;
  // if (tags['highway'] == 'street_lamp') return tags['lamp_mount'] == null;
  if (tags['highway'] == 'bus_stop')
    return tags['bench'] == null || tags['shelter'] == null;

  if (tags['man_made'] == 'manhole') return tags['manhole'] == null;
  if (tags['man_made'] == 'street_cabinet') return tags['street_cabinet'] == null;
  if (tags['man_made'] == 'utility_pole') return tags['utility'] == null;

  if (tags['natural'] == 'tree')
    return tags['leaf_type'] == null || tags['leaf_cycle'] == null;

  if (tags['power'] == 'pole') return tags['material'] == null;
  if (tags['power'] == 'tower') return tags['ref'] == null;
  if (tags['power'] == 'substation') return tags['ref'] == null;
  return false;
}
