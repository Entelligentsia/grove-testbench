#!/usr/bin/env bash
# Render per-side videos from a race's stream-json: synth-cast.py -> agg -> mp4.
# Produces out/<id>.<side>.mp4 for db and dg.
#
# Usage: render.sh <scene-id> [--agent claude] [--out DIR] [--speed 0.45]
#                  [--font-size 24] [--theme dracula]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

AGENT=claude; OUT="$root/out"; SPEED=0.45; FS=24; THEME=dracula; REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2;; --out) OUT="$2"; shift 2;;
    --speed) SPEED="$2"; shift 2;; --font-size) FS="$2"; shift 2;;
    --theme) THEME="$2"; shift 2;; -*) echo "unknown $1">&2; exit 2;;
    *) REPO="$1"; shift;;
  esac
done
[[ -n "$REPO" ]] || { echo "usage: render.sh <scene-id>" >&2; exit 2; }
AGG="${AGG:-$HOME/.local/bin/agg}"
FONT="${FONT:-JetBrainsMono Nerd Font Mono}"
command -v ffmpeg >/dev/null || { echo "ffmpeg required" >&2; exit 1; }
[[ -x "$AGG" ]] || { echo "agg not found at $AGG" >&2; exit 1; }

# language for the header badge (from scenes.yaml, no yaml dep)
LANG_OF="$(python3 - "$REPO" "$root/scenes/scenes.yaml" <<'PY'
import sys,re
repo,path=sys.argv[1],sys.argv[2]; blk=False
for l in open(path):
    m=re.match(r'\s*-\s*id:\s*(\S+)',l)
    if m: blk=(m.group(1)==repo)
    if blk:
        m2=re.match(r'\s*language:\s*(.+)',l)
        if m2: print(m2.group(1).strip()); break
PY
)"

for side in db dg; do
  jsonl="$OUT/$REPO.$AGENT.$side.jsonl"
  [[ -s "$jsonl" ]] || { echo "missing $jsonl (run-race first)" >&2; exit 1; }
  cast="$OUT/$REPO.$side.cast"; gif="$OUT/$REPO.$side.gif"; mp4="$OUT/$REPO.$side.mp4"
  python3 "$here/synth-cast.py" --jsonl "$jsonl" --out "$cast" \
    --repo "$REPO" --lang "$LANG_OF" --side "$side" \
    --prompt-file "$root/scenes/$REPO.prompt.txt" --speed "$SPEED"
  "$AGG" --font-family "$FONT" --font-size "$FS" --theme "$THEME" "$cast" "$gif" >/dev/null 2>&1
  # gif -> mp4 (even dimensions for h264)
  ffmpeg -y -loglevel error -i "$gif" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p" "$mp4"
  echo "rendered $mp4"
done
echo "next: scripts/compose.sh $REPO"
