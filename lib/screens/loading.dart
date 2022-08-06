import 'dart:async';

import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/browser.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_coder/country_coder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  String? message;
  static const kPrefLastSizeWarning = 'last_size_warning';

  Future doInit() async {
    final loc = AppLocalizations.of(context)!;

    // Start loading countries in a background thread.
    compute(CountryCoder.prepareData, null)
        .then((value) => CountryCoder.instance.load(value));

    // Load login name
    ref.read(authProvider);

    setState(() {
      message = loc.loadingPresets;
    });
    ref.read(presetProvider);

    // We need extra error handling for changes.
    setState(() {
      message = loc.loadingChanges;
    });
    String? error;
    try {
      await ref.read(changesProvider).loadChanges();
    } on Exception catch (e) {
      error = e.toString();
    } on Error catch (e) {
      error = e.toString();
    }
    if (error != null) {
      AlertController.show(loc.loadingChangesFailed, error, TypeAlert.error);
    }

    // Update floors in the background.
    ref.read(osmDataProvider).updateAddressesWithFloors();

    // Acquire user location.
    setState(() {
      message = loc.loadingLocation;
    });
    if (!mounted) return;
    await ref.read(geolocationProvider.notifier).enableTracking(context);
    LatLng? location = ref.read(geolocationProvider);
    if (location != null) {
      ref.read(effectiveLocationProvider.notifier).set(location);
    }

    // Alert if there are too many changes loaded.
    final needSizeAlert =
        ref.read(osmDataProvider).length >= kMinElementsForWarning;
    if (needSizeAlert) {
      final prefs = await SharedPreferences.getInstance();
      if (DateTime.now().day != prefs.getInt(kPrefLastSizeWarning)) {
        await prefs.setInt(kPrefLastSizeWarning, DateTime.now().day);
        AlertController.show(loc.loadingTooMuchDataTitle,
            loc.loadingTooMuchData, TypeAlert.warning);
      }
    }

    // Finally switch to the monitor page.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BrowserPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('$kAppTitle $kAppVersion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: null,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 40.0),
            Text(
              message ?? loc.loadingStart,
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
