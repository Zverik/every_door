const kMainKeys = <String>[
  'amenity', 'shop', 'craft', 'tourism', 'historic', 'highway', 'railway',
  'emergency', 'office', 'healthcare',
  'leisure', 'natural', 'waterway', 'man_made', 'power', 'aeroway',
  'aerialway', 'landuse', 'military', 'barrier', 'building', 'boundary',
];

const kDisused = 'disused:';

String? getMainKey(Map<String, String?> tags, [bool alsoDisused = true]) {
  try {
    final k = kMainKeys.firstWhere((k) => tags.containsKey(k) || (alsoDisused && tags.containsKey(kDisused + k)));
    return tags.containsKey(k) ? k : kDisused + k;
  } on StateError {
    return null;
  }
}

String _clearDisused(String key) =>
    key.startsWith(kDisused) ? key.substring(kDisused.length) : key;

bool isAmenityTags(Map<String, String?> tags) {
  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearDisused(key);
  
  const kAllGoodKeys = <String>{'shop', 'craft', 'office', 'healthcare'};
  if (kAllGoodKeys.contains(k)) return true;

  final v = tags[key];
  if (k == 'amenity') {
    const wrongAmenities = <String>{
      'parking',
      'bench',
      'parking_space',
      'waste_basket',
      'bicycle_parking',
      'shelter',
      'post_box',
      'recycling',
      'drinking_water',
      'vending_machine',
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
      'food_court',
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
      'lounger',
      'dressing_room',
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
    };
    return goodLeisure.contains(v);
  } else if (k == 'emergency') {
    return v == 'ambulance_station';
  } else if (k == 'military') {
    return v == 'office';
  }
  return false;
}

bool isGoodTags(Map<String, String?> tags) {
  final key = getMainKey(tags);
  if (key == null) return false;
  final k = _clearDisused(key);

  const kAllGoodKeys = <String>{
    'shop',
    'craft',
    'office',
    'healthcare',
    'tourism',
    'historic',
    'emergency',
    'man_made',
    'power',
    'aerialway',
    'aeroway',
  };
  if (kAllGoodKeys.contains(k)) return true;

  // Keep all objects with addresses.
  if (tags.containsKey('addr:housenumber') || tags.containsKey('addr:housename'))
    return true;

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
    return v == 'bus_stop' || v == 'street_lamp' || v == 'platform';
  } else if (k == 'railway') {
    return {'station', 'tram_stop', 'halt', 'platform'}.contains(v);
  } else if (k == 'natural') {
    return v == 'tree' || v == 'rock' || v == 'spring';
  }
  return false;
}
