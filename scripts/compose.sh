#!/usr/bin/env bash
# Compose the side-by-side race video from the two per-side mp4s (render.sh):
# db (grove OFF) left, dg (grove ON) right, started together, each frozen on its
# last frame until the slower side finishes — so the faster side visibly "wins".
# Adds a top title bar (repo + prompt) and a bottom result banner.
#
# Usage: compose.sh <scene-id> [--out DIR]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
OUT="$root/out"; REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in --out) OUT="$2"; shift 2;; -*) echo "unknown $1">&2; exit 2;; *) REPO="$1"; shift;; esac
done
[[ -n "$REPO" ]] || { echo "usage: compose.sh <scene-id>" >&2; exit 2; }
db="$OUT/$REPO.db.mp4"; dg="$OUT/$REPO.dg.mp4"
[[ -s "$db" && -s "$dg" ]] || { echo "missing per-side mp4s; run render.sh first" >&2; exit 1; }
metrics="$OUT/$REPO.claude.metrics.json"
out="$OUT/$REPO.race.mp4"

dur() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }
ddb="$(dur "$db")"; ddg="$(dur "$dg")"
maxd="$(python3 -c "print(max($ddb,$ddg)+1.5)")"

# result banner text from metrics (winner on tokens/time/turns)
banner="grove race"
if [[ -s "$metrics" ]]; then
  banner="$(python3 - "$metrics" <<'PY'
import sys,json
m=json.load(open(sys.argv[1])); w=m.get("winner",{}); d=m.get("delta_pct",{})
keys=("context","time","tool_calls","turns")
def f(k):
    v=d.get(k)
    return f"{k} {v:+.0f}%" if isinstance(v,(int,float)) else k
wins=sum(1 for k in keys if w.get(k)=="dg")
print(f"grove wins {wins}/4   ·   "+"  ".join(f(k) for k in ("context","time","tool_calls")))
PY
)"
fi

# Pad each side to maxd (freeze last frame so the faster side waits, visibly
# "winning"), then stack with a thin divider. (drawtext is unavailable in this
# ffmpeg build; the per-side headers already label grove ON/OFF + repo + prompt,
# and the metrics ticker is in each pane. Title/result CARDS are added by
# cards.sh as separate clips.)
ffmpeg -y -loglevel error \
  -i "$db" -i "$dg" \
  -filter_complex "\
    [0:v]tpad=stop_mode=clone:stop_duration=$maxd,trim=duration=$maxd,setpts=PTS-STARTPTS,pad=iw+3:ih:0:0:color=0x444455[L];\
    [1:v]tpad=stop_mode=clone:stop_duration=$maxd,trim=duration=$maxd,setpts=PTS-STARTPTS[R];\
    [L][R]hstack=inputs=2,format=yuv420p[v]" \
  -map "[v]" -r 24 "$out"
echo "composed -> $out"
echo "duration: $(dur "$out")s"
echo "result: $banner"
