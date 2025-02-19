import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/poi_warnings.dart';
import 'package:every_door/models/address.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/material.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class PoiTile extends ConsumerWidget {
  final OsmChange amenity;
  final int? index;
  final double? width;
  final VoidCallback? onToggleCheck;

  late final String title;
  late final String present;

  PoiTile({
    this.index,
    required this.amenity,
    this.width,
    this.onToggleCheck,
  }) {
    present = buildPresent();
  }

  String buildMissing(WidgetRef ref) {
    if (!ElementKind.amenity.matchesChange(amenity)) return '';

    List<String> missing = [];
    if (amenity['opening_hours'] == null) missing.add(PoiIcons.hours);
    if (!amenity.hasPayment) missing.add(PoiIcons.cards);
    if (amenity['wheelchair'] == null) missing.add(PoiIcons.wheelchair);
    if (amenity.getContact('phone') == null) missing.add(PoiIcons.phone);
    if (!amenity.hasWebsite) missing.add(PoiIcons.url);
    if (amenity['addr:housenumber'] == null &&
        amenity['addr:housename'] == null) missing.add(PoiIcons.address);
    if (amenity['addr:floor'] == null &&
        amenity['level'] == null &&
        ref
            .read(osmDataProvider)
            .hasMultipleFloors(StreetAddress.fromTags(amenity.getFullTags())))
      missing.add(PoiIcons.floor);
    return missing.join();
  }

  String buildPresent() {
    if (!ElementKind.amenity.matchesChange(amenity)) return '';

    List<String> present = [];
    if (amenity.acceptsCards)
      present.add(PoiIcons.cards);
    else if (amenity.cashOnly) present.add(PoiIcons.cash);

    final room = amenity['addr:door'];
    if (room != null) present.add('${PoiIcons.door}$room');
    final phone = amenity.getContact('phone');
    if (phone != null) present.add('${PoiIcons.phone}${shortPhone(phone)}');
    final hours = amenity['opening_hours'];
    if (hours != null) present.add('${PoiIcons.hours}${shortHours(hours)}');
    return present.join(' ');
  }

  String shortHours(String hours) {
    hours = hours.replaceAll(':00', '');
    // todo: remove comments, simplify breaks etc.
    return hours;
  }

  String shortPhone(String phone) {
    var phonePart = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phonePart.length > 3)
      phonePart = '..' + phonePart.substring(phonePart.length - 3);
    return phonePart;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    bool showWarning = getWarningForAmenity(amenity, loc) != null;
    final title = (index == null ? '' : index.toString() + '. ') +
        (showWarning ? PoiIcons.warning : '') +
        amenity.typeAndName;
    final missing = buildMissing(ref);
    final needsCheckDate = ElementKind.needsCheck.matchesChange(amenity);

    return Container(
      decoration: BoxDecoration(
        color: !amenity.isDisused ? Colors.white : Colors.grey.shade200,
        border: showWarning
            ? Border.all(color: Colors.yellowAccent, width: 3.0)
            : null,
      ),
      width: width,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onToggleCheck != null && needsCheckDate)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: amenity.wasOld ? onToggleCheck : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        amenity.isOld ? Icons.check : Icons.check_circle,
                        color: amenity.isOld ? Colors.black : Colors.green,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    ref.read(microZoomedInProvider.notifier).state = null;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PoiEditorPage(amenity: amenity),
                          fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: title,
                            style: !amenity.isDisused
                                ? null
                                : TextStyle(
                                    decoration: TextDecoration.lineThrough)),
                        if (present.isNotEmpty) ...[
                          TextSpan(text: '\n'),
                          TextSpan(text: present),
                        ],
                        if (missing.isNotEmpty) ...[
                          TextSpan(text: '\n'),
                          TextSpan(
                            text: '${loc.tileNo} $missing',
                            style: TextStyle(backgroundColor: Colors.red.shade50),
                          ),
                        ],
                      ],
                    ),
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
