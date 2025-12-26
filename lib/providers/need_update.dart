// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final needMapUpdateProvider = ChangeNotifierProvider((_) => NeedMapUpdateNotifier());

/// Simple provider to notify the POI list that it needs to be updated.
class NeedMapUpdateNotifier extends ChangeNotifier {
  /// Calls notifyListeners().
  void trigger() {
    notifyListeners();
  }
}