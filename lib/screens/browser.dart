import 'package:every_door/constants.dart';
import 'package:every_door/helpers/circle_bounds.dart';
import 'package:every_door/helpers/lifecycle.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/area.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:every_door/screens/editor/map_chooser.dart';
import 'package:every_door/screens/settings.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:every_door/screens/modes/entrances.dart';
import 'package:every_door/widgets/filter.dart';
import 'package:every_door/screens/modes/poi_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage();

  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  late LifecycleEventHandler lifecycleObserver;
  AreaStatus areaStatus = AreaStatus.fresh;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
    WidgetsBinding.instance?.addObserver(lifecycleObserver);
  }

  @override
  dispose() {
    WidgetsBinding.instance?.removeObserver(lifecycleObserver);
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

  downloadAmenities(LatLng location) async {
    final provider = ref.read(osmDataProvider);
    await provider.downloadAround(location);
    updateAreaStatus();
    ref.read(needMapUpdateProvider).trigger();
  }

  uploadChanges(BuildContext context) async {
    if (ref.read(authProvider) == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OsmAccountPage()));
      return;
    }

    final loc = AppLocalizations.of(context)!;
    try {
      int count = await ref.read(osmApiProvider).uploadChanges(true);
      AlertController.show(
          loc.changesUploadedTitle,
          loc.changesUploadedMessage(loc.changesCount(count)),
          TypeAlert.success);
    } on Exception catch (e) {
      AlertController.show(
          loc.changesUploadFailedTitle, e.toString(), TypeAlert.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorMode = ref.watch(editorModeProvider);
    final apiStatus = ref.watch(apiStatusProvider);
    final hasChangesToUpload = ref.watch(changesProvider).haveNoErrorChanges();
    final hasFilter = ref.watch(poiFilterProvider).isNotEmpty;

    ref.listen(effectiveLocationProvider, (_, LatLng next) {
      updateAreaStatus();
    });

    final screenSize = MediaQuery.of(context).size;
    final isWide =
        screenSize.width > screenSize.height && screenSize.height < 600;

    Widget editorPanel;
    final statusPanel = buildAreaStatusBar(context);
    switch (editorMode) {
      case EditorMode.poi:
      case EditorMode.micromapping:
        editorPanel = PoiListPane(areaStatusPanel: statusPanel, isWide: isWide);
        break;
      case EditorMode.entrances:
        editorPanel = EntrancesPane(areaStatusPanel: statusPanel);
        break;
    }

    final leftHand = ref.watch(editorSettingsProvider).leftHand;
    final settingsButton = IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      },
      icon: Icon(Icons.menu),
    );
    final modeButton = IconButton(
      onPressed: () {
        ref.read(editorModeProvider.notifier).next();
      },
      icon: Icon(kEditorModeIcons[editorMode]!),
    );

    return WillPopScope(
      onWillPop: () async {
        if (ref.read(microZoomedInProvider) != null) {
          ref.read(microZoomedInProvider.state).state = null;
          return false;
        } else if (!ref.read(trackingProvider)) {
          ref.read(trackingProvider.state).state = true;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(kAppTitle, overflow: TextOverflow.fade),
          leading: leftHand ? modeButton : settingsButton,
          actions: [
            if (!hasChangesToUpload)
              IconButton(
                onPressed: apiStatus != ApiStatus.idle
                    ? null
                    : () {
                        final location = ref.read(effectiveLocationProvider);
                        downloadAmenities(location);
                      },
                icon: Icon(Icons.download),
              ),
            if (hasChangesToUpload)
              IconButton(
                onPressed: apiStatus != ApiStatus.idle
                    ? null
                    : () async {
                        uploadChanges(context);
                      },
                icon: Icon(Icons.upload, color: Colors.yellowAccent),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  ref.read(selectedImageryProvider.notifier).toggle();
                });
              },
              icon: Icon(ref.watch(selectedImageryProvider) == kOSMImagery
                  ? Icons.map_outlined
                  : Icons.map),
            ),
            if (editorMode == EditorMode.poi)
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        color: Colors.white,
                        height: 250.0,
                        padding: EdgeInsets.all(15.0),
                        child: PoiFilterPane(),
                      );
                    },
                  );
                },
                icon: Icon(
                  hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: hasFilter ? Colors.yellowAccent : null,
                ),
              ),
            !leftHand ? modeButton : settingsButton,
          ],
        ),
        body: editorPanel,
        floatingActionButton: editorMode == EditorMode.poi ||
                editorMode == EditorMode.micromapping
            ? FloatingActionButton(
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
          color: areaStatus == AreaStatus.missing
              ? Colors.redAccent
              : Colors.yellow,
          child: Center(
            child: Text(
              areaStatus == AreaStatus.missing
                  ? loc.messageNoData
                  : loc.messageDataObsolete,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: areaStatus == AreaStatus.missing
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
        onTap: () {
          downloadAmenities(ref.read(effectiveLocationProvider));
        },
      );
    return null;
  }
}
