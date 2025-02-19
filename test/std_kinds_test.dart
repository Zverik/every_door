import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:test/test.dart';

void testKinds({
  String? name,
  required ElementKindImpl kind,
  required List<String> good,
  required List<String> bad,
}) {
  final kindName = name ?? kind.runtimeType.toString();

  for (final t in good) {
    final kv = t.split('=');
    final tags = {kv[0]: kv[1]};
    expect(kind.matchesTags(tags), isTrue,
        reason: '[$kindName] $t should be good');
  }

  for (final t in bad) {
    final kv = t.split('=');
    final tags = {kv[0]: kv[1]};
    expect(kind.matchesTags(tags), isFalse,
        reason: '[$kindName] $t should be bad');
  }
}

void main() {
  ElementKind.reset();

  test('Good kinds', () {
    testKinds(
      kind: ElementKind.everything,
      name: 'everything',
      good: [
        'addr:housename=name',
        'addr:housenumber=1',
        'xmas:feature=tree',
        'craft=any',
        'power=pole',
        'advertising=banner',
        'playground=swing',
        'entrance=main',
        'traffic_calming=bump',
        'marker=geo',
        'public_transport=stop',
        'hazard=wind',
        'traffic_sign=stop',
        'telecom=office',
        'hazard=bio',
        'military=office',
        'amenity=bench',
        'amenity=parking_spot',
        'amenity=any',
        'shop=whatever',
        'leisure=playground',
        'highway=bus_stop',
        'highway=crossing',
        'railway=crossing',
        'natural=tree',
        'building=roof',
        'building=yes',
        'barrier=gate',
        'barrier=border_control',
        'man_made=chimney',
        'cemetery=grave',
        'waterway=dam',
        'waterway=fuel',
      ],
      bad: [
        'random=tag',
        'amenity=parking',
        'leisure=park',
        'highway=secondary',
        'railway=rail',
        'natural=wood',
        'building:part=yes',
        'man_made=pier',
        'cemetery=pet',
        'barrier=wall',
      ],
    );
  });

  test('Good + bad = good', () {
    final tags = {
      'barrier': 'fence',
      'natural': 'wood',
      'shop': 'supermarket',
      'waterway': 'river',
    };
    expect(ElementKind.everything.matchesTags(tags), isTrue);
  });

  test('Amenities', () {
    testKinds(
      kind: ElementKind.amenity,
      name: 'amenity',
      good: [
        'shop=general',
        'shop=any_other',
        'craft=whatever',
        'club=nightclublol',
        'office=serious',
        'healthcare=everything',
        'amenity=place_of_worship',
        'amenity=post_office',
        'amenity=pharmacy',
        'tourism=hotel',
        'leisure=sports_centre',
        'leisure=dance',
        'emergency=ambulance_station',
        'military=office',
        'attraction=big_wheel',
        'xmas:feature=market',
      ],
      bad: [
        'random=tag',
        'amenity=bench',
        'amenity=fountain',
        'tourism=attraction',
        'leisure=playground',
        'emergency=defibrillator',
        'military=other',
        'attraction=viewpoint',
        'xmas:feature=tree',
      ],
    );
  });

  test('Prefixed amenity', () {
    testKinds(
      kind: ElementKind.amenity,
      name: 'prefixed',
      good: [
        'disused:shop=yes',
        'was:amenity=pharmacy',
        'construction:office=government',
        'disused:xmas:feature=market',
      ],
      bad: [
        'disused=shop',
        'construction=amenity',
      ],
    );
  });

  test('Recycling amenity', () {
    final m = ElementKind.amenity;
    expect(m.matchesTags({'amenity': 'recycling'}), isFalse);
    expect(m.matchesTags({'amenity': 'recycling', 'recycling': 'centre'}),
        isFalse);
    expect(
        m.matchesTags({'amenity': 'recycling', 'recycling_type': 'container'}),
        isFalse);
    expect(m.matchesTags({'amenity': 'recycling', 'recycling_type': 'centre'}),
        isTrue);
  });

  test('Tourism information amenity', () {
    final m = ElementKind.amenity;
    expect(m.matchesTags({'tourism': 'information'}), isFalse);
    expect(m.matchesTags({'tourism': 'information', 'information': 'map'}),
        isFalse);
    expect(m.matchesTags({'tourism': 'information', 'information': 'office'}),
        isTrue);
    expect(
        m.matchesTags(
            {'tourism': 'information', 'information': 'visitor_centre'}),
        isTrue);
  });

  test('Micromapping', () {
    testKinds(
      kind: ElementKind.micro,
      name: 'micro',
      good: [
        'amenity=bench',
        'tourism=viewpoint',
        'emergency=phone',
        'man_made=pier',
        'historic=ruins',
        'playground=swing',
        'advertising=billboard',
        'power=tower',
        'traffic_calming=hump',
        'barrier=lift_gate',
        'barrier=wall',
        'highway=primary',
        'highway=crossing',
        'railway=level_crossing',
        'natural=stone',
        'leisure=park',
        'marker=whatever',
        'public_transport=stop_position',
        'hazard=rain',
        'traffic_sign=give_way',
        'telecom=operator',
        'attraction=place',
        'cemetery=sector',
        'aeroway=forgot',
        'waterway=slide',
        'xmas:feature=tree',
      ],
      bad: [
        'shop=general',
        'shop=any',
        'tourism=hotel',
        'xmas:feature=market',
        'random=tag',
      ],
    );
  });

  test('Building', () {
    final m = ElementKind.building;
    expect(m.matchesTags({}), isFalse);
    expect(m.matchesTags({'building:part': 'yes'}), isFalse);
    expect(m.matchesTags({'shop': 'building'}), isFalse);
    expect(m.matchesTags({'building': 'yes'}), isTrue);
    expect(m.matchesTags({'building': 'roof'}), isTrue);
    expect(m.matchesTags({'building': 'yes', 'shop': 'toy'}), isTrue);
    expect(m.matchesTags({'building': 'yes', 'entrance': 'main'}), isTrue);
    expect(
        m.matchesTags({'building': 'entrance', 'entrance': 'main'}), isFalse);
    expect(m.matchesTags({'building': 'entrance'}), isFalse);
  });

  test('Entrances', () {
    final m = ElementKind.entrance;
    expect(m.matchesTags({}), isFalse);
    expect(m.matchesTags({'shop': 'entrance'}), isFalse);
    expect(m.matchesTags({'building': 'entrance'}), isTrue);
    expect(m.matchesTags({'building': 'not_entrance'}), isFalse);
    expect(m.matchesTags({'building': 'yes', 'entrance': 'main'}), isTrue);
    expect(m.matchesTags({'entrance': 'service'}), isTrue);
    expect(m.matchesTags({'entrance': 'service', 'amenity': 'bench'}), isTrue);
  });

  test('Addresses', () {
    final m = ElementKind.address;
    expect(m.matchesTags({}), isFalse);
    expect(m.matchesTags({'shop': 'address'}), isFalse);
    expect(m.matchesTags({'addr:street': 'Street'}), isFalse);
    expect(m.matchesTags({'addr:housenumber': '1A'}), isTrue);
    expect(m.matchesTags({'addr:housename': 'Name'}), isTrue);
    expect(m.matchesTags({'addr:housenumber': 'what', 'addr:place': 'Village'}),
        isTrue);
    expect(m.matchesTags({'addr:housenumber': 'what', 'office': 'it'}), isFalse,
        reason: 'Having a main key makes it another kind');
  });

  test('Empty', () {
    final m = ElementKind.empty;
    expect(m.matchesTags({}), isTrue);
    expect(m.matchesTags({'note': 'add tags'}), isTrue);
    expect(m.matchesTags({'source': 'JOSM'}), isTrue);
    expect(m.matchesTags({'note_source': 'JOSM'}), isFalse);
    expect(m.matchesTags({'amenity': 'bench', 'note': 'add tags'}), isFalse);
  });

  test('Structure', () {
    final m = ElementKind.structure;
    expect(m.matchesTags({}), isFalse);
    expect(m.matchesTags({'amenity': 'post_office'}), isFalse);
    expect(m.matchesTags({'random': 'tag'}), isFalse);
    expect(m.matchesTags({'amenity': 'school'}), isTrue);
    expect(m.matchesTags({'leisure': 'stadium'}), isTrue);
    expect(m.matchesTags({'leisure': 'stadium', 'shop': 'whatever'}), isFalse,
        reason: 'We check only the main tag, and "shop" takes precedence');
  });

  test('Needs more info', () {
    final m = ElementKind.get('needsInfo');
    expect(m.matchesTags({'amenity': 'pharmacy'}), isFalse);
    expect(m.matchesTags({'shop': 'gift'}), isFalse);
    expect(m.matchesTags({'natural': 'stone'}), isFalse);

    expect(m.matchesTags({'amenity': 'bench'}), isTrue);
    expect(m.matchesTags({'amenity': 'bench', 'backrest': 'yes'}), isTrue);
    expect(
        m.matchesTags(
            {'amenity': 'bench', 'backrest': 'yes', 'material': 'wood'}),
        isFalse);

    expect(m.matchesTags({'emergency': 'fire_hydrant'}), isTrue);
    expect(
        m.matchesTags(
            {'emergency': 'fire_hydrant', 'fire_hydrant:type': 'type'}),
        isFalse);

    expect(m.matchesTags({'amenity': 'recycling'}), isTrue);
    // "recycling:*" keys are not checked, hence a part of tests are disabled.
    expect(
        m.matchesTags({'amenity': 'recycling', 'recycling_type': 'container'}),
        isFalse);
    /*
    expect(m.matchesTags({'amenity': 'recycling', 'recycling:glass': 'yes'}),
        isTrue);
    expect(
        m.matchesTags({
          'amenity': 'recycling',
          'recycling_type': 'container',
          'recycling:glass': 'yes',
        }),
        isFalse);
    expect(
        m.matchesTags({
          'amenity': 'recycling',
          'recycling_type': 'container',
          'recycling:whatever': 'no',
        }),
        isFalse);
    */

    expect(m.matchesTags({'natural': 'tree'}), isTrue);
    expect(
        m.matchesTags({'natural': 'tree', 'leaf_type': 'dedicious'}), isTrue);
    expect(
        m.matchesTags({
          'natural': 'tree',
          'leaf_type': 'dedicious',
          'leaf_cycle': 'evergreen'
        }),
        isFalse);

    expect(m.matchesTags({'power': 'tower'}), isTrue);
    expect(m.matchesTags({'power': 'tower', 'ref': '12'}), isFalse);
  });
}
