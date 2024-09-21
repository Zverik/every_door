# Every Door App Change Log

## 5.2

_Unreleased_

* Added waterway features (like dams) support, snapped to rivers.
* Scale bar for the map chooser.
* Allowing entering arbitraty keys in the raw tags panel.
* Not changing zoom when switching to the notes mode.
* Undo in the notes mode works on labels too.
* Updated all presets and imagery layers.
* New supported languages: Greek (thanks Jim Kats) and Indonesian (thanks teamediacommunity).

## 5.1

_Released on 2024-05-29_

* Added the recent walked path display as small blue dots.
* GeoScribbles drawing is locked by default.
* QR code scanner for the website field.
* When deleting an amenity with a unique address, suggest keeping the address.
* Now possible to move nodes that are relation members.
* Button to mark a building demolished.
* Fixed a blue marker for unmovable objects in the editor.
* Hopefully fixed the white map when adding an object on iOS.
* Location on Android is now updated once a second (thanks @freeExec for a hint).
* Dotted scribble lines are now dashed (now supported in `flutter_map` 7.0).
* Fixed all missing field name translations.
* Minimal supported Android version is 5.0 now, due to the Flutter upgrade.

## 5.0

_Released on 2024-05-06_

### Highlights

* The 4th mode for notes is feature-complete. Try drawing things!
* Days of week are displayed in a local language.
* In combo field value lists, can search by translated values.
* Always suggesting floor tags for levels 0 and 1.

### Other

* Allowing most interactions on maps.
* Allowing deletion of point buildings.
* Airport gates can be added or edited in micromapping mode.
* Location marker is now better visible against dark backgrounds.
* Hopefully fixed the `PlatformException` when logging in to OSM.
* Hopefully fixed the issue when you upload changes and then momentarily see the old data.
* Supporting locationSets for presets, fixing duplicate presets in the list.
* Speed fields are not filtered out now.
* Removed the password login button.
* Switched to Dart 3 and upgraded `flutter_map` to version 6.
* Minimal supported iOS version is 12 now.
* Translations into Estonian (thanks August Murasev Frokjaer), Odia (thanks Soumendra Kumar Sahoo),
  and major updates to Croatian (thanks Milo Ivir).

## 4.1

_Released on 2023-11-06_

* Changed default card payment options to `debit_cards` and `credit_cards`.
* Fixed word capitalization for description and other similar fields.
* You can find a preset by aliases now.
* Fixed amenity warnings not being shown on editor open.
* For combo boxes, options from a preset are prioritized over taginfo.
* Marking a shop on a building closed does not remove it from the map.

## 4.0

_Released on 2023-10-07_

### Highlights

