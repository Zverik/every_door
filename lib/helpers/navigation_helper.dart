import 'package:every_door/screens/browser.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static Widget navigateByUri(Uri uri) {
    if (uri.scheme == 'geo' && uri.path.isNotEmpty) {
      return BrowserPage();
    }
    return BrowserPage();
  }
}
