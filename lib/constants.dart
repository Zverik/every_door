import 'package:flutter/material.dart';

const kAppTitle = 'Every Door';
const kAppVersion = '0.1.2'; // Also used for presets.db versioning

const kDefaultLocation = <double>[59.42, 24.71];
const kDatabaseName = 'every_door.db';
const kBigRadius = 1000; // in meters
const kSmallRadius = 400; // in meters
const kVisibilityRadius = 100; // meters
const kFarDistance = 500; // when we turn to "far location" mode, meters
const kFarVisibilityRadius = 150; // meters
const kGeohashPrecision = 7; // ~76 meters (6 is ~600 which is too much)
const kCoordinatePrecision = 10000000; // For saving locations to a database
const kObsoleteData = Duration(days: 3);
const kSuperObsoleteData = Duration(days: 7);
const kAmenitiesInList = 14;
const kOldAmenityDays = 7;
const kFieldColor = Colors.lightBlueAccent;
const kFieldFontSize = 18.0;
const kFieldTextStyle = TextStyle(fontSize: kFieldFontSize);
const kMaxShownPresets = 10;
const kMaxNSIPresets = 3;
const kFollowLinks = false;
const kUploadOnClose = false;

const kDefaultPresets = [
  'shop/convenience', 'shop/clothes',
  'shop/hairdresser', 'shop/beauty',
  'shop/florist', 'amenity/pharmacy',
  'amenity/cafe', 'amenity/fast_food',
  'amenity/atm', 'amenity/fuel',
  'amenity/doctors', 'amenity/dentist',
  'shop/furniture', 'shop/shoes',
];

const kEraseDatabase = false; // Clear all data on start — do not forget to set to false!
const kOverwritePresets = false; // Set to false when done testing