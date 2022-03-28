import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/radio_field.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/filter.dart';
import 'package:every_door/models/floor.dart';
import 'package:every_door/providers/need_update.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/providers/poi_filter.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PoiFilterPane extends ConsumerStatefulWidget {
  final LatLng location;

  const PoiFilterPane(this.location);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PoiFilterPaneState();
}

class _PoiFilterPaneState extends ConsumerState<PoiFilterPane> {
  List<StreetAddress> nearestAddresses = [];
  List<Floor> floors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      loadAddresses();
      updateFloors();
    });
  }

  loadAddresses() async {
    final osmData = ref.read(osmDataProvider);
    final addr = await osmData.getAddressesAround(widget.location, 3);
    setState(() {
      nearestAddresses = addr;
    });
  }

  updateFloors() async {
    final filter = ref.watch(poiFilterProvider);
    final osmData = ref.read(osmDataProvider);
    List<Floor> floors;
    try {
      floors = await osmData.getFloorsAround(widget.location, filter.address);
    } on Exception catch (e) {
      print(e);
      floors = [];
    }
    setState(() {
      this.floors = floors;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(poiFilterProvider);
    if (nearestAddresses.isEmpty) {
      return Text('No addresses nearby');
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by address:', style: kFieldTextStyle),
          RadioField(
            options: nearestAddresses.map((e) => e.toString()).toList(),
            value: filter.address?.toString(),
            onChange: (value) {
              if (value == null) {
                // On clear, clearing all fields.
                ref.read(poiFilterProvider.state).state =
                    PoiFilter(includeNoData: filter.includeNoData);
              } else {
                final addr = nearestAddresses
                    .firstWhere((element) => element.toString() == value);
                setState(() {
                  // Clearing floors when the address has changed.
                  ref.read(poiFilterProvider.state).state = PoiFilter(
                    address: addr,
                    floor: null,
                    includeNoData: filter.includeNoData,
                  );
                });
              }
            },
          ),
          SizedBox(height: 10.0),
          Text('Filter by floor:', style: kFieldTextStyle),
          RadioField(
            options: floors.map((e) => e.string).toList() + ['empty'],
            value: (filter.floor?.isEmpty ?? false)
                ? 'empty'
                : filter.floor?.string,
            onChange: (value) {
              if (value == null) {
                ref.read(poiFilterProvider.state).state = PoiFilter(
                  address: filter.address,
                  floor: null,
                  includeNoData: filter.includeNoData,
                );
              } else if (value == 'empty') {
                ref.read(poiFilterProvider.state).state =
                    filter.copyWith(floor: Floor.empty());
              } else {
                final addr =
                    floors.firstWhere((element) => element.string == value);
                ref.read(poiFilterProvider.state).state =
                    filter.copyWith(floor: addr);
              }
            },
          ),
          /*Row(
            children: [
              Switch(
                value: filter.includeNoData,
                onChanged: (value) {
                  if (filter.isNotEmpty)
                    ref.read(poiFilterProvider.state).state =
                        filter.copyWith(includeNoData: value);
                },
              ),
              Text('Include no data'),
            ],
          ),*/
        ],
      ),
    );
  }
}
