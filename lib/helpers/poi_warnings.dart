import 'package:every_door/constants.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const _kTagsWithoutYesValue = {
  'amenity',
  'shop',
  'craft',
  'tourism',
  'historic',
  'club',
  'highway',
  'railway',
  'office',
  'healthcare',
  'leisure',
  'natural',
  'emergency',
  'waterway',
  'man_made',
  'power',
  'aeroway',
  'aerialway',
  'marker',
  'public_transport',
  'traffic_sign',
  'hazard',
  'telecom',
  'landuse',
  'military',
  'boundary',
  'advertising',
  'playground',
  'traffic_calming',
};

String? getWarningForAmenity(OsmChange amenity, AppLocalizations loc) {
  String? fixmeValue = amenity['fixme'];
  if (fixmeValue != null && !amenity.isNew && amenity['amenity'] != 'fixme') {
    if (fixmeValue.length > 50) {
      fixmeValue = fixmeValue.substring(0, 50) + '…';
    }
    return loc.warningFixme(fixmeValue);
  }

  final mainKey = getMainKey(amenity.getFullTags(true));
  if (mainKey != null &&
      _kTagsWithoutYesValue.contains(mainKey) &&
      amenity[mainKey] == 'yes') {
    return loc.warningWrongTag('$mainKey=${amenity[mainKey]}');
  }

  final int ageInDays = DateTime.now()
      .difference(amenity.element?.timestamp ?? DateTime.now())
      .inDays;
  if (ageInDays >= kOldAmenityWarning && amenity.isOld) {
    return loc.warningTooOld(loc.years((ageInDays / 365).round()));
  }

  return null;
}
