import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_eval/widgets.dart' show $IconData;

class $Icons {
  static void _registerIcon(Runtime runtime, String name, IconData icon) {
    runtime.registerBridgeFunc(
      'package:flutter/src/material/icons.dart',
      '${name}add*g',
      (r, t, a) => $IconData.wrap(icon),
    );
  }

  static final _icons = {
    'add': Icons.add,
    'arrow_back': Icons.arrow_back,
    'check': Icons.check,
    'check_circle': Icons.check_circle,
    'clear': Icons.clear,
    'close': Icons.close,
    'copy': Icons.copy,
    'delete': Icons.delete,
    'delete_forever': Icons.delete_forever,
    'delete_outline': Icons.delete_outline,
    'done': Icons.done,
    'download': Icons.download,
    'edit': Icons.edit,
    'filter_alt': Icons.filter_alt,
    'filter_alt_outlined': Icons.filter_alt_outlined,
    'location_pin': Icons.location_pin,
    'lock': Icons.lock,
    'map': Icons.map,
    'menu': Icons.menu,
    'my_location': Icons.my_location,
    'navigate_next': Icons.navigate_next,
    'qr_code': Icons.qr_code,
    'remove': Icons.remove,
    'search': Icons.search,
    'share': Icons.share,
    'undo': Icons.undo,
    'upload': Icons.upload,
    'warning': Icons.warning,
  };

  static void configureForRuntime(Runtime runtime) {
    _icons.forEach((name, icon) => _registerIcon(runtime, name, icon));
  }

  static const $type = BridgeTypeRef(
      BridgeTypeSpec('package:flutter/src/material/icons.dart', 'Icons'));

  static const _stValueType = BridgeMethodDef(
      BridgeFunctionDef(returns: BridgeTypeAnnotation($IconData.$type)),
      isStatic: true);

  static final $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {},
    getters: {
      for (final e in _icons.entries)
        e.key: _stValueType,
    },
    wrap: true,
  );
}
