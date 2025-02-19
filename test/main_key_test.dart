import 'package:every_door/helpers/tags/main_key.dart';
import 'package:test/test.dart';

void main() {
  test('Finds plain main key according to the order', () {
    expect(getMainKey({'amenity': 'whatever'}), equals('amenity'));
    expect(getMainKey({'xmas:feature': 'tree'}), equals('xmas:feature'));
    expect(
        getMainKey({'leisure': 'tree', 'tourism': 'hotel'}), equals('tourism'));
    expect(getMainKey({'building': 'yes', 'entrance': 'main'}),
        equals('building'));
  });

  test('Find prefixed main key', () {
    expect(getMainKey({'disused:amenity': 'bench'}), equals('disused:amenity'));
    expect(getMainKey({'was:amenity': 'bench'}), equals('was:amenity'));
    expect(getMainKey({'demolished:building': 'yes'}),
        equals('demolished:building'));
  });

  test('Supports all lifecycle prefixes', () {
    expect(getMainKey({'construction:building': 'yes'}),
        equals('construction:building'));
    expect(getMainKey({'planned:shop': 'shoes'}), equals('planned:shop'));
    expect(getMainKey({'ruins:building': 'train_station'}),
        equals('ruins:building'));
    expect(getMainKey({'removed:xmas:feature': 'tree'}),
        equals('removed:xmas:feature'));
  });

  test('Prefers prefixes amenities to non-amenities', () {
    expect(getMainKey({'disused:shop': 'gift', 'was:craft': 'tailor'}),
        equals('disused:shop'));
    expect(getMainKey({'disused:shop': 'gift', 'highway': 'crossing'}),
        equals('disused:shop'));
    expect(getMainKey({'disused:shop': 'gift', 'office': 'government'}),
        equals('office'));
    expect(getMainKey({'shop': 'gift', 'disused:office': 'government'}),
        equals('shop'));
    expect(getMainKey({'disused:highway': 'road', 'waterway': 'pier'}),
        equals('waterway'));
    expect(getMainKey({'disused:highway': 'road', 'disused:waterway': 'pier'}),
        equals('disused:highway'));
  });

  test('Doesn\'t take "no" for a tag', () {
    expect(getMainKey({'shop': 'yes'}), equals('shop'));
    expect(getMainKey({'shop': 'no'}), isNull);
    expect(getMainKey({'shop': 'yes', 'office': 'it'}), equals('shop'));
    expect(getMainKey({'shop': 'no', 'office': 'it'}), equals('office'));
    expect(getMainKey({'disused:shop': 'yes', 'natural': 'tree'}),
        equals('disused:shop'));
    expect(getMainKey({'disused:shop': 'no', 'natural': 'tree'}),
        equals('natural'));
  });

  test('Clears prefixes correctly', () {
    expect(clearPrefix('shop'), equals('shop'));
    expect(clearPrefix('was:shop'), equals('shop'));
    expect(clearPrefix('disused:shop'), equals('shop'));
    expect(clearPrefix('construction:shop'), equals('shop'));
    expect(clearPrefix('demolished:building'), equals('building'));
    expect(clearPrefix('xmas:feature'), equals('xmas:feature'));
    expect(clearPrefix('disused:xmas:feature'), equals('xmas:feature'));
    expect(clearPrefix('camera:mount'), equals('camera:mount'));
    expect(clearPrefixNull(null), isNull);
    expect(clearPrefixNull('was:shop'), equals('shop'));
  });
}
