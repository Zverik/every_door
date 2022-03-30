import 'package:every_door/models/address.dart';
import 'package:flutter/material.dart';

class NewAddressPane extends StatefulWidget {
  const NewAddressPane({Key? key}) : super(key: key);

  @override
  State<NewAddressPane> createState() => _NewAddressPaneState();
}

class _NewAddressPaneState extends State<NewAddressPane> {
  late StreetAddress address;

  @override
  void initState() {
    super.initState();
    address = StreetAddress();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: Center(child: Text('Under Construction')),
    );
  }
}
