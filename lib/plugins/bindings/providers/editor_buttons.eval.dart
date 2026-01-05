import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/providers/editor_buttons.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/plugins/bindings/models/amenity.eval.dart';
import 'package:flutter_eval/widgets.dart';

/// dart_eval bridge binding for [EditorButton]
class $EditorButton$bridge extends EditorButton with $Bridge<EditorButton> {
  /// Forwarded constructor for [EditorButton.new]
  $EditorButton$bridge();

  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$EditorButton$bridge]
  static const $spec = BridgeTypeSpec(
    'package:every_door/providers/editor_buttons.dart',
    'EditorButton',
  );

  /// Compile-time type declaration of [$EditorButton$bridge]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$EditorButton]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'shouldDisplay': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
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
              ),
              false,
            ),
          ],
        ),
      ),

      'build': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:flutter/src/material/material_button.dart',
                'MaterialButton',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
                  ),
                  [],
                ),
              ),
              false,
            ),

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
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: false,
    bridge: true,
  );

  @override
  $Value? $bridgeGet(String identifier) {
    return null;
  }

  @override
  void $bridgeSet(String identifier, $Value value) {}

  @override
  bool shouldDisplay(OsmChange amenity) =>
      $_invoke('shouldDisplay', [$OsmChange.wrap(amenity)]);

  @override
  MaterialButton build(BuildContext context, OsmChange amenity) => $_invoke(
    'build',
    [$BuildContext.wrap(context), $OsmChange.wrap(amenity)],
  );
}
