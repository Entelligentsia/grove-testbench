#!/usr/bin/env bash
# Run ONE rung across many repos in parallel, then extract metrics for each.
# Usage: run-rung-parallel.sh <RUNG> <model> <repo> [<repo> ...]
#   expects scenes/opt-<repo>-<RUNG>.prompt.txt to exist per repo.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNG="$1"; MODEL="$2"; shift 2
repos=("$@")

echo "=== parallel rung $RUNG across: ${repos[*]} (model $MODEL) ==="
pids=()
for r in "${repos[@]}"; do
  sid="opt-$r-$RUNG"
  ( "$here/run-race.sh" "$sid" --repo-name "$r" --model "$MODEL" >"$here/../out/$sid.run.log" 2>&1 ) &
  pids+=("$!")
  echo "launched $r (pid $!)"
done

echo "waiting for ${#pids[@]} races..."
fail=0
for p in "${pids[@]}"; do wait "$p" || fail=$((fail+1)); done
echo "races done (failures: $fail). extracting metrics..."

for r in "${repos[@]}"; do
  "$here/extract-metrics.sh" "opt-$r-$RUNG" >/dev/null 2>&1 || echo "  ! metrics failed: $r"
done
echo "ALL DONE: $RUNG"
