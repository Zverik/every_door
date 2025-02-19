import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/screens/modes/amenity.dart';
import 'package:every_door/screens/modes/definitions/amenity.dart';
import 'package:every_door/screens/modes/definitions/entrances.dart';
import 'package:every_door/screens/modes/definitions/micro.dart';
import 'package:every_door/screens/modes/definitions/notes.dart';
import 'package:every_door/screens/modes/entrances.dart';
import 'package:every_door/screens/modes/micro.dart';
import 'package:every_door/screens/modes/navigate.dart';
import 'package:every_door/screens/modes/notes.dart';
import 'package:every_door/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage();

  @override
  ConsumerState createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  bool _canPopScope(bool updateProviders) {
    if (ref.read(microZoomedInProvider) != null) {
      if (updateProviders) {
        ref.read(microZoomedInProvider.notifier).state = null;
      }
      return false;
    } else if (!ref.read(trackingProvider) &&
        ref.read(geolocationProvider) != null) {
      if (updateProviders) {
        ref.read(trackingProvider.notifier).state = true;
      }
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorMode = ref.watch(editorModeProvider);
    final isNavigation = ref.watch(navigationModeProvider);

    ref.listen(editorModeProvider, (_, next) {
      ref.read(microZoomedInProvider.notifier).state = null;
    });

    // Now we have to listen to both providers to change the pop state.
    ref.listen(microZoomedInProvider, (_, next) {
      setState(() {});
    });
    ref.listen(trackingProvider, (_, next) {
      setState(() {});
    });

    Widget editorPanel;
    if (isNavigation) {
      editorPanel = NavigationPane();
    } else if (editorMode is AmenityModeDefinition ) {
      editorPanel = AmenityPane(editorMode);
    } else if (editorMode is MicromappingModeDefinition ) {
      editorPanel = MicromappingPane(editorMode);
    } else if (editorMode is EntrancesModeDefinition) {
      editorPanel = EntrancesPane(editorMode);
    } else if (editorMode is NotesModeDefinition) {
      editorPanel = NotesPane(editorMode);
    } else {
      editorPanel = Container();
    }

    return PopScope(
      canPop: _canPopScope(false),
      onPopInvokedWithResult: (didPop, Object? result) {
        if (!didPop) {
          setState(() {
            _canPopScope(true);
          });
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: editorPanel),
            BrowserNavigationBar(),
          ],
        ),
      ),
    );
  }
}
