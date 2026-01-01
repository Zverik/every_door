import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/poi_warnings.dart';
import 'package:every_door/models/amenity.dart';

/// This class contains age data for an amenity.
/// It is used for building a POI tile: the age flags control the checkmark
/// button, and the disused flag affects the tile style.
/// Use [from] to get the data from an [OsmChange] object, or fill directly.
@Bind()
class AmenityAgeData {
  /// Whether the object is "disused", that is, closed or obsolete.
  final bool isDisused;

  final bool showWarning;

  /// Whether the object is old and requires confirmation. Leave as null
  /// when the object does not need confirmation.
  final bool? isOld;

  /// Whether the original object before any modifications was old.
  /// If false, the checkmark button won't be tappable.
  final bool wasOld;

  AmenityAgeData({
    this.isDisused = false,
    this.showWarning = false,
    this.isOld,
    this.wasOld = false,
  });

  /// Get the information from [amenity].
  /// The [checkIntervals] maps [ElementKind] names to durations in days.
  /// It is expected to have at least the "amenity" key.
  static AmenityAgeData from(
      OsmChange amenity, Map<String, int> checkIntervals) {
    bool needsAge = ElementKind.needsCheck.matchesChange(amenity);
    final defaultAge = checkIntervals['amenity'] ??
        (checkIntervals.length == 1 ? checkIntervals.values.first : null);
    if (defaultAge == null) needsAge = false;

    bool isCountedOld(int age) {
      for (final entry in checkIntervals.entries) {
        if (entry.key != 'amenity' &&
            ElementKind.get(entry.key).matchesChange(amenity))
          return age >= entry.value;
      }
      return age >= (defaultAge ?? 0);
    }

    return AmenityAgeData(
      isDisused: amenity.isDisused,
      showWarning: getWarningForAmenity(amenity) != null,
      isOld: needsAge ? isCountedOld(amenity.age) : null,
      wasOld:
          needsAge ? !amenity.isNew && isCountedOld(amenity.baseAge) : false,
    );
  }
}
