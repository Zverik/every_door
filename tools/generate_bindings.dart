import 'dart:convert';
import 'dart:io';

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/plugins/bindings/every_door_eval.dart';

void main() {
  // To properly generate the bindings, dart_eval needs Flutter context which is
  // delivered when running Dart programs via `flutter test`,
  // but isn't for Dart code ran via `dart run`.
  final serializer = BridgeSerializer();
  serializer.addPlugin(EveryDoorPlugin());
  final output = serializer.serialize();
  File('every_door_eval.json').writeAsStringSync(json.encode(output));
}
