import 'package:every_door/constants.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/lifecycle.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/notes.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/modes/entrances.dart';
import 'package:every_door/screens/modes/navigate.dart';
import 'package:every_door/screens/modes/notes.dart';
import 'package:every_door/screens/modes/poi_list.dart';
import 'package:every_door/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage();

  @override
  ConsumerState createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  late LifecycleEventHandler lifecycleObserver;
  AreaStatus areaStatus = AreaStatus.fresh;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateAreaStatus();
    });

    lifecycleObserver = LifecycleEventHandler(
      detached: () async {
        try {
          if (kUploadOnClose) {
            final provider = ref.read(osmApiProvider);
            await provider.uploadChanges();
          }
        } on Exception {
          // No point in catching anything.
        }
      },
    );
    WidgetsBinding.instance.addObserver(lifecycleObserver);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    super.dispose();
  }

  updateAreaStatus() async {
    final area = ref.read(downloadedAreaProvider);
    final location = ref.read(effectiveLocationProvider);
    final bbox = boundsFromRadius(location, kVisibilityRadius);
    final status = await area.getAreaStatus(bbox);
    if (status != areaStatus) {
      setState(() {
        areaStatus = status;
      });
    }
  }

  downloadAmenities(BuildContext context) async {
    final location = ref.read(effectiveLocationProvider);
    final provider = ref.read(osmDataProvider);
    final loc = AppLocalizations.of(context)!;

    try {
      final count = await provider.downloadAround(location);
      AlertController.show(loc.dataDownloadSuccessful, loc.dataDownloadedCount(count), TypeAlert.success);
    } on Exception catch (e) {
      AlertController.show(loc.dataDownloadFailed, e.toString(), TypeAlert.error);
      return;
    }
    ref.read(presetProvider).clearFieldCache();
    ref.read(presetProvider).cacheComboOptions();

    try {
      await ref.read(notesProvider).downloadNotes(location);
    } on Exception catch (e) {
      // TODO: message about notes
      AlertController.show(loc.dataDownloadFailed, e.toString(), TypeAlert.error);
    }
    updateAreaStatus();
    ref.read(needMapUpdateProvider).trigger();
  }

  @override
  Widget build(BuildContext context) {
    final editorMode = ref.watch(editorModeProvider);
    final isNavigation = ref.watch(navigationModeProvider);

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      updateAreaStatus();
    });

    ref.listen(editorModeProvider, (_, next) {
      ref.read(microZoomedInProvider.state).state = null;
    });

    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 600;

    Widget editorPanel;
    final statusPanel = buildAreaStatusBar(context);
    if (isNavigation) {
      editorPanel = NavigationPane();
    } else {
      switch (editorMode) {
        case EditorMode.poi:
        case EditorMode.micromapping:
          editorPanel = PoiListPane(areaStatusPanel: statusPanel, isWide: isWide);
          break;
        case EditorMode.entrances:
          editorPanel = EntrancesPane(areaStatusPanel: statusPanel);
          break;
        case EditorMode.notes:
          editorPanel = NotesPane(areaStatusPanel: statusPanel);
          break;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (ref.read(microZoomedInProvider) != null) {
          ref.read(microZoomedInProvider.state).state = null;
          return false;
        } else if (!ref.read(trackingProvider) && ref.read(geolocationProvider) != null) {
          ref.read(trackingProvider.state).state = true;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: editorPanel),
            BrowserNavigationBar(downloadAmenities: downloadAmenities),
          ],
        ),
        floatingActionButton: !isNavigation && (editorMode == EditorMode.poi || editorMode == EditorMode.micromapping)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    ref.read(microZoomedInProvider.state).state = null;
                    final location = ref.read(effectiveLocationProvider);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapChooserPage(
                          creating: true,
                          location: location,
                          closer: editorMode == EditorMode.micromapping,
                        ),
                      ),
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget? buildAreaStatusBar(BuildContext context) {
    final apiStatus = ref.watch(apiStatusProvider);
    final loc = AppLocalizations.of(context)!;
    if (areaStatus != AreaStatus.fresh && apiStatus == ApiStatus.idle)
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          height: 50.0,
          color: areaStatus == AreaStatus.missing ? Colors.redAccent : Colors.yellow,
          child: Center(
            child: Text(
              areaStatus == AreaStatus.missing ? loc.messageNoData : loc.messageDataObsolete,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: areaStatus == AreaStatus.missing ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        onTap: () {
          downloadAmenities(context);
        },
      );
    return null;
  }
}
