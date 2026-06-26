#!/usr/bin/env bash
# Harvest and compress JSONL transcripts from an eval round into evidence/.
#
# Usage:
#   scripts/harvest-transcripts.sh <round>              # out/<round>/ → evidence/transcripts/<round>/
#   scripts/harvest-transcripts.sh <round> --src <dir>  # explicit source dir
#   scripts/harvest-transcripts.sh r1 --src out         # flat top-level (old db/dg runs)
#
# Writes:
#   evidence/transcripts/<round>/<scene>.<agent>.<side>.jsonl.gz
#   evidence/transcripts/<round>/<scene>.<agent>.metrics.json   (verbatim, already small)
#   evidence/transcripts/<round>/<scene>.<agent>.run.log        (verbatim, already small)
#
# After running, git-add evidence/transcripts/<round>/ and commit.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

ROUND=""
SRC=""
DEST=""
DRY=0
while [[ $# -gt 0 ]]; do case "$1" in
  --src)    SRC="$2"; shift 2 ;;
  --dest)   DEST="$2"; shift 2 ;;
  --dry-run) DRY=1; shift ;;
  -*)       echo "unknown flag: $1" >&2; exit 2 ;;
  *)        ROUND="$1"; shift ;;
esac; done

[[ -n "$ROUND" ]] || { echo "usage: harvest-transcripts.sh <round> [--src <dir>] [--dest <dir>]" >&2; exit 2; }
SRC="${SRC:-$root/out/$ROUND}"
DEST="${DEST:-$root/evidence/transcripts/$ROUND}"

[[ -d "$SRC" ]] || { echo "source dir not found: $SRC" >&2; exit 1; }

jsonl_count=$(find "$SRC" -maxdepth 1 -name "*.jsonl" | wc -l)
[[ "$jsonl_count" -gt 0 ]] || { echo "no .jsonl files in $SRC" >&2; exit 1; }

echo "harvesting round '$ROUND'"
echo "  src:  $SRC  ($jsonl_count JSONL files)"
echo "  dest: $DEST"
[[ "$DRY" == 1 ]] && echo "  [dry-run — no files written]"
echo

[[ "$DRY" == 1 ]] || mkdir -p "$DEST"

total_in=0; total_out=0; count=0
while IFS= read -r f; do
  base="$(basename "$f")"
  dest_file="$DEST/${base}.gz"
  sz_in=$(stat -c%s "$f")
  total_in=$((total_in + sz_in))
  if [[ "$DRY" == 1 ]]; then
    echo "  [dry] gzip $base → ${base}.gz"
  else
    gzip -9 -c "$f" > "$dest_file"
    sz_out=$(stat -c%s "$dest_file")
    total_out=$((total_out + sz_out))
    pct=$(( (sz_in - sz_out) * 100 / sz_in ))
    printf "  %-60s %5dK → %4dK  (-%d%%)\n" "$base" "$((sz_in/1024))" "$((sz_out/1024))" "$pct"
  fi
  count=$((count + 1))
done < <(find "$SRC" -maxdepth 1 -name "*.jsonl" | sort)

# Copy small companion files verbatim
for ext in metrics.json run.log; do
  while IFS= read -r f; do
    base="$(basename "$f")"
    if [[ "$DRY" == 1 ]]; then
      echo "  [dry] copy $base"
    else
      cp "$f" "$DEST/$base"
    fi
  done < <(find "$SRC" -maxdepth 1 -name "*.$ext" | sort)
done

if [[ "$DRY" == 0 && "$total_in" -gt 0 ]]; then
  pct_total=$(( (total_in - total_out) * 100 / total_in ))
  echo
  echo "done: $count JSONL files  ${total_in}B → ${total_out}B  (-${pct_total}%)"
  echo "      $DEST"
  echo
  echo "next: git add evidence/transcripts/$ROUND && git commit"
fi
