# Every Door App Change Log

## 0.1.2

_Unreleased_

* Map zooms dynamically only when location tracking is enabled.
* When far away from your geolocation, the map size is increased.
* Invalid phone numbers are now still accepted (e.g. 4-digit short numbers).
* Phone and website values are stored on lost field focus as well.
* Map for adding an amenity shows other amenities.
* Search terms are split by words, improving type searching.
* Checkmark hit area is increased vertically.
* Vending machines are displayed now, guideposts are not.
* Better error catching when uploading data.
* Fixed uploading modified relations.

## 0.1.1

_Released on 2022-03-30_

* Map zooms dynamically to accomodate all amenities listed.
* Fixed OAuth error with a `FormatException`.
* First upload after app start redirected to the login page.
* Added address and floor filters.
* Added a raw tag editor.
* Pending changes can be deleted from the list by swiping left.
* Uploading conflicts are resolved preemptively by downloading fresh data first.
* Better display for downloading state.
* Now can delete polygon amenities (using `was:` prefix).
* Moved "disused" and "missing" buttons below the fields.
* Removed the "missing" button for freshly created amenities.
* Better message for when there are no POI around.
* Changed app name to "Every Door" from "every\_door".
* Radio buttons stay in place on tap when they fit the screen.
* Removed `building_area` and `opening_hours/covid19` fields.
* Added more emoji for types (thanks @mfbehrens99).
* Types now can be found by tag values.
* It was possible to have an opening\_hours fragment with no weekdays.
* Made an editor for complex opening hours (as a raw string).
* Added address and floor fields to human-less amenities like atms.
* German translation (thanks @mfbehrens99).
* Your location is now updated once every 10 seconds when you don't move.
* With GPS disabled, app now restores the last location.
* Fixed a map error when GPS is off.
* Fixed empty floor list when adding an address to a POI with floor tags.
* Fixed a database error when restoring multipolygon relations.

## 0.1.0

_Released on 2022-03-25_

* First public version.
