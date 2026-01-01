// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

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

String? getWarningForAmenity(OsmChange amenity, [AppLocalizations? loc]) {
  if (amenity.isFixmeNote()) {
    return loc?.warningFixmeNote ?? 'fixme note';
  }

  String? fixmeValue = amenity['fixme'];
  if (fixmeValue != null) {
    if (fixmeValue.length > 50) {
      fixmeValue = fixmeValue.substring(0, 50) + '…';
    }
    return loc?.warningFixme(fixmeValue) ?? 'fixme';
  }

  final mainKey = amenity.mainKey;
  if (mainKey != null &&
      _kTagsWithoutYesValue.contains(mainKey) &&
      amenity[mainKey] == 'yes') {
    return loc?.warningWrongTag('$mainKey=${amenity[mainKey]}') ?? 'yes value';
  }

  final int ageInDays = DateTime.now()
      .difference(amenity.element?.timestamp ?? DateTime.now())
      .inDays;
  if (ElementKind.amenity.matchesChange(amenity) &&
      ageInDays >= kOldAmenityWarning &&
      amenity.isOld) {
    return loc?.warningTooOld(loc.years((ageInDays / 365).round())) ??
        'too old';
  }

  if (!ElementKind.everything.matchesChange(amenity)) {
    return loc?.warningUnsupported ?? 'unsupported';
  }

  return null;
}
