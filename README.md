# Every Door

The best mobile editor for adding shops and amenities to OpenStreetMap.

## How To Build

1. Copy `lib/private.dart.sample` to `lib/private.dart` and write your OAuth and Bing keys there.
2. Download [taginfo-db.db](https://taginfo.openstreetmap.org/download) and unpack it somewhere (it's ~9 GB).
3. Run `tools/update.sh <path_to_taginfo_db>`.
4. `flutter pub get`.
5. `flutter run`.
