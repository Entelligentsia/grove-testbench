#!/usr/bin/env bash
# Run ONE rung across many repos, throttled to MAXP concurrent races, then
# extract metrics for each. Each race itself runs db then dg sequentially, so
# MAXP concurrent races == MAXP containers at peak. Keep MAXP small: each claude
# container is ~0.5GB, and 20 at once OOMs a 16GB box.
# Usage: MAXP=4 run-rung-parallel.sh <RUNG> <model> <repo> [<repo> ...]
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNG="$1"; MODEL="$2"; shift 2
repos=("$@")
MAXP="${MAXP:-4}"

echo "=== rung $RUNG across: ${repos[*]} (model $MODEL, MAXP=$MAXP) ==="
fail=0
for r in "${repos[@]}"; do
  # throttle: wait until fewer than MAXP background jobs are running
  while [[ "$(jobs -rp | wc -l)" -ge "$MAXP" ]]; do wait -n 2>/dev/null || true; done
  sid="opt-$r-$RUNG"
  ( "$here/run-race.sh" "$sid" --repo-name "$r" --model "$MODEL" >"$here/../out/$sid.run.log" 2>&1 ) &
  echo "launched $r (pid $!)"
done

echo "waiting for remaining races..."
wait
echo "races done. extracting metrics..."

for r in "${repos[@]}"; do
  "$here/extract-metrics.sh" "opt-$r-$RUNG" >/dev/null 2>&1 || echo "  ! metrics failed: $r"
done
echo "ALL DONE: $RUNG"
