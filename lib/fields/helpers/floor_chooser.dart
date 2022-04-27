import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FloorChooserPane extends StatefulWidget {
  const FloorChooserPane({Key? key}) : super(key: key);

  @override
  State<FloorChooserPane> createState() => _FloorChooserPaneState();
}

class _FloorChooserPaneState extends State<FloorChooserPane> {
  final _formKey = GlobalKey<FormState>();
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      if (_formKey.currentState!.validate()) {
        Navigator.pop(context, [_controller1.text, _controller2.text]);
      } else if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
        });
      }
    }

    final loc = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Text(
            loc.fieldFloorNew,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          )),
          SizedBox(height: 10.0),
          Text(
            loc.fieldFloorFloorDesc + ':',
            style: TextStyle(fontSize: 16.0),
          ),
          TextFormField(
            controller: _controller1,
            autofocus: true,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: 'G, 1, 2, 3A, ...'),
          ),
          SizedBox(height: 15.0),
          Text(
            loc.fieldFloorLevelDesc + ':',
            style: TextStyle(fontSize: 16.0),
          ),
          TextFormField(
            controller: _controller2,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autovalidateMode: _autovalidateMode,
            decoration: InputDecoration(hintText: '0, 1, 2.5, ...'),
            validator: (value) => value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null
                ? loc.fieldFloorShouldBeNumber
                : null,
            onEditingComplete: submit,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel)),
              TextButton(
                  onPressed: submit,
                  child: Text(MaterialLocalizations.of(context).okButtonLabel)),
            ],
          )
        ],
      ),
    );
  }
}
