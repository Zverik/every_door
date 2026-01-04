import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/floor.dart';
import 'package:test/test.dart';
import 'package:latlong2/latlong.dart' show LatLng;

void main() {
  test('Floors make readable string representations', () {
    expect(Floor(level: null, floor: null).string, equals(''));
    expect(Floor(level: null, floor: '1').string, equals('1/'));
    expect(Floor(level: 0, floor: null).string, equals('/0'));
    expect(Floor(level: 0, floor: '1').string, equals('1'));
    expect(Floor(level: null, floor: '1', duplicate: true).string, equals('1/'));
    expect(Floor(level: 0, floor: null, duplicate: true).string, equals('/0'));
    expect(Floor(level: 0, floor: '1', duplicate: true).string, equals('1/0'));
  });

  test('Single floors parse okay', () {
    expect(MultiFloor.fromTags({}), isEmpty);

    MultiFloor m = MultiFloor.fromTags({'level': '0'});
    expect(m.floors.length, equals(1));
    expect(m.floors.first, equals(Floor(level: 0, floor: null)));

    m = MultiFloor.fromTags({'addr:floor': '1'});
    expect(m.floors.length, equals(1));
    expect(m.floors.first, equals(Floor(level: null, floor: '1')));

    m = MultiFloor.fromTags({'level': '2', 'addr:floor': '3'});
    expect(m.floors.length, equals(1));
    expect(m.floors.first, equals(Floor(level: 2, floor: '3')));
  });

  test('Multiple floors parse okay', () {
    expect(MultiFloor.fromTags({'level': '0;1'}).floors,
        equals([Floor(level: 0, floor: null), Floor(level: 1, floor: null)]));
    expect(MultiFloor.fromTags({'addr:floor': 'G;1'}).floors,
        equals([Floor(level: null, floor: 'G'), Floor(level: null, floor: '1')]));
    expect(MultiFloor.fromTags({'level': '1;2', 'addr:floor': '2;3'}).floors,
        equals([Floor(level: 1, floor: '2'), Floor(level: 2, floor: '3')]));

    expect(MultiFloor.fromTags({'level': '1;2', 'addr:floor': '2'}).floors,
        equals([Floor(level: 1, floor: '2'), Floor(level: 2, floor: null)]));
    expect(MultiFloor.fromTags({'level': '1;2', 'addr:floor': '2;3;4'}).floors,
        equals([Floor(level: 1, floor: '2'), Floor(level: 2, floor: '3')]));
    expect(MultiFloor.fromTags({'level': '1', 'addr:floor': '2;3'}).floors,
        equals([Floor(level: 1, floor: '2')]));

    expect(MultiFloor.fromTags({'level': '1', 'addr:floor': ';'}).floors,
        equals([Floor(level: 1, floor: null)]));
    expect(MultiFloor.fromTags({'level': '1;', 'addr:floor': '2;3'}).floors,
        equals([Floor(level: 1, floor: '2'), Floor(level: null, floor: '3')]));
    expect(MultiFloor.fromTags({'level': '1;', 'addr:floor': '2;;3'}).floors,
        equals([Floor(level: 1, floor: '2')]));
    expect(MultiFloor.fromTags({'level': '1;;2', 'addr:floor': '2;;3'}).floors,
        equals([Floor(level: 1, floor: '2'), Floor(level: 2, floor: '3')]));
    expect(MultiFloor.fromTags({'level': ';', 'addr:floor': '2;3'}).floors,
        equals([Floor(level: null, floor: '2'), Floor(level: null, floor: '3')]));
  });

  test('Floors render okay', () {
    final kDefault = LatLng(1.0, 1.0);

    final tags1 = {'level': '1;2', 'addr:floor': '2;3'};
    final el1 = OsmChange.create(tags: {}, location: kDefault, source: 'osm');
    MultiFloor.fromTags(tags1).setTags(el1);
    expect(el1.getFullTags(), equals(tags1));

    final tags2 = {'level': '1;2'};
    final el2 = OsmChange.create(tags: {}, location: kDefault, source: 'osm');
    MultiFloor.fromTags(tags2).setTags(el2);
    expect(el2.getFullTags(), equals(tags2));

    final tags3 = {'addr:floor': 'G;1'};
    final el3 = OsmChange.create(tags: {}, location: kDefault, source: 'osm');
    MultiFloor.fromTags(tags3).setTags(el3);
    // Sorting breaks this order.
    expect(el3.getFullTags(), equals({'addr:floor': '1;G'}));
  });
}
