import 'package:flutter/material.dart';

typedef FutureVoidCallback = Future<void> Function();

class LifecycleEventHandler extends WidgetsBindingObserver {
  final FutureVoidCallback? detached;
  final FutureVoidCallback? resumed;
  bool isActive = true;

  LifecycleEventHandler({this.detached, this.resumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumed != null && !isActive)
          await resumed!();
        isActive = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (detached != null && isActive)
          await detached!();
        isActive = false;
        break;
    }
  }
}