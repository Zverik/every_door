import 'package:every_door/models/amenity.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

List<WebsiteProvider> websiteProviders = [
  UrlWebsiteProvider(), // Should be the first
  // Ordered by popularity, descending
  FacebookProvider(),
  TwitterProvider(),
  InstagramProvider(),
  VkProvider(),
  OkProvider(),
  LinkedinProvider(),
  TelegramProvider(),
  WhatsappProvider(),
  ViberProvider(),
  TikTokProvider(),
];

abstract class WebsiteProvider {
  /// List of prefixes to use this provider for a common website field.
  final List<String> prefixes;

  /// Icon for the drop-down list.
  final IconData icon;

  /// OSM key for this provider. Include "contact:" to force this prefix.
  final String key;

  /// Label for displaying.
  final String label;

  WebsiteProvider(
      {required this.prefixes,
      required this.icon,
      required this.key,
      required this.label});

  /// Whether user-entered value can be parsed.
  bool isValid(String full);

  /// Converts user-entered value into a proper tag value.
  String format(String value);

  /// Returns a short representation of the URL.
  String display(String full);

  /// Returns an URL for a tag value.
  String? url(String value);

  /// Gets tag value from element.
  String? getValue(OsmChange element) => element.getContact(key);

  /// Checks that the list of tags is relevant to this provider.
  bool hasKey(Map<String, String> tags) =>
      tags.containsKey(key) ||
      tags.containsKey(key.startsWith('contact:')
          ? key.replaceFirst('contact:', '')
          : 'contact:$key');

  /// Replaces tag value for element.
  setValue(OsmChange element, String value, {bool preferContact = false}) {
    element.setContact(
        preferContact && !key.startsWith('contact:') ? 'contact:$key' : key,
        value);
  }
}

class UrlWebsiteProvider extends WebsiteProvider {
  UrlWebsiteProvider()
      : super(
            prefixes: const [],
            icon: LineIcons.link,
            key: 'website',
            label: 'URL');

  @override
  String display(String full) => full;

  @override
  String? url(String value) {
    try {
      return format(value);
    } on ArgumentError {
      return null;
    }
  }

  static const kValidWebsiteUrlSchemes = ["http", "https"];

  @override
  bool isValid(String full) {
    try {
      final uri = Uri.parse(full.replaceAll(' ', '').trim());
      if (uri.hasScheme && !kValidWebsiteUrlSchemes.contains(uri.scheme)) {
        return false;
      }
      return true;
    } on FormatException {
      return false;
    }
  }

  @override
  String format(String value) {
    if (!isValid(value)) {
      throw ArgumentError('Please call isValid() before formatting');
    }
    Uri parsedUri = Uri.parse(value.replaceAll(' ', '').trim());
    if (!parsedUri.hasScheme) {
      // In Dart 2.17.6, just doing
      // parsedUri = parsedUri.replace(scheme: "https")
      // doesn't work. It changes www.google.com to http:www.google.com,
      // missing the slashes after the colon

      parsedUri = Uri.parse("https://${parsedUri.toString()}");
    }

    return parsedUri.toString();
  }
}

class _ProviderHelper extends WebsiteProvider {
  final RegExp _regexp;
  final String _format;

  _ProviderHelper({
    List<String>? prefixes,
    required super.icon,
    required super.key,
    required super.label,
    required RegExp regexp,
    String? format,
  })  : _regexp = regexp,
        _format = format ?? '%s',
        super(
            prefixes: prefixes ?? const []);

  @override
  bool isValid(String full) => _regexp.hasMatch(full.trim());

  @override
  String? url(String value) {
    try {
      final v = format(value);
      return v.startsWith('http') ? v : null;
    } on ArgumentError {
      return null;
    }
  }

  @override
  String format(String value) {
    final match = _regexp.firstMatch(value);
    if (match == null)
      throw ArgumentError('Please call isValid() before formatting');
    return _format.replaceFirst('%s', match.group(1)!);
  }

  @override
  String display(String full) {
    final match = _regexp.firstMatch(full);
    return match?.group(1) ?? full;
  }
}

