import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/poi_describer.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/located.dart';
import 'package:every_door/providers/language.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart'
    show TextSpan, TextStyle, TextDecoration, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;

/// Icons that are used by [AmenityDescriber].
class PoiIcons {
  static const phone = '📞';
  static const wifi = '📶';
  static const wifiAbsent = '📵';
  static const cards = '💳';
  static const cash = '💰';
  static const url = '🌐';
  static const address = '🏠';
  static const photo = '📸';
  static const hours = '🕑';
  static const floor = '📶'; // TODO: better emoji
  static const wheelchair = '♿';
  static const warning = '⚠';
  static const door = '🚪';
}

/// Amenity indicator controls the information present in a POI tile.
/// Used by [AmenityDescriber] to build a tile content.
/// It usually returns a single icon for a missing property, and
/// maybe some more information when the property is present.
@Bind(bridge: true, wrap: true)
abstract class AmenityIndicator {
  /// Whether this indicator is useful for this object.
  bool applies(OsmChange amenity) => true;

  /// Returns an icon for when a property is missing.
  String? whenMissing(OsmChange amenity) => null;

  /// Returns an icon and maybe an abridged value for a property.
  String? whenPresent(OsmChange amenity) => null;
}

class HoursIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity['opening_hours'] == null ? PoiIcons.hours : null;

  @override
  String? whenPresent(OsmChange amenity) {
    String? hours = amenity['opening_hours'];
    if (hours == null) return null;
    hours = hours.replaceAll(':00', '');
    // todo: remove comments, simplify breaks etc.
    return '${PoiIcons.hours}$hours';
  }
}

class PaymentIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity.hasPayment ? null : PoiIcons.cards;

  @override
  String? whenPresent(OsmChange amenity) {
    if (amenity.acceptsCards) return PoiIcons.cards;
    if (amenity.cashOnly) return PoiIcons.cash;
    return null;
  }
}

class WheelchairIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity['wheelchair'] == null ? PoiIcons.wheelchair : null;
}

class PhoneIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity.getContact('phone') == null ? PoiIcons.phone : null;

  @override
  String? whenPresent(OsmChange amenity) {
    final phone = amenity.getContact('phone');
    if (phone == null) return null;
    var phonePart = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phonePart.length > 3)
      phonePart = '..' + phonePart.substring(phonePart.length - 3);
    return '${PoiIcons.phone}$phonePart';
  }
}

class WebsiteIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity.hasWebsite ? null : PoiIcons.url;
}

class AddressIndicator extends AmenityIndicator {
  @override
  String? whenMissing(OsmChange amenity) =>
      amenity['addr:housenumber'] == null && amenity['addr:housename'] == null
          ? PoiIcons.address
          : null;
}

class FloorIndicator extends AmenityIndicator {
  final Ref _ref;

  FloorIndicator(this._ref);

  @override
  String? whenMissing(OsmChange amenity) => amenity['addr:floor'] == null &&
          amenity['level'] == null &&
          _ref
              .read(osmDataProvider)
              .hasMultipleFloors(StreetAddress.fromTags(amenity.getFullTags()))
      ? PoiIcons.floor
      : null;
}

class RoomIndicator extends AmenityIndicator {
  @override
  String? whenPresent(OsmChange amenity) {
    final room = amenity['addr:door'];
    return room != null ? '${PoiIcons.door}$room' : null;
  }
}

/// Describes an [OsmChange] object by calling [AmenityIndicator]s.
/// Without a single indicator added it just prints [OsmChange.typeAndName].
@Bind()
class AmenityDescriber implements PoiDescriber {
  final Ref _ref;

  /// A list of indicators with string keys.
  /// Keys do not matter, they are here only to allow
  /// for predictable modification by plugins.
  final Map<String, AmenityIndicator> indicators;

  /// Initializer the describer with the default set of indicators,
  /// if [indicators] is not specified.
  AmenityDescriber(this._ref, [Map<String, AmenityIndicator>? indicators])
      : indicators = indicators ??
            {
              // missing: hours, payment, wheelchair, phone, website, addr, floor
              // present: payment, room, phone, hours
              'payment': PaymentIndicator(),
              'wheelchair': WheelchairIndicator(),
              'phone': PhoneIndicator(),
              'website': WebsiteIndicator(),
              'address': AddressIndicator(),
              'floor': FloorIndicator(_ref),
              'room': RoomIndicator(),
              'hours': HoursIndicator(),
            };

  String _buildMissing(OsmChange amenity) {
    if (!ElementKind.amenity.matchesChange(amenity)) return '';
    return indicators.values
        .where((i) => i.applies(amenity))
        .map((i) => i.whenMissing(amenity))
        .whereType<String>()
        .join();
  }

  String _buildPresent(OsmChange amenity) {
    if (!ElementKind.amenity.matchesChange(amenity)) return '';
    return indicators.values
        .where((i) => i.applies(amenity))
        .map((i) => i.whenPresent(amenity))
        .whereType<String>()
        .join(' ');
  }

  @override
  TextSpan describe(Located element) {
    if (element is! OsmChange) return TextSpan(text: '???');

    final present = _buildPresent(element);
    final missing = _buildMissing(element);
    final no = _ref.read(localizationsProvider).tileNo;

    return TextSpan(
      children: [
        TextSpan(
            text: element.typeAndName,
            style: !element.isDisused
                ? null
                : TextStyle(decoration: TextDecoration.lineThrough)),
        if (present.isNotEmpty) ...[
          TextSpan(text: '\n'),
          TextSpan(text: present),
        ],
        if (missing.isNotEmpty) ...[
          TextSpan(text: '\n'),
          TextSpan(
            text: '$no $missing',
            style: TextStyle(backgroundColor: Colors.red.shade50),
          ),
        ],
      ],
    );
  }
}