* Hopefully GPS works much better now, thanks to Jeroeen Weener for
  [fixing](https://github.com/Baseflow/flutter-geolocator/issues/1114) multiple geolocation issues.
* Switched the default imagery to Mapbox and disabled Maxar (which has forsaken us).
* Updated the Bing imagery key.
* Increased minimum Android version to 4.4.
* Card payment settings were moved to the editor pane; introducing local card payment defaults.
* Name capitalization style (words vs sentences) is now detected from the map.
* New notes are marked with the `#EveryDoor` hashtag (thanks @deevroman).

### Editor

* Country-specific fields were not filtered properly, leading to duplicate fields in the editor.
* Support for `roadheight` fields (e.g. `maxheight`).
* Removed the `check_date` field from the editor.
* Allowing adding breaks to opening hours intervals spanning midnight.
* Support for `traffic_calming=table` checkbox.
* Warning when adding an unsupported object (not visible on the map).
* Warning when adding an amenity from the micromapping mode or vice-versa.
* Editable addresses in forms for buildings.
* Forbade changing buildings and entrances types (to amenities).
* Added `addr:postcode` field to all presets with addresses, including buildings.
* Added searching to the language chooser.

### Other

* Snapping `stop_position` to the nearest highway or railway.
* Mentioning addresses in changeset comments properly.
* Log can be copied now (thanks @ann-who).
* Increased max zoom when placing an object (thanks @ann-who).
* In the language settings panel, the device language is placed first (thanks @ann-who).
* Fixed error 414 when uploading 700+ changed nodes at once.
* Prefix could override an existing main tag (e.g. `was:amenity` vs `shop`).
* For letter boxes, `post:*` address fields are now editable.
* OSM Note comment dates are now displayed.
* Added option for `roof:levels=0`.

## 3.1

_Released on 2023-06-03_

* Updated Maxar and Mapbox imagery keys.
* Supporting tagging schema v6, added hundred new presets.
* Some POI like churches and libraries have reduced obsoletion rate (1 year).
* Deleting buildings via lifecycle prefixes is forbidden now.
* Added `block_number` field for japanese addresses.
* `name:signed` is not a language suffix.
* When downloading data for an area, do not delete new notes (but changes
  to existing notes would be lost though).
* Purge non-modified notes when purging all data.
* Update all secondary tags when changing a type for an amenity.
* Fixed error when after uploading new amenities and editing them, duplicates
  might have appeared.
* Pasting a `wikimedia_commons` value strips it of wiki formatting.
* Fixed long press on the sharing icon at the raw tags panel.
* Snack bar when removing a change does not time out for some reason.
  Forcibly closing it when leaving the changes list.
* Switched the editing page to a full screen dialog for better UX on iOS.
* Allow 1-character Japanese or Chinese search queries.
* Allow January dates on specific days opening\_hours editor.
* More emoji for POI types (thanks @ivanbranco and @neuschaefer).
* Translations into Finnish (thanks Lasse Liehu), Marathi (thanks संकेत गराडे),
  and Hungarian (thanks Balázs Úr) languages, and major updates to Punjabi
  (both variants) and Persian.

## 3.0

_Released on 2022-10-25_

### Highlights

* You can zoom out to the max to navigate wherever you want.
* Zoom levels are preserved between modes.
* Direction editor (for degrees 0-360 clockwise).
* Changed colors in the micromapping mode and made them more stable.

### Other

* Street names from streets and manually entered values were missing.
* Added `attraction=*` to supported keys.
* Displaying room number in POI tiles.
* Tag `opening_hours:signed=no` is removed after adding opening hours.
* Changeset hashtags box was hidden behind the keyboard.
* Extended numeric keyboard for `level` supporting negative values.
* Resolving a non-uploaded note now deletes it.
* Fixed processing `disused:*` keys for changeset comments.
* Increased max zoom to 21.
* Option to mark a newly created amenity disused (or delete it).
* Added `shop=vacant` to preset searching results.
* Added OSM notes to the map chooser.
* Translation into Punjabi (Pakistan) language (thanks @bgo-eiu)
  and major updates to Norwegian (thanks Nikolaj Fyhn) and Esperanto (thanks jolesh).

## 2.0

_Released on 2022-09-10_

### Highlights

* Changeset hashtags.
* Increased confirmation interval to 2 months.
* Name field is focused when creating a new POI.
* Warnings for amenities that have a `fixme` tag or that are too old.

### Other

* Fixed filtering for empty floor values.
* Show `name:en` etc on a tile when `name` is not set.
* Editing a building that's also a POI removed `check_date` from it.
* Removed the requirement for a roof shape to get a yellow building label.
* Added a FAQ entry about yellow labels and white dots.
* Increased warning threshold for too many elements to 60k.
* "Cards only" option for payment fields.
* Changed the icon for raw tags.
* Added missing language names for the chooser.
* Streamlined URL parsing, thanks to @mitchellmebane.
* Fixed updating the pending uploads list after changing an object from within it.
* Field labels were not translated after switching language from inside the app.
* Bing imagery was not immediately visible in the list.
* Checking for stale authentication before uploading.
* Tap on the tile downloading button the second time to abort downloading.
* Split buttons on the entrance card in two lines.
* Editing breaks in opening hours in two taps, not four.
* Translations into Catalan (thanks raf) and Croatian (thanks @mnalis),
  major improvements to Dutch (thanks invalidCards).

## 1.0

_Released on 2022-08-13_

* **First public release.**
* Imagery by default is now Maxar Premium.
* Moved `amenity=lounger` to micromapping (thanks @starsep).
* Added support for `hazard=*`, `telecom=*`, and `traffic_sign=*`.
* Fixed filtering panel when the map was moved.
* Fixed partial uploading in case of an error.
* Fixed wrong map in the editor pane after moving the object.
* Translations into Czech (thanks Fjuro), Portuguese (thanks Matheus Gomes Correia),
  Chinese Traditional (thanks Supaplex).

## 0.10

_Released on 2022-08-08_

* Selectable notes content with tappable links.
* Tooltips for all icon buttons.
* Fixed font size on amenity tiles to be more accessible.
* Language chooser in settings.
* New Thai translation (thanks VRSasha) and major improvements in
  Arabic (thanks Abdullah Abdulrhman), Belorussian (thanks Jaŭhien),
  and Swedish (thanks Dennis Öberg) translations.

## 0.9

_Released on 2022-08-02_

### Highlights

* The fourth editing mode with OSM notes (the design is preliminary).
* Button to download tiles at the imagery list.
* Object history panel (thanks @GeorgeHoneywood).

### Other

* Email field now can edit `contact:email`.
* Returned the setting for preferring `contact:` prefixes.
* Supporting `marker=*` for pipeline markers.
* Fixed editor pane when in Basque locale.
* ATMs and vending machines are back in the POI category.
* Added `public_transport=*` to micromapping.
* Autocompletion of the key in the tags pane.
* Made dots in the micromapping mode bigger.
* Removed `shop` from fields.
* Caching combo values on downloading data.
* Major improvements in Turkish (thanks Nesim İŞ), Portugese (thanks Matheus Gomes Correia),
  and Korean (thanks Items Align) translations.
* Updated all dependencies and increased target API to Android 13.

## 0.8

_Released on 2022-07-15_

* Removed `addr:postcode` and added `building:material` to the building properties.
* Removed non-card options from the payment setting.
* Disabled map jumping in POI mode because of the number of POI.
* The editor did not download address points.
* No addresses on buildings in Netherlands.
* Removed `not:name` field.

### Opening Hours Editor

* Could not mark an hours fragment as `off`.
* An inactive `PH` interval is no longer added by default.
* Hour options are displayed in five columns instead of four.
* When switching to the raw hours editor, the value was not updated.
* `24/7` value was missing from the raw value editor.

## 0.7

_Released on 2022-07-11_

### Highlights

* Rewrote both the UI and the model for the `opening_hours` editor.
* New About page (thanks @GeorgeHoneywood).
* Moved ATM, vending machines and parcel lockers to micromapping.
* Added indication for payment types, missing floor, and wheelchair
  accessibility to POI tiles.

### Editor

* Field definitions are cached for faster loading.
* Storing last used tags only for non-amenities.
* Storing last used tags for entrances too.
* Removed searching for entrance-related presets.
* Fixed losing input focus on duplicate warning.
* Lowercase input fields for colours and some other tags.
* You can use any keys in the tags panel, not just popular.
* Fixed multi-word query strings when searching for a preset.
* NSI suggestions for micromapping objects.

### Addresses

* Option to type a street name by hand.
* House names support.
* `addr:city` was removed when editing an address.
* Support for multiple floors for an amenity.
* Added `addr:postcode` editor to buildings.

### Other

* Buildings in relations did not have the `roof:shape` chooser.
* A warning when you've downloaded too much elements.
* Changes are split in groups for uploading if possible.
* Added a hint on how to undo a change.
* Complete Ukrainian (by T.H.), Chinese Simplified (by Oil\_Station),
  and Basque (by Gari Araolaza) translations.

## 0.6

_Released on 2022-06-23_

* Supporting subway entrances.
* Long tap on the crosshair did not work in the entrances mode.
* Button to open an object's history (thanks @GeorgeHoneywood).
* Non-https URLs failed to open from the editor.
* Removed generic presets like `shop=*` from the preset chooser.
* Combo options are sorted by popularity in downloaded data.
* Combo fields now look the same as radio fields.
* Fixed geolocation exception on the first run on iOS.
* Complete Polish (by @strebski) and Spanish translation (by @franco999).

## 0.5

_Released on 2022-06-20_

### Highlights

* Keeping the map big when there's enough space for POI tiles.
* Added Maxar Premium Imagery.
* When adding multiple objects of the same type,
  copying tags from the last one.
* Warning about a possible duplicate when adding a new amenity.
* Many, many new translations — thanks folks, and thanks to Weblate.

### Editor

* Preventing deletion of nodes that are relation members.
* Editor pane now shows location even when you cannot move the POI.
* Removed the "inactive" button for new non-amenities.
* Addresses from new amenities are included in the chooser.
* Keeping values with semicolons for `voltage` options.
* Presenting 250 top values for `payment:*` and `craft` keys.

### Entrances Mode

* Quick fix for the entrances mode when the map is rotated:
  not asking for options then.
* Fixed dragging entrances onto the map when the map is rotated.
* Not asking for a roof shape if there are `building:part`s.
* Not allowing the "address" option on polygonal buildings.
* Removed question mark from some types of unaddressed buildings.

### Other

* OpenStreetMap layer zoom 19 is back.
* Increased minimum rotation angle to 30° to make disabling it easier.
* Long tap the crosshair button to reset rotation.
* Fixed type list flicker because of defaults loading slowly.
* Better ordering for choosing the best preset for an object.
* Imagery list in Settings was refreshing constantly.
* Attribution is not rotated with the map now.
* Labels for U-shaped buildings are positioned on buildings.
* Temporary (?) option in Settings to disable Google location services.

## 0.4

_Released on 2022-05-22_

* Redesigned app navigation (thanks Alexey A for ideas).
* Default locale is English now.
* Fixed issue with storing default payment tags.
* Added zooming buttons to the map when adding an object.
* Added (black) entrances to that map as well.
* Moved `tourism=picnic_site` to the micromapping mode.
* For `shop=yes`, displaying `shop` in a tile, not `yes`.
* Objects with `club=*` did not register and were not uploaded.
* When snapping a new point to a way failed, adding a `fixme` tag to it.
* Added API status panel to entrances and micromapping modes.
* Drawing much more objects on the map for micromapping.
* Fixed the placeholder API error when updating a building
  after adding an entrance to it.
* Maps can be rotated now.
* Improved sorting in the imagery list.
* Italian translation by @ricloy.
* French translation by @paulhenry46.

### Editor

* Added current values to combo options.
* Increased the number of options to 50 for combo panels.
* Case-insensitive search on the combo page.
* Fixed parsing `Su off` in opening hours.
* For the phone field, validation message is yellow, since it's informational.
* Social media tag values are now clickable when they are not in an URL form.
* Proper keyboard replacement for `ref` and other numeric fields.
* Changed the icon for the tags panel.
* Replaced the plus icon with a checkmark for phone and website fields.
* Moving standard fields to the icon labels block.
* Returned the big green "Save" button.

### Entrances Mode

* Allowing addresses with no street, and fixed removing house numbers.
* Added the address form to entrances (click on `+ADDR` button).
* Added a button for opening an editor for an entrance.
* Tapping away from a building / entrance form saves the edits.
* Choose "address" building type to add a building-less address.

## 0.3

_Released on 2022-05-09_

* Made the saving button into a small floating one.
* Swapped tracking and mode changing buttons.
* Road names in address forms are also taken from highways.
* Combo options are now not limited to a preset list.
* Removed the setting for `contact:` prefixes.
* Enabled opening links and phone numbers from the editor.
* Long tap on the sharing button on the tags panel to copy the link.
* Added missing translations for the entrances mode.
* Sped up storing elements to the database slightly.
* Displaying all alternative points on the map, not just modified.
* Option to move buttons from right to left.
* Added safe areas to layout.
* Finally caught the offset issue when dragging entrances onto the map.
* Fixed offset in numbers on the map.

## 0.2

_Released on 2022-05-03_

* **First public version.**
* Patched `ref`s to be numbers.
* Allowing floors without addresses.
* Removed closed barrier ways and modified roads from the map.
* Won't allow free-form keys that are not popular enough.
* Enforced maximal value length of 255 characters.
* Added sharing button to the raw tags panel.
* Adding `opening_hours` field if an amenity preset doesn't have one.

## 0.1.13

_Released on 2022-05-01_

* Name supports multiple languages now.
* Added "Move" label to the map in the amenity editor.
* White dots in micromapping denote missing major attributes.
* Fixed micromapping crossings and barriers.
* Fixed duplicates in the types list.
* Enlarged hit boxes for building entrances.
* Added a yellow dot to the map chooser for better visibility over dark background.

## 0.1.12

_Released on 2022-04-30_

* Tap on the editor app bar title to change the amenity type.
* Fixed error on submitting a value in a single-value combobox.
* Fixed error catching on async exceptions.
* Disabled editing floors for POI on building contours.
* In the location chooser for a new object, filtering objects by type.
* Added `barrier=*` to micromapping types.
* Once more reduced "big map" distance in the amenity mode.
* Map shows modified objects from other modes, just in case.
* Zoom buttons for the map.

## 0.1.11

_Released on 2022-04-27_

* German translation complete, thanks to @mfbehrens99.
* Fixed an error when upgrading database.
* Made labels column in the floor editor a bit wider.
* Forgot some translations.

## 0.1.10

_Released on 2022-04-27_

* System logs can be sent to the author (tap the version in settings).
* When the database is broken, the app recreates it.
* More roof shapes.
* Option to store flat number for an entrance in `addr:unit`.
* Translated everything.

## 0.1.9

_Released on 2022-04-26_

* Better sorting in the micromapping legend, and a label for "Other".
* Exception catching on loading changes.
* More translated strings.

## 0.1.8

_Released on 2022-04-25_

* Mode switching button is now on the main screen.
* Micromapping mode now has coloured dots instead of tiles and numbers.
* Added app version to the settings screen.
* Fixed location scopes in the app.
* Made hint labels lighter in text fields.
* Button in hours editor to use the most common value from around.
* For a list of default presets, also considering last used presets
  and types of objects around.
* Button to delete all downloaded data in settings.
* Increased re-check interval to 2 weeks.
* Support for landscape screen orientation.
* Fixed a possible deadlock on the loading screen.

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

* First internal testing version.
