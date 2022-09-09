import 'package:flutter/material.dart' show Colors, TextStyle;

const kAppTitle = 'Every Door';
const kAppVersion = '2.0'; // Also used for presets.db versioning

const kDefaultLocation = <double>[59.42, 24.71];
const kDatabaseName = 'every_door.db';
const kBigRadius = 1000; // for downloading, in meters
const kSmallRadius = 400; // for downloading, in meters
const kVisibilityRadius = 100; // meters
const kFarDistance = 150; // when we turn to "far location" mode, meters
const kFarVisibilityRadius = 150; // meters in far location mode
const kDuplicateSearchRadius = 150; // meters
const kGeohashPrecision = 7; // ~76 meters (6 is ~600 which is too much)
const kRoadNameGeohashPrecision = 7;
const kCoordinatePrecision = 10000000; // For saving locations to a database
const kObsoleteData = Duration(days: 3); // for yellow warning
const kSuperObsoleteData = Duration(days: 14); // for purging
const kAmenitiesInList = 12; // for shops & amenities mode
const kMicroStuffInList = 24; // same, but for micromapping mode
const kTapRadius = 20.0; // flutter pixels
const kOldAmenityDays = 60; // check_date expiration rate
const kOldAmenityDaysEditor = 3; // check_date expiration rate for the editor
const kOldAmenityWarning = 365 * 5; // When warn about an old amenity
const kFieldColor = Colors.lightBlueAccent;
const kFieldFontSize = 18.0; // font size in fields
const kFieldTextStyle = TextStyle(fontSize: kFieldFontSize);
const kMaxShownPresets = 14; // total number of presets for autocomplete
const kMaxNSIPresets = 3; // how many of them can come from NSI
const kFollowLinks = true; // whether to open links and phones on tap
const kUploadOnClose = false; // whether to trigger data upload on app deactivation
const kShowContactSetting = true; // whether to show the "contact:" setting
const kSlowDownGPS = false; // skip location changes that are too small to register
const kInitialZoom = 17.0; // For POI list screen
const kMicromappingTapZoom = 19.0; // how much to zoom in when tapping a bunch of elements in micromapping
const kRotationThreshold = 30.0; // degrees, for snapping to zero rotation
const kManualOption = '✍️'; // Emoji icon for entering values by hand
const kMinElementsForWarning = 60000; // Alerting user when they have that many elements downloaded
const kChangesetSplitGap = 0.02; // Decimal degrees, min distance between groups of changes
const kMaxBulkDownloadZoom = 18; // Max zoom for bulk downloading tiles

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

const kOsmEndpoint = 'api.openstreetmap.org';
const kOsmAuth2Endpoint = 'www.openstreetmap.org';
// const kOsmEndpoint = 'master.apis.dev.openstreetmap.org';
// const kOsmAuth2Endpoint = 'master.apis.dev.openstreetmap.org';

const kEraseDatabase = false; // Clear all data on start — do not forget to set to false!
const kOverwritePresets = false; // Set to false when done testing