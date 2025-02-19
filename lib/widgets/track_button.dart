import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackButton extends ConsumerWidget {
  const TrackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    final loc = AppLocalizations.of(context)!;

    return MapButton(
      enabled: !ref.watch(trackingProvider) && trackLocation != null,
      icon: Icons.my_location,
      tooltip: loc.mapLocate,
      onPressed: () {
        ref.read(geolocationProvider.notifier).enableTracking(context);
      },
      onLongPressed: () {
        if (ref.read(rotationProvider) != 0.0) {
          ref.read(rotationProvider.notifier).state = 0.0;
          MapController.of(context).rotate(0.0);
        } else {
          ref.read(geolocationProvider.notifier).enableTracking(context);
        }
      },
    );
  }
}
