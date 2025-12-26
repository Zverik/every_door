// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import "package:unorm_dart/unorm_dart.dart" as unorm;

String normalizeString(String s) {
  var combining = RegExp(r"[\u0300-\u036F\u3099-\u309C]");
  return unorm.nfkd(s.toLowerCase().trim()).replaceAll(combining, '');
}
