# Every Door App Change Log

## 0.1.8

_Unreleased_

* Micromapping mode now has coloured dots instead of tiles and numbers.
* Added app version to the settings screen.
* Fixed location scopes in the app.
* Made hint labels lighter in text fields.
* Button in hours editor to use the most common value from around.

## 0.1.7

_Released on 2022-04-22_

* You could press the upload button twice and make duplicates.
* Changing building tags and adding an entrance to it broke uploading.
* Fixed osmChange exporting that broke in the last version.
* Increased zoom in map chooser in the micromapping mode.
* Not adding `check_date` for micromapping objects.
* When renewing an area, deleted elements were not removed from the editor.
* Disabled uploading elements one by one when there are way geometry changes.
* Better error handling when uploading elements one by one.
* After pressing the "manual ref" button in entrance editor, input focus stayed elsewhere.

## 0.1.6

_Released on 2022-04-22_

* Automatic snapping of entrances, tram stops, highway bumps, etc
  to buildings and roads on upload.
* Fixed arrow color and positioning on new entrance drag.
* Images instead of values for `roof:shape`.
* Added a safeguard against changeset comments made too long.

## 0.1.5

_Released on 2022-04-19_

* Redesiged mode buttons in Settings.
* Refactored all mode editors, now the UI is consistent.
* Editable preference for `payment:*` tags.
* `ref` for an entrance can be typed manually.
* Cancelling building or entrance editing did not work.
* Editor displays modified objects only relevant to the current mode.
* Finalized default preset lists for both modes.
* Added submitting buttons to phone and website fields.
* Description, note, and some other fields are now multiline.

## 0.1.4

_Released on 2022-04-16_

* Amenity list is displayed top-down instead of left-right.
* Added a draft version of the micromapping mode (can be enabled in Settings).
* Added a draft version of the building & entrance editor (find it in Settings).
* When your numeric keyboard cannot switch to letters, there's a fix in Settings.
* If you prefer `contact:phone` and `contact:website`, there's a setting.
* `PH off` support for opening hours and few more usability tweaks.
* You can mark an unchanged amenity checked on the editor page.
* Reduced distance for switching into the big map mode.
* Hopefull solved absence of POI on app restore.
* Added `club=*` to supported tags.
* Allowing moving nodes that are relation members.
* Better indication that the map in the editor is just another editable field.

## 0.1.3

_Released on 2022-04-04_

* You can choose an address on a map.
* Button to add a new address if the correct one is missing.
* Added support for Zelenograd addressing (`addr:city` without `addr:place`).
* Failsafe for tapping "back" button in the editor and losing changes.
* Press "back" on the main screen to return to your location.
* When adding a new opening hours fragment, enter the time interval.
* Initial opening hours interval is the most common one around.
* Hours fragments are sorted and de-duplicated on save.
* Current floor is displayed in the editor even without an address.
* Floor filter wasn't updated on address change.
* Fixed normalization in searching ("кофейня" works now).
* Fixed searching by tag values ("bar" works now).
* Fixed certificate error and icon for Android 7.

## 0.1.2

_Released on 2022-03-31_

* Map zooms dynamically only when location tracking is enabled.
* When far away from your geolocation, the map size is increased.
* Invalid phone numbers are now still accepted (e.g. 4-digit short numbers).
* Phone and website values are stored on lost field focus as well.
* Filter for non-verified amenities.
* Map for adding an amenity shows other amenities.
* Search terms are split by words, improving type searching.
* Checkmark hit area is increased vertically.
* Vending machines are displayed now, guideposts are not.
* When restoring the app, POI are updated now.
* App did not remember an object was referenced by another.
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
