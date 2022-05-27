# Every Door

The best mobile editor for adding shops and amenities to OpenStreetMap.

Help test it for [iOS](https://testflight.apple.com/join/5138nQCq) and
[Android](https://play.google.com/store/apps/details?id=info.zverev.ilya.every_door).

The roadmap is in [a project](https://github.com/users/Zverik/projects/1/views/2).

## Screenshots
<img src="https://wiki.openstreetmap.org/w/images/4/4c/Every_Door_0.3.0_Android_-_Main_Screen.png" width="170"/> <img src="https://wiki.openstreetmap.org/w/images/a/a3/Every_Door_0.3.0_Android_-_Main_Screen_Library.png" width="170"/> <img src="https://wiki.openstreetmap.org/w/images/f/f7/Every_Door_0.3.0_Android_-_Mode_Features_Near_You.png" width="170"/>

[More screenshots](https://wiki.openstreetmap.org/wiki/Every_Door)

## Presets and Translations

The editor uses [presets from iD](https://github.com/openstreetmap/id-tagging-schema):
they are managed in a dedicated repository and translated on Transifex.

Brands are managed in the [Name Suggestion Index](https://github.com/osmlab/name-suggestion-index).

Help translate the app at [Weblate](https://hosted.weblate.org/projects/every-door/app/). I'm grateful
to them for a libre hosting.

## Design

I need help with design. That includes [a new icon](https://github.com/Zverik/every_door/tree/main/icon),
[the website](https://github.com/Zverik/everydoor-website), Flutter animations for everything,
and general UX improvements. Please help.

## How To Build

You will need the [Flutter SDK](https://docs.flutter.dev/development/tools/sdk/overview) installed.

1. Copy `lib/private.dart.sample` to `lib/private.dart` and put your OAuth2 and Bing keys there.
You can generate OAuth2 keys for the staging API [here](https://master.apis.dev.openstreetmap.org/oauth2/applications/new)
— use `everydoor:/oauth` as the Redirect URI. Note that the staging API uses a different database
to the production API, so you may need to sign up again.
2. Download [taginfo-db.db](https://taginfo.openstreetmap.org/download) and unpack it somewhere (it's ~9 GB).
3. From the `tools` directory, run `./update.sh <path_to_taginfo_db>`.
4. `flutter pub get`.
5. `flutter run`.

## Author and License

The editor was written by © 2022 Ilya Zverev and published under the ISC license.
