import 'package:yaml/yaml.dart';

extension YamlMapConverter on YamlMap {
  dynamic _convertNode(YamlNode v) {
    if (v is YamlMap) {
      return v.toMap();
    } else if (v is YamlList) {
      return v.nodes.map((e) => _convertNode(e)).toList();
    } else if (v is YamlScalar) {
      return v.value;
    } else {
      return v;
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    nodes.forEach((k, v) {
      if (k is YamlScalar) {
        map[k.value.toString()] = _convertNode(v);
      }
    });
    return map;
  }
}
