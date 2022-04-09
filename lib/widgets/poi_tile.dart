import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/providers/micromapping.dart';
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
}

class PoiTile extends ConsumerWidget {
  final OsmChange amenity;
  final int? index;
  final double? width;
  final VoidCallback? onToggleCheck;
  final VoidCallback? onNeedReload;

  late final String title;
  late final String present;
  late final String missing;

  PoiTile(
      {this.index,
      required this.amenity,
      this.width,
      this.onToggleCheck,
      this.onNeedReload}) {
    present = buildPresent();
    missing = buildMissing();
  }

  String buildMissing() {
    if (!isAmenityTags(amenity.getFullTags())) return '';

    List<String> missing = [];
    if (amenity.getContact('phone') == null) missing.add(PoiIcons.phone);
    if (!amenity.hasWebsite) missing.add(PoiIcons.url);
    if (amenity['opening_hours'] == null) missing.add(PoiIcons.hours);
    if (amenity['addr:housenumber'] == null) missing.add(PoiIcons.address);
    // TODO: add more icons?
    return missing.join();
  }

  String buildPresent() {
    if (!isAmenityTags(amenity.getFullTags())) return '';

    List<String> present = [];
    final hours = amenity['opening_hours'];
    if (hours != null) present.add('${PoiIcons.hours}${shortHours(hours)}');
    final phone = amenity.getContact('phone');
    if (phone != null) present.add('${PoiIcons.phone}${shortPhone(phone)}');
    // TODO: more icons
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
    final title =
        (index == null ? '' : index.toString() + '. ') + amenity.typeAndName;
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
      color: !amenity.isDisused ? Colors.white : Colors.grey.shade200,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onToggleCheck != null)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onToggleCheck,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
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
            child: GestureDetector(
              onTap: () async {
                ref.read(microZoomedInProvider.state).state = null;
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PoiEditorPage(amenity: amenity)),
                );
                if (result == true && onNeedReload != null) {
                  onNeedReload!();
                }
              },
              child: RichText(
                text: TextSpan(
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
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 16.0,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
