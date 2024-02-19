import 'package:every_door/constants.dart';
import 'package:every_door/helpers/pin_marker.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/providers/location.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/widgets/attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddrChooserPage extends ConsumerStatefulWidget {
  final LatLng location;
  final bool creating;

  const AddrChooserPage({required this.location, this.creating = false});

  @override
  ConsumerState createState() => _AddrChooserPageState();
}

class _AddrChooserPageState extends ConsumerState<AddrChooserPage> {
  List<StreetAddress> addresses = [];

  @override
  void initState() {
    super.initState();
    findNearestAddresses();
  }

  findNearestAddresses() async {
    final provider = ref.read(osmDataProvider);
    List<StreetAddress> data = await provider.getAddressesAround(
      widget.location,
      limit: 15,
      includeAmenities: false,
    );
    setState(() {
      addresses = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final imagery = ref.watch(selectedImageryProvider);
    final tileLayer = TileLayerOptions(imagery);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.fieldAddressTap),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                ref.read(selectedImageryProvider.notifier).toggle();
              });
            },
            icon: Icon(imagery == kOSMImagery ? Icons.map_outlined : Icons.map),
            tooltip: loc.navImagery,
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.location,
          initialZoom: 18.0,
          minZoom: 17.0,
          maxZoom: 20.0,
          initialRotation: ref.watch(rotationProvider),
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            rotationThreshold: kRotationThreshold,
          ),
        ),
        children: [
          AttributionWidget(imagery),
          TileLayer(
            urlTemplate: tileLayer.urlTemplate,
            wmsOptions: tileLayer.wmsOptions,
            tileProvider: tileLayer.tileProvider,
            minNativeZoom: tileLayer.minNativeZoom,
            maxNativeZoom: tileLayer.maxNativeZoom,
            maxZoom: tileLayer.maxZoom,
            tileSize: tileLayer.tileSize,
            tms: tileLayer.tms,
            subdomains: tileLayer.subdomains,
            additionalOptions: tileLayer.additionalOptions,
            userAgentPackageName: tileLayer.userAgentPackageName,
            reset: tileResetController.stream,
          ),
          MarkerLayer(
            markers: [
              PinMarker(widget.location),
              for (final addr in addresses)
                Marker(
                    point: addr.location ?? LatLng(0.0, 0.0),
                    rotate: true,
                    width: 100.0,
                    height: 50.0,
                    child: GestureDetector(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white.withOpacity(0.7),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0,
                          ),
                          child: Text(
                            addr.housenumber ?? addr.housename ?? '?',
                            style: kFieldTextStyle,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, addr);
                      },
                    )),
            ],
          ),
        ],
      ),
    );
  }
}
