import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/screens/editor/types.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval wrapper binding for [TypeChooserPage]
class $TypeChooserPage implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/screens/editor/types.dart',
      'TypeChooserPage.',
      $TypeChooserPage.$new,
    );
  }

  /// Compile-time type specification of [$TypeChooserPage]
  static const $spec = BridgeTypeSpec(
    'package:every_door/screens/editor/types.dart',
    'TypeChooserPage',
  );

  /// Compile-time type declaration of [$TypeChooserPage]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$TypeChooserPage]
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
              'launchEditor',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
            BridgeParameter(
              'kinds',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:every_door/helpers/tags/element_kind.dart',
                    'ElementKindImpl',
                  ),
                  [],
                ),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'defaults',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
              true,
            ),
          ],
        ),
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [TypeChooserPage.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $TypeChooserPage.wrap(
      TypeChooserPage(
        location: args[0]?.$value,
        launchEditor: args[1]?.$value ?? true,
        kinds: args[2]?.$value,
        defaults: (args[3]?.$reified ?? const [] as List?)?.cast(),
      ),
    );
  }

  @override
  final TypeChooserPage $value;

  @override
  TypeChooserPage get $reified => $value;

  /// Wrap a [TypeChooserPage] in a [$TypeChooserPage]
  $TypeChooserPage.wrap(this.$value);

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
