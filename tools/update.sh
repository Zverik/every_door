#!/bin/bash
set -e -u -o pipefail
[ $# -lt 1 ] && echo "Usage: $0 <taginfo-db.db> [<path_to_git_repos>]" && exit 1

HERE="$(dirname "$0")"
ASSETS="$HERE/../assets"
PRESETS_DB="$ASSETS/presets.db"
PRESETS_ZIP="$ASSETS/presets.gz"
NSI_FEATURES="$HERE/../lib/helpers/nsi_features.dart"

TAGINFO_DB="$1"
[ ! -e "$TAGINFO_DB" ] && echo "Could not open $TAGINFO_DB" && exit 2

GIT_PATH="${2-}"
if [ -n "$GIT_PATH" ]; then
  [ ! -d "$GIT_PATH/id-tagging-schema" ] && echo "Could not find $GIT_PATH/id-tagging-schema" && exit 2
  [ ! -d "$GIT_PATH/name-suggestion-index" ] && echo "Could not find $GIT_PATH/name-suggestion-index" && exit 2
  [ ! -d "$GIT_PATH/editor-layer-index" ] && echo "Could not find $GIT_PATH/editor-layer-index" && exit 2
fi

if [ ! -d "$HERE/venv" ]; then
  python3 -m venv "$HERE/venv"
  "$HERE/venv/bin/pip" install -r "$HERE/requirements.txt"
fi
PYTHON="$HERE/venv/bin/python"

mkdir -p "$ASSETS"
rm -f "$PRESETS_DB" "$PRESETS_ZIP"
"$PYTHON" json_to_sqlite.py "$PRESETS_DB" "$GIT_PATH"
"$PYTHON" add_taginfo.py "$PRESETS_DB" "$TAGINFO_DB"
"$PYTHON" add_imagery.py "$PRESETS_DB" "$GIT_PATH"
# cat "$PRESETS_DB" | gzip > "$PRESETS_ZIP"
# rm "$PRESETS_DB"

if [ -n "$GIT_PATH" ]; then
  cp "$GIT_PATH/name-suggestion-index/dist/featureCollection.min.json" nsi_fc.json
else
  curl -s 'https://raw.githubusercontent.com/osmlab/name-suggestion-index/main/dist/featureCollection.min.json' > nsi_fc.json
fi
echo "const String nsiFeaturesRaw = '''" > "$NSI_FEATURES"
cat nsi_fc.json >> "$NSI_FEATURES"
echo "''';" >> "$NSI_FEATURES"
rm nsi_fc.json
