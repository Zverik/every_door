import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [MapChooserPage]
class $MapChooserPage implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/screens/editor/map_chooser.dart',
      'MapChooserPage.',
      $MapChooserPage.$new,
    );
  }

  /// Compile-time type specification of [$MapChooserPage]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/editor/map_chooser.dart',
    'MapChooserPage',
  );

  /// Compile-time type declaration of [$MapChooserPage]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MapChooserPage]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, $extends: $StatefulWidget$bridge.$type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'location',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:latlong2/latlong.dart', 'LatLng'),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'creating',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
        ),
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [MapChooserPage.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MapChooserPage.wrap(
      MapChooserPage(
        location: args[0]?.$value,
        creating: args[1]?.$value ?? false,
      ),
    );
  }

  @override
  final MapChooserPage $value;

  @override
  MapChooserPage get $reified => $value;

  /// Wrap a [MapChooserPage] in a [$MapChooserPage]
  $MapChooserPage.wrap(this.$value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    throw UnimplementedError();
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    throw UnimplementedError();
  }
}
