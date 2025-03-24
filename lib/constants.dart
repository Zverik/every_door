import 'package:flutter/material.dart' show Colors, TextStyle;

const kAppTitle = 'Every Door';
const kAppVersion = '6.0-alpha2'; // Also used for presets.db versioning

// we might want to redefine
const kOldAmenityDays = 60; // check_date expiration rate
const kOldStructureDays = 360; // check_date expiration rate for churches and schools
const kSlowDownGPS = true; // skip location changes that are too small to register
const kRotationThreshold = 30.0; // degrees, for snapping to zero rotation

// global
const kDefaultLocation = <double>[59.42, 24.71];
const kBigRadius = 1000; // for downloading, in meters
const kSmallRadius = 400; // for downloading, in meters
const kVisibilityRadius = 100; // meters
const kObsoleteData = Duration(days: 3); // for yellow warning
const kSuperObsoleteData = Duration(days: 14); // for purging
const kFieldColor = Colors.lightBlueAccent;
const kManualOption = '✍️'; // Emoji icon for entering values by hand
const kLocalPaymentRadius = 5000; // How far local payment options reach, in meters
const kLocalFloorsRadius = 5000; // How far local floor options reach, in meters
// other modes
const kFarVisibilityRadius = 250; // meters in far location mode
const kNotesVisibilityRadius = 3000; // meters. Can be displayed very far out
const kInitialZoom = 17.0; // For POI list screen
const kEditMinZoom = 15.0; // Below that, the navigation mode switches on
const kEditMaxZoom = 21.0; // Same for all modes
const kDrawingMaxPoints = 100; // for hand-drawings
const kDrawingMaxLength = 5000; // meters, for hand-drawings
// editor
const kDuplicateSearchRadius = 150; // meters
const kOldAmenityDaysEditor = 3; // check_date expiration rate for the editor
const kOldAmenityWarning = 365 * 5; // When warn about an old amenity
const kMaxShownPresets = 14; // total number of presets for autocomplete
const kMaxNSIPresets = 4; // how many of them can come from NSI
const kFollowLinks = true; // whether to open links and phones on tap
const kShowContactSetting = true; // whether to show the "contact:" setting
const kCapitalizeNames = false; // By default, can be overridden by OSM data

// stays here
const kGeohashPrecision = 7; // ~76 meters (6 is ~600 which is too much)
const kRoadNameGeohashPrecision = 7;
const kCoordinatePrecision = 10000000; // For saving locations to a database
const kTapRadius = 20.0; // flutter pixels
const kFieldFontSize = 18.0; // font size in fields
const kFieldTextStyle = TextStyle(fontSize: kFieldFontSize);
const kMinElementsForWarning = 60000; // Alerting user when they have that many elements downloaded
const kChangesetSplitGap = 0.02; // Decimal degrees, min distance between groups of changes
const kMaxBulkDownloadZoom = 18; // Max zoom for bulk downloading tiles

const kOsmEndpoint = 'api.openstreetmap.org';
const kOsmAuth2Endpoint = 'www.openstreetmap.org';
// const kOsmEndpoint = 'master.apis.dev.openstreetmap.org';
// const kOsmAuth2Endpoint = 'master.apis.dev.openstreetmap.org';
const kScribblesEndpoint = 'geoscribble.osmz.ru';

const kEraseDatabase = false; // Clear all data on start — do not forget to set to false!
const kOverwritePresets = false; // Set to false when done testing
