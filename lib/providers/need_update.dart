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