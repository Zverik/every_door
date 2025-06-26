# Every Door

The best mobile editor for adding shops and amenities to OpenStreetMap.

Help test it for [iOS](https://apps.apple.com/app/every-door/id1621945342) and
Android ([F-Droid](https://f-droid.org/packages/info.zverev.ilya.every_door/), [Google Play](https://play.google.com/store/apps/details?id=info.zverev.ilya.every_door), [GitHub](https://github.com/Zverik/every_door/releases/latest), [Huawei AppGallery](https://appgallery.cloud.huawei.com/app/C109364057)).

The roadmap is in [a project](https://github.com/users/Zverik/projects/1/views/2).

## Screenshots
<img src="https://user-images.githubusercontent.com/25514836/183449814-38caa70f-9fb3-4ccb-b188-d13251b86352.jpg" width="170" alt="Amenity mode"/> <img src="https://user-images.githubusercontent.com/25514836/183450365-fc21e680-168f-479b-9195-0dd77297e47c.jpg" width="170" alt="Editing a library"/> <img src="https://user-images.githubusercontent.com/25514836/183449966-995ad572-b8f4-472b-b958-584f552e8a46.jpg" width="170" alt="Micromapping mode"/>

[More screenshots](https://wiki.openstreetmap.org/wiki/Every_Door)

## Presets and Translations

The editor uses [presets from iD](https://github.com/openstreetmap/id-tagging-schema):
they are managed in a dedicated repository and translated on [Transifex](https://www.transifex.com/openstreetmap/id-editor/translate/#ru/presets/).

To translate value options, first make a pull request to the iD tagging repo
adding desired options, [like here](https://github.com/openstreetmap/id-tagging-schema/blob/main/data/fields/camera/type.json).
Then, when the translation source on Transifex is updated, there will be strings to translate.
[Like here](https://www.transifex.com/openstreetmap/id-editor/translate/#ru/presets/101711314?q=key%3Apresets.fields.camera%2Ftype).

Brands are managed in the [Name Suggestion Index](https://github.com/osmlab/name-suggestion-index).

Help translate the app at [Weblate](https://hosted.weblate.org/projects/every-door/app/). I'm grateful
to them for a libre hosting.

## Design

I need help with design. That includes [a new icon](https://github.com/Zverik/every_door/tree/main/icon),
[the website](https://github.com/Zverik/everydoor-website), Flutter animations for everything,
and general UX improvements. Please help.

### Principles

1. ED displays and edits only tagged nodes and polygons represented with their centerpoints. No roads.
2. ED focuses on surveying: adding and detailing things that you can see around you. Not map maintenance.
3. Fewer buttons and menus: heuristic is preferable to a setting, and every button benefits the surveyor.

## How To Build

You will need the [Flutter SDK](https://docs.flutter.dev/development/tools/sdk/overview) installed.
Alternatively, clone with submodules (`git clone --recursive`) and use `vendor/flutter/bin/flutter`. That
is the preferred way for releases.

1. Download [taginfo-db.db](https://taginfo.openstreetmap.org/download) and unpack it somewhere (it's ~9 GB).
2. From the `tools` directory, run `./update.sh <path_to_taginfo_db>`.
    * Alternatively, do `curl https://textual.ru/presets.db -o assets/presets.db`
3. `echo '{}' > lib/l10n/app_zh.arb` (fixing Dart's localization issues).
4. `dart run build_runner build`
5. `flutter pub get`.
6. `flutter build`.

## Author, License, and Sponsors

The editor was written by Ilya Zverev © 2022-2025 and published under the ISC license.

The author is sponsored by many individual contributors through [GitHub](https://github.com/sponsors/Zverik)
and [Liberapay](https://liberapay.com/zverik). Thank you everybody!

The NLNet Foundation is [sponsoring](https://nlnet.nl/project/EveryDoor/) the development in 2025
through the [NGI Commons Fund](https://nlnet.nl/commonsfund) with funds from the European Commission.

Want to sponsor the development? [Contact Ilya](mailto:ilya@zverev.info) directly or through
[his company](https://avatudkaart.ee/).
