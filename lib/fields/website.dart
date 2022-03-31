import 'package:every_door/constants.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpers/website_fmt.dart';

class WebsiteField extends PresetField {
  WebsiteField({required String label})
      : super(
          key: "website",
          label: label,
          icon: Icons.language,
        );

  @override
  Widget buildWidget(OsmChange element) => WebsiteInputField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    return websiteProviders.any(
        (key) => tags.containsKey(key) || tags.containsKey('contact:$key'));
  }
}

class WebsiteInputField extends StatefulWidget {
  final OsmChange element;
  final WebsiteField field;

  const WebsiteInputField(this.field, this.element);

  @override
  State<WebsiteInputField> createState() => _WebsiteInputFieldState();
}

class _WebsiteInputFieldState extends State<WebsiteInputField> {
  late TextEditingController _controller;
  late WebsiteProvider _provider;
  late FocusNode _fieldFocus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _provider = websiteProviders.first;
    _fieldFocus = FocusNode();
    _fieldFocus.addListener(() {
      if (!_fieldFocus.hasFocus) {
        submitWebsite(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  String cutEllipsis(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength - 2) + '...';
  }

  submitWebsite(String value) {
    value = value.trim();
    if (value.isEmpty || !_provider.isValid(value)) return;
    _controller.clear();
    setState(() {
      _provider.setValue(widget.element, _provider.format(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<WebsiteRow> websites = [];
    for (final provider in websiteProviders) {
      final value = provider.getValue(widget.element);
      if (value != null) {
        websites.add(WebsiteRow(provider, value));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Ink(
              decoration: ShapeDecoration(
                color: Theme.of(context).primaryColor,
                shape: CircleBorder(),
              ),
              width: 40.0,
              child: IconButton(
                icon: Icon(
                  _provider.icon,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: [
                            for (final provider in websiteProviders)
                              GestureDetector(
                                child: Container(
                                  color: kFieldColor.withOpacity(0.2),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.0,
                                    horizontal: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        provider.icon,
                                        size: 30.0,
                                      ),
                                      SizedBox(width: 5.0),
                                      Text(
                                        provider.label,
                                        style: TextStyle(fontSize: 24.0),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, provider);
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                  if (result != null) {
                    setState(() {
                      _provider = result;
                      _fieldFocus.requestFocus();
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _fieldFocus,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(hintText: _provider.label),
                onSubmitted: submitWebsite,
              ),
            )
          ],
        ),
        for (final website in websites)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                color: Colors.blueGrey.shade50,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(website.provider.icon),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        child: Text(cutEllipsis(website.provider.display(website.value), 25), style: kFieldTextStyle),
                        onTap: () {
                          if (kFollowLinks && website.value.startsWith('http')) {
                            launch(website.value);
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.close, size: 30.0),
                      onTap: () {
                        setState(() {
                          website.provider.setValue(widget.element, '');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class WebsiteRow {
  final WebsiteProvider provider;
  final String value;

  const WebsiteRow(this.provider, this.value);
}
