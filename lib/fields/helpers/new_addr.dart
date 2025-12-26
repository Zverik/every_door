// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/widgets/address_form.dart';
import 'package:every_door/models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class NewAddressPane extends ConsumerStatefulWidget {
  final LatLng location;
  final StreetAddress? initialAddress;

  const NewAddressPane({required this.location, this.initialAddress});

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
          initialAddress: widget.initialAddress,
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
