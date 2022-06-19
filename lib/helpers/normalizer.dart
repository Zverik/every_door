import "package:unorm_dart/unorm_dart.dart" as unorm;

String normalizeString(String s) {
  var combining = RegExp(r"[\u0300-\u036F]");
  return unorm.nfkd(s.toLowerCase().trim()).replaceAll(combining, '');
}
