import 'amenity.dart';

class Floor implements Comparable<Floor> {
  final double? level;
  final String? floor;
  final bool duplicate;

  const Floor({this.level, this.floor, this.duplicate = false});

  static const empty = Floor(level: null, floor: null);

  factory Floor.fromTags(Map<String, String> tags) {
    final levelValue = tags['level'];
    double? level = levelValue == null ? null : double.tryParse(levelValue);
    return Floor(level: level, floor: tags['addr:floor']);
  }

  Floor makeDuplicate() => Floor(level: level, floor: floor, duplicate: true);

  bool get isEmpty => level == null && floor == null;
  bool get isNotEmpty => !isEmpty;
  bool get isComplete => level != null && floor != null;

  String? get levelStr {
    if (level == null) return null;
    int intLevel = level!.truncate();
    return intLevel == level ? intLevel.toString() : level.toString();
  }

  setTags(OsmChange element) {
    if (isEmpty) return;
    element['level'] = levelStr;
    element['addr:floor'] = floor;
  }

  static clearTags(OsmChange element) {
    element.removeTag('level');
    element.removeTag('addr:floor');
  }

  @override
  bool operator ==(Object other) => other is Floor && level == other.level && floor == other.floor;

  @override
  int get hashCode => (level ?? -100.123).hashCode + (floor ?? '').hashCode;

  @override
  String toString() => 'Floor($floor/$level)';

  String get string => duplicate ? '$floor/$levelStr' : (floor != null ? floor! + (level == null ? '/' : '') : '/$levelStr');

  @override
  int compareTo(Floor other) {
    if (level != null && other.level != null)
      return level!.compareTo(other.level!);
    if (floor != null && other.floor != null) {
      final dFloor = double.tryParse(floor!);
      final odFloor = double.tryParse(other.floor!);
      if (dFloor != null && odFloor != null)
        return dFloor.compareTo(odFloor);
      return floor!.compareTo(other.floor!);
    }
    if (level != null) return -1;
    if (other.level != null) return 1;
    if (floor != null) return -1;
    if (other.floor != null) return 1;
    return 0;
  }

  /// Removes incomplete duplicates.
  static collapse(Set<Floor> floors) {
    final compLevels = floors.where((element) => element.isComplete).map((e) => e.level!).toSet();
    final compFloors = floors.where((element) => element.isComplete).map((e) => e.floor!).toSet();

    // Remove incomplete floors where a complete alternative exists.
    floors.removeWhere((floor) {
      if (!floor.isComplete) {
        if (floor.level != null && compLevels.contains(floor.level))
          return true;
        if (floor.floor != null && compFloors.contains(floor.floor))
          return true;
      }
      return false;
    });

    // Complete floors can contain duplicates on levels or floors.
    // TODO: replace these floors with .makeDuplicate()
  }

  static collapseList(List<Floor> floors) {
    final set = floors.toSet();
    collapse(set);
    final result = set.toList();
    result.sort();
    return result;
  }
}