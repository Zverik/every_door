import 'package:every_door/helpers/multi_icon.dart';
import 'package:every_door/providers/geolocation.dart';
import 'package:every_door/widgets/map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class TrackButton extends ConsumerWidget {
  const TrackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);
    final loc = AppLocalizations.of(context)!;

    return MapButton(
      enabled: !ref.watch(trackingProvider) && trackLocation != null,
      icon: MultiIcon(fontIcon: Icons.my_location),
      tooltip: loc.mapLocate,
      onPressed: (_) {
        ref.read(geolocationProvider.notifier).enableTracking(context);
      },
    );
  }
}
