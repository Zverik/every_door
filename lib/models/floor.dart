import 'amenity.dart';

/// Depicts a floor on which an object is located. Built from two values:
/// a numeric [level] (from level=* tag, starts from 0), and a textual
/// [floor] (from addr:floor=*, a human-understandable value).
///
/// You might want to use [MultiFloor] to manage floor tags.
class Floor implements Comparable<Floor> {
  final double? level;
  final String? floor;
  final bool duplicate;

  const Floor({this.level, this.floor, this.duplicate = false});

  static const empty = Floor(level: null, floor: null);

  Floor makeDuplicate() => Floor(level: level, floor: floor, duplicate: true);

  bool get isEmpty => level == null && floor == null;
  bool get isNotEmpty => !isEmpty;
  bool get isComplete => level != null && floor != null;

  @override
  bool operator ==(Object other) =>
      other is Floor && level == other.level && floor == other.floor;

  @override
  int get hashCode => Object.hash(level ?? -100.123, floor ?? '');

  @override
  String toString() => 'Floor($floor/$level)';

  String get _levelStr {
    if (level == null) return '';
    int intLevel = level!.truncate();
    return intLevel == level ? intLevel.toString() : level.toString();
  }

  String get string {
    if (isEmpty) return '';
    if (duplicate) return '${floor ?? ""}/$_levelStr';
    return floor != null ? floor! + (level == null ? '/' : '') : '/$_levelStr';
  }

  @override
  int compareTo(Floor other) {
    if (level != null && other.level != null)
      return level!.compareTo(other.level!);
    if (floor != null && other.floor != null) {
      final dFloor = double.tryParse(floor!);
      final odFloor = double.tryParse(other.floor!);
      if (dFloor != null && odFloor != null) return dFloor.compareTo(odFloor);
      return floor!.compareTo(other.floor!);
    }
    if (level != null) return -1;
    if (other.level != null) return 1;
    if (floor != null) return -1;
    if (other.floor != null) return 1;
    return 0;
  }

  /// Removes incomplete duplicates.
  static void collapse(Set<Floor> floors) {
    final compLevels = floors
        .where((element) => element.isComplete)
        .map((e) => e.level!)
        .toSet();
    final compFloors = floors
        .where((element) => element.isComplete)
        .map((e) => e.floor!)
        .toSet();

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

  static List<Floor> collapseList(Iterable<Floor> floors) {
    final set = floors.toSet();
    collapse(set);
    final result = set.toList();
    result.sort();
    return result;
  }
}

/// A class to manage a list of floors as denoted by tags on an object.
/// Use this class to parse and apply floor tags, instead of a single [Floor]
/// instance.
class MultiFloor {
  List<Floor> floors;

  MultiFloor(this.floors);

  bool get isEmpty => floors.isEmpty;
  bool get isNotEmpty => floors.isNotEmpty;
  List<String> get strings => floors.map((f) => f.string).toList();

  factory MultiFloor.fromTags(Map<String, String> tags) {
    final levelValue = tags['level'];
    final List<double?> levelParts = levelValue == null
        ? []
        : levelValue.split(';').map((s) => double.tryParse(s.trim())).toList();

    final floorValue = tags['addr:floor'];
    final List<String?> floorParts = floorValue == null
        ? []
        : List<String?>.from(floorValue.split(';').map((v) => v.trim()));
    for (int i = 0; i < floorParts.length; i++)
      if (floorParts[i]?.isEmpty ?? false) floorParts[i] = null;

    final count = levelParts.isNotEmpty ? levelParts.length : floorParts.length;
    if (count == 0) return MultiFloor([]);

    return MultiFloor(Iterable.generate(
      count,
      (i) => Floor(
        level: i >= levelParts.length ? null : levelParts[i],
        floor: i >= floorParts.length ? null : floorParts[i],
      ),
    ).where((element) => element.isNotEmpty).toList());
  }

  static final _kTailSemicolons = RegExp(r';+$');

  void setTags(OsmChange element) {
    if (floors.isEmpty) {
      element.removeTag('level');
      element.removeTag('addr:floor');
    } else {
      floors.sort();
      element['level'] = floors
          .map((f) => f._levelStr)
          .join(';')
          .replaceFirst(_kTailSemicolons, '');
      element['addr:floor'] = floors
          .map((f) => f.floor ?? '')
          .join(';')
          .replaceFirst(_kTailSemicolons, '');
    }
  }
}
