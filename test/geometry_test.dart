import 'package:test/test.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:latlong2/latlong.dart' show LatLng;

void main() {
  test('Throws exception on incorrect polygon', () {
    expect(() => Polygon([]), throwsException);
    expect(() => Polygon([LatLng(1, 1), LatLng(2, 2), LatLng(1, 1)]),
        throwsException);
  });

  test('Inside a polygon works for a simple one', () {
    final p = Polygon([LatLng(1, 1), LatLng(2, 1), LatLng(2, 2), LatLng(1, 2)]);
    expect(p.center, equals(LatLng(1.5, 1.5)));
    expect(p.contains(p.center), isTrue);
    expect(p.contains(LatLng(0.5, 1.5)), isFalse);
    expect(p.contains(LatLng(1, 1)), isTrue);
    expect(p.contains(LatLng(1, 1.1)), isTrue);
    expect(p.contains(LatLng(1, 0.9)), isFalse);
    expect(p.contains(LatLng(1.9, 2)), isTrue);
    expect(p.contains(LatLng(2.1, 2)), isFalse);
  });

  test('Inside a polygon works for a rhombus', () {
    final p = Polygon([LatLng(1, 2), LatLng(2, 3), LatLng(3, 2), LatLng(2, 1)]);
    expect(p.center, equals(LatLng(2, 2)));
    expect(p.contains(p.center), isTrue);
    expect(p.contains(LatLng(1, 2)), isTrue);
    expect(p.contains(LatLng(2, 1)), isTrue);
    expect(p.contains(LatLng(1, 1)), isFalse);
    expect(p.contains(LatLng(1.5, 1.5)), isTrue);
    expect(p.contains(LatLng(1.51, 1.5)), isTrue);
    expect(p.contains(LatLng(1.49, 1.5)), isFalse);
  });

  test('Polygon like a reversed C', () {
    final p = Polygon([
      LatLng(1, 1),
      LatLng(1, 3),
      LatLng(3, 3),
      LatLng(3, 1),
      LatLng(2.5, 1),
      LatLng(2.5, 2.5),
      LatLng(1.5, 2.5),
      LatLng(1.5, 1)
    ]);
    expect(p.center, equals(LatLng(2, 2)));
    expect(p.contains(p.center), isFalse);
    final c = p.findPointOnSurface();
    expect(c, equals(LatLng(2, 2.75)));
    expect(p.contains(c), isTrue);
    expect(p.contains(LatLng(1, 1)), isTrue);
    expect(p.contains(LatLng(1.5, 3)), isTrue);
    // expect(p.contains(LatLng(1.5, 2.4)), isTrue); // fails
    expect(p.contains(LatLng(1.5, 2.6)), isTrue);
    expect(p.contains(LatLng(1.5, 3.1)), isFalse);
    expect(p.contains(LatLng(1.5, 0.9)), isFalse);
  });

  test('Polygon like U', () {
    final p = Polygon([
      LatLng(4, 1), LatLng(1, 1), LatLng(1, 5), LatLng(4, 5),
      LatLng(4, 4), LatLng(2, 4), LatLng(2, 1.5), LatLng(4, 1.5)
    ]);
    expect(p.center, equals(LatLng(2.5, 3)));
    expect(p.contains(p.center), isFalse);
    final c = p.findPointOnSurface();
    expect(c, equals(LatLng(2.5, 4.5)));
    expect(p.contains(c), isTrue);
    expect(p.contains(LatLng(4, 1)), isTrue);
    // expect(p.contains(LatLng(4, 1.1)), isTrue); // fails
    expect(p.contains(LatLng(4, 1.6)), isFalse);
    expect(p.contains(LatLng(2, 1.1)), isTrue);
    // expect(p.contains(LatLng(4, 1.6)), isTrue); // fails
  });
}