class FacebookProvider extends _ProviderHelper {
  FacebookProvider()
      : super(
          icon: LineIcons.facebook,
          label: 'Facebook',
          prefixes: ['fb', 'facebook', 'face'],
          key: 'contact:facebook',
          regexp: RegExp(r'(?:facebook(?:\.com)?/)?([^/ ]+)/?$'),
          format: 'https://www.facebook.com/%s',
        );
}

class InstagramProvider extends _ProviderHelper {
  InstagramProvider()
      : super(
          icon: LineIcons.instagram,
          label: 'Instagram',
          prefixes: ['i', 'insta', 'instagram', 'инстаграм'],
          key: 'contact:instagram',
          regexp: RegExp(r'(?:instagram(?:\.com)?/)?([^/ ]+)/?$'),
          format: 'https://www.instagram.com/%s',
        );
}

class VkProvider extends _ProviderHelper {
  VkProvider()
      : super(
          icon: LineIcons.vk,
          label: 'Vk',
          prefixes: ['vk', 'вк'],
          key: 'contact:vk',
          regexp: RegExp(r'(?:vk(?:ontakte)?(?:\.com|\.ru)?/)?([^/ ]+)/?$'),
          format: 'https://vk.com/%s',
        );

  @override
  String format(String value) {
    final kDigits = '0123456789'.split('');
    value = value.trim();
    if (value.isNotEmpty &&
        value.characters.every((ch) => kDigits.contains(ch)))
      value = 'club' + value;
    return super.format(value);
  }
}

class TwitterProvider extends _ProviderHelper {
  TwitterProvider()
      : super(
          icon: LineIcons.twitter,
          label: 'Twitter',
          prefixes: ['tw', 'twitter'],
          key: 'contact:twitter',
          regexp: RegExp(r'(?:twitter(?:\.com)?/)?([^/ ]+)/?$'),
          format: 'https://twitter.com/%s',
        );
}

class OkProvider extends _ProviderHelper {
  OkProvider()
      : super(
          icon: LineIcons.odnoklassniki,
          label: 'OK',
          prefixes: ['ok', 'ок', 'однокл', 'одноклассники'],
          key: 'contact:ok',
          regexp: RegExp(r'(?:ok\.ru/)?([^/ ]+)/?$'),
          format: 'https://ok.ru/%s',
        );
}

class TelegramProvider extends _ProviderHelper {
  TelegramProvider()
      : super(
          icon: LineIcons.telegram,
          label: 'Telegram',
          prefixes: ['tg', 'telegram'],
          key: 'contact:telegram',
          regexp: RegExp(r'(?://t.me/|^t.me/)?([^/ ]+)/?$'),
          format: 'https://t.me/%s',
        );
}

class WhatsappProvider extends _ProviderHelper {
  WhatsappProvider()
      : super(
          icon: LineIcons.whatSApp,
          label: 'WhatsApp',
          key: 'contact:whatsapp',
          regexp: RegExp(r'(\d[\d -]{5,}\d)'),
        );

  @override
  String format(String value) => '+' + super.format(value);

  @override
  String display(String full) => format(full);
}

class ViberProvider extends _ProviderHelper {
  ViberProvider()
      : super(
          icon: LineIcons.viber,
          label: 'Viber',
          prefixes: ['viber'],
          key: 'contact:viber',
          regexp: RegExp(
              r'(?:chats\.viber\.com/|chatURI=)?(\+[\d -]+\d|[^/ ]+)/?$'),
        );
}

class LinkedinProvider extends _ProviderHelper {
  LinkedinProvider()
      : super(
    icon: LineIcons.linkedin,
    label: 'LinkedIn',
    prefixes: ['linkedin', 'li'],
    key: 'contact:linkedin',
    regexp: RegExp(r'(?:linkedin\.com/company/)?([^/ ]+)/?$'),
    format: 'https://www.linkedin.com/company/%s',
  );
}

class TikTokProvider extends _ProviderHelper {
  TikTokProvider()
      : super(
          icon: Icons.music_note,
          label: 'TikTok',
          prefixes: ['tiktok', 'tt'],
          key: 'contact:tiktok',
          regexp: RegExp(r'(?:tiktok\.com/)?@?([^@ /?]+)'),
          format: 'https://www.tiktok.com/@%s',
        );
}
