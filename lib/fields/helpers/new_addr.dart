import 'package:every_door/widgets/address_form.dart';
import 'package:every_door/models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class NewAddressPane extends ConsumerStatefulWidget {
  final LatLng location;

  const NewAddressPane(this.location);

  @override
  ConsumerState<NewAddressPane> createState() => _NewAddressPaneState();
}

class _NewAddressPaneState extends ConsumerState<NewAddressPane> {
  StreetAddress address = StreetAddress();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddressForm(
          location: widget.location,
          onChange: (addr) {
            setState(() {
              address = addr;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: address.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context, address);
                    },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        )
      ],
    );
  }
}
