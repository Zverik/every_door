import 'dart:async';

import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/presets.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:every_door/constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/screens/poi_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_coder/country_coder.dart';

class LoadingPage extends ConsumerStatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  String? message;

  Future doInit() async {
    // Start loading countries in a background thread.
    compute(CountryCoder.prepareData, null)
        .then((value) => CountryCoder.instance.load(value));

    // Load login name
    ref.read(authProvider);

    setState(() {
      message = 'Loading presets';
    });
    ref.read(presetProvider);

    setState(() {
      message = 'Loading changes';
    });
    await ref.read(changesProvider).loadChanges();

    // Acquire user location.
    setState(() {
      message = 'Acquiring location';
    });
    await ref.read(geolocationProvider.notifier).enableTracking(context);
    LatLng? location = ref.read(geolocationProvider);

    // Finally switch to the monitor page.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PoiListPage(location: location)),
    );
  }

  @override
  void initState() {
    super.initState();
    doInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
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
              message ?? 'Initializing...',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
