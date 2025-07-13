import 'package:every_door/constants.dart';
import 'package:every_door/fields/helpers/qr_code.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/field.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpers/website_fmt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebsiteField extends PresetField {
  WebsiteField({required super.label})
      : super(
          key: "website",
          icon: Icons.language,
        );

  @override
  Widget buildWidget(OsmChange element) => WebsiteInputField(this, element);

  @override
  bool hasRelevantKey(Map<String, String> tags) {
    return websiteProviders.any((provider) => provider.hasKey(tags));
  }
}

class WebsiteInputField extends ConsumerStatefulWidget {
  final OsmChange element;
  final WebsiteField field;

  const WebsiteInputField(this.field, this.element);

  @override
  ConsumerState<WebsiteInputField> createState() => _WebsiteInputFieldState();
}

class _WebsiteInputFieldState extends ConsumerState<WebsiteInputField> {
  static final _logger = Logger('WebsiteInputField');

  late TextEditingController _controller;
  late WebsiteProvider _provider;
  late FocusNode _fieldFocus;
  int currentLength = 0;

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
    return value.substring(0, maxLength - 2) + '…';
  }

  bool submitWebsite(String value) {
    value = value.trim();
    if (value.isEmpty || !_provider.isValid(value)) return false;
    _controller.clear();
    setState(() {
      currentLength = 0;
      _provider.setValue(widget.element, _provider.format(value),
          preferContact: ref.read(editorSettingsProvider).preferContact);
    });
    return true;
  }

  void detectAndSubmitUrl(String url) {
    WebsiteProvider? found;
    // Skip first for the end (it's the generic URL provider).
    for (int i = 1; i < websiteProviders.length; i++) {
      if (websiteProviders[i].isValid(url, url: true)) {
        found = websiteProviders[i];
        break;
      }
    }
    if (found == null && websiteProviders[0].isValid(url, url: true)) {
      found = websiteProviders[0];
    }

    _logger.info('Provider ${found?.label ?? "unknown"} for $url');
    if (found != null) {
      setState(() {
        // Weird we need to do this check twice.
        if (found != null) {
          found.setValue(widget.element, found.format(url),
              preferContact: ref.read(editorSettingsProvider).preferContact);
        }
      });
    }
  }

  Future<void> showProviderChooser() async {
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
                    color: kFieldColor.withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: Icon(
                _provider.icon,
                color: Colors.white,
                size: 20.0,
              ),
              onPressed: showProviderChooser,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _fieldFocus,
                  keyboardType: TextInputType.url,
                  maxLength: currentLength > 200 ? 255 : null,
                  decoration: InputDecoration(
                    hintText: _provider.label,
                    suffixIcon: GestureDetector(
                      child: Icon(Icons.done),
                      onTap: () {
                        if (submitWebsite(_controller.text))
                          _fieldFocus.unfocus();
                      },
                    ),
                  ),
                  onSubmitted: submitWebsite,
                  onChanged: (value) {
                    setState(() {
                      currentLength = value.length;
                    });
                  },
                ),
              ),
            ),
            if (QrCodeScanner.kEnabled)
              IconButton(
                icon: Icon(
                  Icons.qr_code_scanner,
                  size: 30.0,
                ),
                onPressed: () async {
                  final Uri? detected = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => QrCodeScanner()));
                  if (detected != null) detectAndSubmitUrl(detected.toString());
                },
              ),
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
                        child: Text(
                            cutEllipsis(
                                website.provider.display(website.value), 25),
                            style: kFieldTextStyle),
                        onTap: () {
                          final url = website.provider.url(website.value);
                          if (kFollowLinks && url != null) {
                            final uri = Uri.tryParse(url);
                            if (uri != null)
                              launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.close, size: 30.0),
                      onTap: () {
                        final contact =
                            ref.read(editorSettingsProvider).preferContact;
                        setState(() {
                          website.provider.setValue(widget.element, '',
                              preferContact: contact);
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
