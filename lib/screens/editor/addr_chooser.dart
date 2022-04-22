import 'package:every_door/constants.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:every_door/helpers/tile_layers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddrChooserPage extends ConsumerStatefulWidget {
  final LatLng location;
  final bool creating;

  const AddrChooserPage({required this.location, this.creating = false});

  @override
  _AddrChooserPageState createState() => _AddrChooserPageState();
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
      limit: 5,
      includeAmenities: false,
    );
    setState(() {
      addresses = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(selectedImageryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tap an address'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                ref.read(selectedImageryProvider.notifier).toggle();
              });
            },
            icon: Icon(imagery == kOSMImagery ? Icons.map_outlined : Icons.map),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: widget.location,
          zoom: 18.0,
          minZoom: 17.0,
          maxZoom: 20.0,
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
        children: [
          TileLayerWidget(
            options: buildTileLayerOptions(imagery),
          ),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                Marker(
                  point: widget.location,
                  anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                  builder: (ctx) => Icon(Icons.location_pin),
                ),
              ],
            ),
          ),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                for (final addr in addresses)
                  Marker(
                    point: addr.location ?? LatLng(0.0, 0.0),
                    width: 100.0,
                    height: 50.0,
                    builder: (BuildContext context) {
                      return GestureDetector(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black.withOpacity(0.3)),
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
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
