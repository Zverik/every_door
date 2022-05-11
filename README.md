# Every Door

The best mobile editor for adding shops and amenities to OpenStreetMap.

Help test it for [iOS](https://testflight.apple.com/join/5138nQCq) and
[Android](https://play.google.com/store/apps/details?id=info.zverev.ilya.every_door).

The roadmap is in [a project](https://github.com/users/Zverik/projects/1/views/2).

## Presets and Translations

The editor uses [presets from iD](https://github.com/openstreetmap/id-tagging-schema):
they are managed in a dedicated repository and translated on Transifex.

Brands are managed in the [Name Suggestion Index](https://github.com/osmlab/name-suggestion-index).

For the time being Every Door localization is contained
[along the code](https://github.com/Zverik/every_door/tree/main/lib/l10n). You can either
make a new ARB file, or wait until I publish the translations to Weblate.

## Design

I need help with design. That includes [a new icon](https://github.com/Zverik/every_door/tree/main/icon),
[the website](https://github.com/Zverik/everydoor-website), Flutter animations for everything,
and general UX improvements. Please help.

## How To Build

1. Copy `lib/private.dart.sample` to `lib/private.dart` and put your OAuth and Bing keys there.
2. Download [taginfo-db.db](https://taginfo.openstreetmap.org/download) and unpack it somewhere (it's ~9 GB).
3. Run `tools/update.sh <path_to_taginfo_db>`.
4. `flutter pub get`.
5. `flutter run`.

## Author and License

The editor was written by © 2022 Ilya Zverev and published under the ISC license.
