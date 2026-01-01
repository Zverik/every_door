import 'package:latlong2/latlong.dart' show LatLng;
import 'package:eval_annotation/eval_annotation.dart';

/// Super-class for everything that can be displayed on the map.
/// Obviously, as the editor only supports points, this class contains
/// only the point location. Also has three service getters to learn
/// the state of the object. If not needed, it's safe to use default
/// values: true for [isNew] and false for everything else.
@Bind(wrap: true, bridge: true)
abstract class Located {
  /// The location of the object.
  LatLng get location;

  /// Unique id for usage as keys in various widgets.
  String get uniqueId;

  /// Whether this object has been created in the editor and not uploaded
  /// to the server yet.
  bool get isNew => true;

  /// Whether this object was modified in the editor. Should return true
  /// when [isNew] or [isDeleted] are true.
  bool get isModified => false;

  /// Whether this object is still present on a server, but was deleted
  /// in the editor. Also might mean setting a deleted flag on the server,
  /// so it's possible to have [isDeleted] true and [isModified] false.
  bool get isDeleted => false;
}