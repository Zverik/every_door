import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [PoiEditorPage]
class $PoiEditorPage implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/screens/editor.dart',
      'PoiEditorPage.',
      $PoiEditorPage.$new,
    );
  }

  /// Compile-time type specification of [$PoiEditorPage]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/editor.dart',
    'PoiEditorPage',
  );

  /// Compile-time type declaration of [$PoiEditorPage]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PoiEditorPage]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, $extends: $StatefulWidget$bridge.$type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'amenity',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/amenity.dart',
                    'OsmChange',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'preset',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/models/preset.dart',
                    'Preset',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
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
              'isModified',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PoiEditorPage.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PoiEditorPage.wrap(
      PoiEditorPage(
        amenity: args[0]?.$value,
        preset: args[1]?.$value,
        location: args[2]?.$value,
        isModified: args[3]?.$value ?? false,
      ),
    );
  }

  @override
  final PoiEditorPage $value;

  @override
  PoiEditorPage get $reified => $value;

  /// Wrap a [PoiEditorPage] in a [$PoiEditorPage]
  $PoiEditorPage.wrap(this.$value);

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
