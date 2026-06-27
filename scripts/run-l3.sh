#!/usr/bin/env bash
# L3 (flow-trace) rung across repos, baseline=base vs grove=v0.1.8, throttled.
# Mirrors run-r2-l2.sh but for the L3_flow rung. Scene ids are
# opt-<repo>-L3_flow, reading scenes/opt-<repo>-L3_flow.prompt.txt.
#
# Outputs to out/l3/ (so it never collides with L1/L2 artifacts).
#
# Usage:
#   scripts/run-l3.sh --repos 'redis bitcoin django tokio' --model sonnet
#   scripts/run-l3.sh --all --model sonnet            # all 10 repos
#   scripts/run-l3.sh --rest --model sonnet           # the 6 not in the first subset
#   scripts/run-l3.sh --dry-run --repos 'redis'
#
# Env: CLAUDE_CREDS (default ~/.claude/.credentials.json) must exist & be valid.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

MODEL=""
OUT="$root/out/l3"
SUBSET="redis bitcoin django tokio"                 # high-signal call-chains, run first
REST="hugo typescript webpack spring-boot rails laravel"
ALL_REPOS="redis bitcoin django tokio hugo typescript webpack spring-boot rails laravel"
REPOS="$SUBSET"
BASELINE_IMG="grove-testbench/base:latest"
GROVE_IMG="grove-testbench/grove:v0.1.10"
DRY=0
while [[ $# -gt 0 ]]; do case "$1" in
  --model)    MODEL="$2"; shift 2 ;;
  --out)      OUT="$2"; shift 2 ;;
  --repos)    REPOS="$2"; shift 2 ;;
  --all)      REPOS="$ALL_REPOS"; shift ;;
  --rest)     REPOS="$REST"; shift ;;
  --baseline) BASELINE_IMG="$2"; shift 2 ;;
  --grove)    GROVE_IMG="$2"; shift 2 ;;
  --dry-run)  DRY=1; shift ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;; esac; done

command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }
CREDS="${CLAUDE_CREDS:-$HOME/.claude/.credentials.json}"
[[ -f "$CREDS" ]] || { echo "missing Claude creds: $CREDS (set CLAUDE_CREDS)" >&2; exit 1; }

installed_ver="$(docker run --rm "$GROVE_IMG" grove --version 2>/dev/null || echo '?')"
echo "=== L3_flow · grove $GROVE_IMG ($installed_ver) · baseline $BASELINE_IMG ==="
echo "    out dir: $OUT"
echo "    repos:   $REPOS"
[[ "$installed_ver" == "grove 0.1.8" ]] || echo "WARN: $GROVE_IMG is '$installed_ver', not grove 0.1.8" >&2
mkdir -p "$OUT"

MAXP="${MAXP:-4}"
MODEL_ARG=(); [[ -n "$MODEL" ]] && MODEL_ARG=(--model "$MODEL")

if [[ "$DRY" == 1 ]]; then
  for repo in $REPOS; do
    scene="opt-$repo-L3_flow"
    echo "  [dry-run] run-race.sh $scene --repo-name $repo --baseline $BASELINE_IMG --grove $GROVE_IMG --out $OUT ${MODEL_ARG[*]:-}"
  done
  exit 0
fi

declare -a launched=()
for repo in $REPOS; do
  scene="opt-$repo-L3_flow"
  prompt="$root/scenes/$scene.prompt.txt"
  [[ -f "$prompt" ]] || { echo "skip $repo: no prompt $prompt" >&2; continue; }
  while [[ "$(jobs -rp | wc -l)" -ge "$MAXP" ]]; do wait -n 2>/dev/null || true; done
  (
    bash "$here/run-race.sh" "$scene" --repo-name "$repo" \
         --baseline "$BASELINE_IMG" --grove "$GROVE_IMG" \
         --out "$OUT" "${MODEL_ARG[@]}"
    bash "$here/extract-metrics.sh" "$scene" --out "$OUT"
  ) >"$OUT/$scene.run.log" 2>&1 &
  echo "launched $repo (pid $!)"
  launched+=("$repo")
done
echo "waiting for ${#launched[@]} L3 races (MAXP=$MAXP)..."
wait
echo
for repo in "${launched[@]}"; do
  scene="opt-$repo-L3_flow"
  echo "--- $repo ---"
  tail -4 "$OUT/$scene.run.log" 2>/dev/null
done
echo
echo "=== L3 summary ==="
echo "metrics: $OUT/opt-*-L3_flow.claude.metrics.json"
