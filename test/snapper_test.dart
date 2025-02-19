import 'package:every_door/models/osm_element.dart';
import 'package:test/test.dart';
import 'package:every_door/helpers/geometry/snap_nodes.dart';
import 'package:latlong2/latlong.dart' show LatLng;

OsmElement wayFromPoints(List<LatLng> points) {
  return OsmElement(
    id: OsmId(OsmElementType.way, 0),
    version: 1,
    tags: {},
    timestamp: DateTime.now(),
    nodes: List.generate(points.length, (index) => index),
    nodeLocations: points.asMap(),
  );
}

void main() {
  final snapper = Snapper();

  test('Simple case works', () {
    final a = LatLng(0.0, 0.0);
    final b = LatLng(1.0, 0.0);
    expect(snapper.testProject(LatLng(0.0, 0.0), a, b), equals(0.0));
    expect(snapper.testProject(LatLng(1.0, 0.0), a, b), equals(1.0));
    expect(snapper.testProject(LatLng(0.11, 0.0), a, b), equals(0.11));
    expect(snapper.testProject(LatLng(0.11, 10.0), a, b), equals(0.11));
    expect(snapper.testProject(LatLng(0.91, -9.0), a, b), equals(0.91));
    expect(snapper.testProject(LatLng(-10.0, 10.0), a, b), lessThan(0.0));
    expect(snapper.testProject(LatLng(10.0, -1.0), a, b), greaterThan(1.0));
  });

  test('Projects to segments correctly', () {
    final a = LatLng(1.0, 4.0);
    final b = LatLng(5.0, 1.0);
    double t = snapper.testProject(LatLng(0.0, 4.5), a, b);
    expect(t, lessThan(0.0));
    t = snapper.testProject(LatLng(0.0, 0.5), a, b);
    expect(t, inExclusiveRange(0.0, 1.0));
  });

  final way =
      wayFromPoints([LatLng(0.0, 0.0), LatLng(1.0, 0.0), LatLng(1.0, 2.0)]);
  test('We build ways properly', () {
    expect(way.nodes, equals([0, 1, 2]));
    expect(way.nodeLocations, isNotNull);
  });

  test('Calculates distance to way', () {
    expect(snapper.distanceToWay(LatLng(10.0, -5.0), way), greaterThan(100.0));
    expect(snapper.distanceToWay(LatLng(0.3, 0.0), way), equals(0.0));
    expect(snapper.distanceToWay(LatLng(1.00001, 1.0), way),
        inExclusiveRange(1.0, 2.0));
    // 0.00001 degrees is ~1.1 meters
  });
  test('Ignores distance to edges', () {
    expect(snapper.distanceToWay(LatLng(0.0, 0.0), way, noEdges: true), isNull);
    expect(snapper.distanceToWay(LatLng(1.01, -0.01), way, noEdges: true), isNull);
  });

  test('Does not match a way too far', () {
    expect(snapper.closestWay(LatLng(0.1, 1.0), [way]), isNull);
    expect(
        snapper.closestWay(LatLng(0.1, 0.001), [way], maxDistance: 50), isNull);
  });
  test('Does not match vertices', () {
    expect(snapper.closestWay(LatLng(1.0, 0.0), [way], noEdges: true), isNull);
    expect(snapper.closestWay(LatLng(1.0, 2.0), [way], noEdges: true), isNull);
  });
  test('Does not snap to vertices', () {
    expect(snapper.snap(-1, LatLng(1.0, 0.0), way), isNull);
  });
  test('Properly inserts a node', () {
    final r = snapper.snap(-1, LatLng(0.5, 0.0), way);
    expect(r, isNotNull);
    if (r == null) return;
    expect(r.newLocation, equals(LatLng(0.5, 0.0)));
    expect(r.newElement.nodes, equals([0, -1, 1, 2]));
    expect(r.newElement.nodeLocations, isNotNull);
    expect(r.newElement.nodeLocations, contains(-1));
    expect(r.newElement.nodeLocations![-1], equals(LatLng(0.5, 0.0)));
  });
  test('Projects and inserts a node', () {
    final r = snapper.snap(-1, LatLng(1.1, 1.1), way);
    expect(r, isNotNull);
    if (r == null) return;
    final loc = LatLng(1.0, 1.1);
    expect(r.newLocation, equals(loc));
    expect(r.newElement.nodes, equals([0, 1, -1, 2]));
    expect(r.newElement.nodeLocations![-1], equals(loc));
  });
}
