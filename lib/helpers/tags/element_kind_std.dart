import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/main_key.dart';
import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';

/// To be used only from [ElementKind.reset].
void registerStandardKinds() {
  ElementKind.register("empty", _EmptyKind());
  ElementKind.register("amenity", _AmenityKind());
  ElementKind.register("micro", _MicroKind());
  ElementKind.register("building", _BuildingKind());
  ElementKind.register("entrance", _EntranceKind());
  ElementKind.register("address", _AddressKind());
  ElementKind.register("structure", _StructureKind());
  ElementKind.register("needsCheck", _AmenityKind());
  ElementKind.register("needsInfo", _NeedsMoreInfo());
  ElementKind.register("everything", _EverythingKind());
}

class _AmenityKind extends ElementKindImpl {
  _AmenityKind()
      : super(
          icon: MultiIcon(fontIcon: Icons.shopping_cart),
          matcher: TagMatcher(good: {
            'shop',
            'craft',
            'office',
            'healthcare',
            'club',
          }, {
            'amenity': ValueMatcher(
              when: {
                'recycling': TagMatcher({
                  'recycling_type': ValueMatcher(only: {'centre'}),
                }),
              },
              except: {
                'parking',
                'bench',
                'parking_space',
                'clothes_dryer',
                'dressing_room',
                'shower',
                'waste_basket',
                'bicycle_parking',
                'shelter',
                'post_box',
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
                'food_sharing',
                'give_box',
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
              },
            ), // amenity
            'tourism': ValueMatcher(
              when: {
                'information': TagMatcher({
                  'information':
                      ValueMatcher(only: {'office', 'visitor_centre'}),
                }),
              },
              except: {
                'attraction',
                'viewpoint',
                'artwork',
                'picnic_site',
                'camp_pitch',
                'wilderness_hut',
                'cabin'
              },
            ),
            'leisure': ValueMatcher(only: {
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
            }),
            'emergency': ValueMatcher(only: {
              'ambulance_station',
              'mountain_rescue',
              'ses_station',
              'water_rescue',
              'air_rescue_service',
            }),
            'military': ValueMatcher(only: {'office', 'school', 'academy'}),
            'attraction': ValueMatcher(only: {
              // From top attraction values used with opening_hours.
              'big_wheel', 'amusement_ride', 'winery', 'maze', 'carousel',
              'geosite', 'train', 'summer_toboggan', 'river_rafting',
            }),
            'xmas:feature': ValueMatcher(except: {'tree'}),
          }),
        );
}

class _MicroKind extends ElementKindImpl {
  _MicroKind()
      : super(
            icon: MultiIcon(fontIcon: Icons.park),
            matcher: TagMatcher({}, good: {
              'advertising',
              'aeroway',
              'amenity',
              'attraction',
              'barrier',
              'cemetery',
              'emergency',
              'hazard',
              'highway',
              'historic',
              'leisure',
              'man_made',
              'marker',
              'natural',
              'playground',
              'power',
              'public_transport',
              'railway',
              'telecom',
              'tourism',
              'traffic_calming',
              'traffic_sign',
              'waterway',
              'xmas:feature',
            }));

  @override
  bool matchesTags(Map<String, String> tags) {
    if (ElementKind.amenity.matchesTags(tags)) return false;
    return super.matchesTags(tags);
  }

  @override
  bool matchesChange(OsmChange change) {
    if (ElementKind.amenity.matchesChange(change)) return false;
    return super.matchesChange(change);
  }
}

class _EntranceKind extends ElementKindImpl {
  _EntranceKind()
      : super(
          icon: MultiIcon(fontIcon: Icons.door_front_door),
          matcher: TagMatcher({
            'entrance': ValueMatcher(),
            'building': ValueMatcher(only: {"entrance"}),
          }),
          onMainKey: false,
        );
}

class _BuildingKind extends ElementKindImpl {
  _BuildingKind()
      : super(
          icon: MultiIcon(fontIcon: Icons.home),
          matcher: TagMatcher({
            'building': ValueMatcher(except: {"entrance"}),
          }),
          onMainKey: false,
        );
}

class _AddressKind extends ElementKindImpl {
  _AddressKind() : super(icon: MultiIcon(fontIcon: Icons.onetwothree));

  @override
  bool matchesTags(Map<String, String> tags) {
    return getMainKey(tags) == null &&
        (tags.containsKey('addr:housenumber') ||
            tags.containsKey('addr:housename'));
  }

  @override
  bool matchesChange(OsmChange change) {
    return change.mainKey == null &&
        (change['addr:housenumber'] != null ||
            change['addr:housename'] != null);
  }
}

class _EmptyKind extends ElementKindImpl {
  static const _kMetaTags = {'source', 'note'};

  _EmptyKind() : super(onMainKey: false);

  @override
  bool matchesTags(Map<String, String> tags) {
    return tags.isEmpty ||
        tags.keys.every((element) => _kMetaTags.contains(element));
  }

  @override
  bool matchesChange(OsmChange change) => matchesTags(change.getFullTags());
}

