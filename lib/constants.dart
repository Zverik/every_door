import 'package:flutter/material.dart';

const kAppTitle = 'Every Door';
const kAppVersion = '0.2.0'; // Also used for presets.db versioning

const kDefaultLocation = <double>[59.42, 24.71];
const kDatabaseName = 'every_door.db';
const kBigRadius = 1000; // for downloading, in meters
const kSmallRadius = 400; // for downloading, in meters
const kVisibilityRadius = 100; // meters
const kFarDistance = 150; // when we turn to "far location" mode, meters
const kFarVisibilityRadius = 150; // meters in far location mode
const kGeohashPrecision = 7; // ~76 meters (6 is ~600 which is too much)
const kCoordinatePrecision = 10000000; // For saving locations to a database
const kObsoleteData = Duration(days: 3); // for yellow warning
const kSuperObsoleteData = Duration(days: 14); // for purging
const kAmenitiesInList = 12;
const kMicroStuffInList = 15;
const kTapRadius = 20.0; // flutter pixels
const kOldAmenityDays = 14;
const kFieldColor = Colors.lightBlueAccent;
const kFieldFontSize = 18.0;
const kFieldTextStyle = TextStyle(fontSize: kFieldFontSize);
const kMaxShownPresets = 10;
const kMaxNSIPresets = 3;
const kFollowLinks = false;
const kUploadOnClose = false;
const kShowContactSetting = false;
const kMicromappingTapZoom = 19.0;
const kManualOption = '✍️';

// Should be exactly 8 lines in both lists.
const kDefaultPresets = [
  'shop/convenience', 'amenity/atm',
  'shop/hairdresser', 'shop/beauty',
  'shop/florist', 'amenity/pharmacy',
  'shop/clothes', 'shop/shoes',
  'amenity/toilets', 'shop/bakery',
  'amenity/restaurant', 'amenity/cafe',
  'amenity/fast_food', 'amenity/bar',
  'amenity/fuel', 'amenity/car_wash',
];

const kDefaultMicroPresets = [
  'amenity/waste_basket', 'amenity/bench',
  'highway/street_lamp', 'natural/tree',
  'power/pole', 'man_made/utility_pole',
  'amenity/recycling', 'amenity/waste_disposal',
  'emergency/fire_hydrant', 'man_made/street_cabinet',
  'leisure/playground', 'amenity/bicycle_parking',
  'amenity/post_box', 'man_made/manhole',
  'tourism/information/guidepost', 'tourism/information/board',
];

const kEraseDatabase = false; // Clear all data on start — do not forget to set to false!
const kOverwritePresets = false; // Set to false when done testing