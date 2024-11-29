import 'dart:async';
import 'dart:io';

import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/presets.dart';
import 'package:every_door/screens/browser.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_coder/country_coder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  static final _logger = Logger('LoadingPageState');
  String? message;
  static const kPrefLastSizeWarning = 'last_size_warning';

  // https://en.wikipedia.org/wiki/Geo_URI_scheme
  parseGeoLocation(String geo) {
    if (!geo.startsWith("geo:")) return null;
    final geoSplit = geo.split("geo:");
    if (geoSplit.length != 2) return null;
    final semicolonSplit = geoSplit[1].split(";");
    final questionMarkSplit = semicolonSplit[0].split("?");
    final latLonSplit = questionMarkSplit[0].split(",");
    try {
      final lat = double.parse(latLonSplit[0]);
      final lon = double.parse(latLonSplit[1]);
      return LatLng(lat, lon);
    } catch (e) {
      _logger.severe("Couldn't parseGeoLocation: " + questionMarkSplit[0] + "\n" + e.toString());
      return null;
    }
  }

  Future setLocationFromAndroidIntent() async {
    const intentLocationChannel = MethodChannel('info.zverev.ilya.every_door/location');
    try {
      final result = await intentLocationChannel.invokeMethod<String>('getLocationFromIntent');
      if (result != null) {
        final parsedLocation = parseGeoLocation(result);
        if (parsedLocation != null) {
          ref.read(effectiveLocationProvider.notifier).set(parsedLocation);
          return true;
        }
      }
    } on PlatformException catch (e) {
      _logger.severe("Failed calling getLocationFromIntent: " + e.toString());
    }
    return false;
  }

  Future acquireUserLocation(AppLocalizations loc) async {
    setState(() {
      message = loc.loadingLocation;
    });
    if (!mounted) return;
    await ref.read(geolocationProvider.notifier).enableTracking(context);
    LatLng? location = ref.read(geolocationProvider);
    if (location != null) {
      ref.read(effectiveLocationProvider.notifier).set(location);
    }
  }

  Future doInit() async {
    final loc = AppLocalizations.of(context)!;

    // Start loading countries in a background thread.
    compute(CountryCoder.prepareData, null)
        .then((value) => CountryCoder.instance.load(value));

    // Load login name.
    ref.read(authProvider);

    // Load changeset hashtags.
    ref.read(changesetTagsProvider);

    // Initialize Bing imagery.
    ref.read(imageryProvider);

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

    if (Platform.isAndroid) {
      final success = await setLocationFromAndroidIntent();
      if (!success) {
        await acquireUserLocation(loc);
      }
    } else {
      await acquireUserLocation(loc);
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