class _EverythingKind extends ElementKindImpl {
  _EverythingKind()
      : super(
          matcher: TagMatcher(good: {
            'shop',
            'craft',
            'office',
            'healthcare',
            'tourism',
            'historic',
            'club',
            'emergency',
            'power',
            'aerialway',
            'aeroway',
            'advertising',
            'playground',
            'entrance',
            'traffic_calming',
            'marker',
            'public_transport',
            'hazard',
            'traffic_sign',
            'telecom',
            'xmas:feature',
            'building',
          }, {
            'amenity': ValueMatcher(except: {
              'parking',
              'parking_space',
              'parking_entrance',
              'loading_dock',
              'waste_dump_site',
              'waste_transfer_station',
            }),
            'leisure': ValueMatcher(except: {
              'park',
              'garden',
              'nature_reserve',
              'track',
              'common',
              'grass',
            }),
            'highway': ValueMatcher(only: {
              'crossing',
              'bus_stop',
              'street_lamp',
              'platform',
              'stop',
              'give_way',
              'milestone',
              'speed_camera',
              'passing_place',
              'traffic_signals',
              'traffic_mirror',
              'elevator',
              'speed_display',
              'emergency_access_point',
            }),
            'railway': ValueMatcher(only: {
              'station',
              'tram_stop',
              'halt',
              'platform',
              'stop',
              'signal',
              'crossing',
              'milestone',
              'tram_crossing',
              'subway_entrance',
              'ventilation_shaft',
            }),
            'natural': ValueMatcher(only: {
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
              'anthill',
            }),
            'barrier': ValueMatcher(except: {
              'cable_barrier',
              'city_wall',
              'ditch',
              'fence',
              'guard_rail',
              'handrail',
              'hedge',
              'retaining_wall',
              'wall',
              'delineators',
            }),
            'man_made': ValueMatcher(except: {
              'bridge',
              'works',
              'clearcut',
              'pier',
              'wastewater_plant',
              'cutline',
              'pipeline',
              'embankment',
              'breakwater',
              'groyne',
              'reservoir_covered',
              'water_works',
              'courtyard',
              'dyke',
              'ventilation_shaft',
            }),
            'military': ValueMatcher(only: {
              'academy',
              'base',
              'barracks',
              'checkpoint',
              'office',
              'school',
              'range',
            }),
            'cemetery': ValueMatcher(only: {'grave'}),
            'waterway': ValueMatcher(only: {
              'dam',
              'weir',
              'waterfall',
              'rapids',
              'lock_gate',
              'sluice_gate',
              'floodgate',
              'debris_screen',
              'check_dam',
              'turning_point',
              'water_point',
              'fuel',
            }),
          }),
        );

  static const _kAnyKeys = {'addr:housenumber', 'addr:housename', 'building'};

  @override
  bool matchesTags(Map<String, String> tags) {
    if (_kAnyKeys.any((k) => tags.containsKey(k))) return true;
    return super.matchesTags(tags);
  }

  @override
  bool matchesChange(OsmChange change) {
    if (_kAnyKeys.any((k) => change[k] != null)) return true;
    return super.matchesChange(change);
  }
}

class _StructureKind extends ElementKindImpl {
  _StructureKind()
      : super(
          matcher: TagMatcher({
            'amenity': ValueMatcher(
              only: {
                'kindergarten',
                'college',
                'library',
                'research_institute',
                'school',
                'university',
                'ferry_terminal',
                'hospital',
                'cinema',
                'theatre',
                'arts_centre',
                'conference_centre',
                'events_venue',
                'courthouse',
                'fire_station',
                'police',
                'prison',
                'townhall',
                'crematorium',
                'funeral_hall',
                'grave_yard',
                'marketplace',
                'monastery',
                'place_of_worship',
              },
            ),
            'leisure': ValueMatcher(only: {'stadium', 'golf_course', 'resort'}),
          }),
        );
}

class _NeedsMoreInfo extends ElementKindImpl {
  _NeedsMoreInfo()
      : super(
          matcher: TagMatcher({
            'amenity': ValueMatcher(when: {
              'bench': TagMatcher({}, missing: {'backrest', 'material'}),
              'bicycle_parking':
                  TagMatcher({}, missing: {'bicycle_parking', 'capacity'}),
              'post_box': TagMatcher({}, missing: {'collection_times', 'ref'}),
              'recycling': TagMatcher({},
                  missing: {'recycling_type'}), // TODO: recycling:*=*
              'waste_disposal': TagMatcher({}, missing: {'waste'}),
            }),
            'emergency': ValueMatcher(when: {
              'fire_hydrant': TagMatcher({}, missing: {'fire_hydrant:type'}),
            }),
            'highway': ValueMatcher(when: {
              'crossing': TagMatcher({}, missing: {'crossing'}),
              // 'street_lamp': TagMatcher({}, missing: {'lamp_mount'}),
              'bus_stop': TagMatcher({}, missing: {'bench', 'shelter'}),
            }),
            'natural': ValueMatcher(when: {
              'tree': TagMatcher({}, missing: {'leaf_type', 'leaf_cycle'}),
            }),
            'power': ValueMatcher(when: {
              'pole': TagMatcher({}, missing: {'material'}),
              'tower': TagMatcher({}, missing: {'ref'}),
              'substation': TagMatcher({}, missing: {'ref'}),
            }),
          }),
          onMainKey: false,
        );
}
