// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/tags/main_key.dart';

/// Type of object to snap an element to.
/// E.g. entrances are snapped to `SnapTo.building`.
enum SnapTo { nothing, building, highway, railway, wall, stream }

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
  // else if (k == 'historic' && {'plaque', 'blue_plaque'}.contains(tags['memorial']))
  //   return SnapTo.building;
  else if (k == 'public_transport' && tags['public_transport'] == 'stop_position') {
    if (tags['bus'] == 'yes' || tags['trolleybus'] == 'yes')
      return SnapTo.highway;
    else if (tags['train'] == 'yes' || tags['subway'] == 'yes' || tags['tram'] == 'yes')
      return SnapTo.railway;
  }
  else if (tags['support'] == 'wall_mounted') return SnapTo.wall;
  else if (k == 'tourism' && tags['tourism'] == 'artwork') {
    if ({'mural', 'graffiti'}.contains(tags['artwork_type'])) return SnapTo.wall;
  }
  else if (k == 'waterway') {
    if (!{'turning_point', 'water_point', 'fuel'}.contains(tags[k]))
      return SnapTo.stream;
  }

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
    return tags['building'] != 'roof' && tags['building'] != 'part';
  if (tags.containsKey('barrier') && (kind == null || kind == SnapTo.wall))
    return {'wall', 'fence'}.contains(tags['barrier']);
  if (tags.containsKey('waterway') && (kind == null || kind == SnapTo.stream))
    return {'river', 'stream', 'ditch', 'drain', 'canal'}.contains(tags['waterway']);
  return false;
}