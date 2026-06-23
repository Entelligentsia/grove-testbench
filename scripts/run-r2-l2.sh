#!/usr/bin/env bash
# R2 (round 2) L2_callsites re-run using the **v0.1.7** official release, which
# ships all four fixes from R1 friction: GI-1 (off-by-one lines / #31), GI-5
# (generated-decl files / #32), GI-6 (callers recall / #33), GI-3 (over-read /
# #34). Tier-1 probes already confirmed all four pass in the all-fixes-r2 image;
# v0.1.7 is the same content as an official release.
#
# R1 outputs live in out/opt-<repo>-L2_callsites.claude.{db,dg}.jsonl;
# R2 writes to out/r2-l2/ so R1 is preserved for side-by-side comparison.
#
# Priority repos — repos where grove underperformed baseline in R1 (context:
# dg > db), ordered by delta magnitude:
#   rails      +132.5%  (GI-1 fix expected to help — callers over-expanded)
#   redis       +52.8%  (GI-1 + GI-3 fixes)
#   laravel     +14.9%  (GI-1 fix)
#   django       +2.0%  (GI-1 + GI-6 fixes)
# The well-performing repos (hugo, tokio, typescript, spring-boot, webpack,
# bitcoin) are included for completeness but are lower priority.
#
# Usage:
#   scripts/run-r2-l2.sh                               # priority-4 repos only
#   scripts/run-r2-l2.sh --all                         # all 10 repos
#   scripts/run-r2-l2.sh --model sonnet                # pin a model (recommended)
#   scripts/run-r2-l2.sh --repos 'redis rails'         # explicit subset
#   scripts/run-r2-l2.sh --dry-run                     # print commands, don't run
#
# Env: CLAUDE_CREDS (default ~/.claude/.credentials.json) must exist.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

MODEL=""
OUT="$root/out/r2-l2"
# Default: only the repos where grove underperformed in R1
REPOS="rails redis laravel django"
ALL_REPOS="rails redis laravel django hugo tokio typescript spring-boot webpack bitcoin"
BASELINE_IMG="grove-testbench/base:latest"
GROVE_IMG="grove-testbench/grove:v0.1.7-r2"
DRY=0
while [[ $# -gt 0 ]]; do case "$1" in
  --model)    MODEL="$2"; shift 2 ;;
  --out)      OUT="$2"; shift 2 ;;
  --repos)    REPOS="$2"; shift 2 ;;
  --all)      REPOS="$ALL_REPOS"; shift ;;
  --baseline) BASELINE_IMG="$2"; shift 2 ;;
  --grove)    GROVE_IMG="$2"; shift 2 ;;
  --dry-run)  DRY=1; shift ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;; esac; done

command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }
CREDS="${CLAUDE_CREDS:-$HOME/.claude/.credentials.json}"
[[ -f "$CREDS" ]] || { echo "missing Claude creds: $CREDS (set CLAUDE_CREDS)" >&2; exit 1; }

installed_ver="$(PATH=/tmp/grove-podman-shim:$PATH podman run --rm "$GROVE_IMG" grove --version 2>/dev/null || echo '?')"
echo "=== R2 L2_callsites · grove image $GROVE_IMG ($installed_ver) · baseline $BASELINE_IMG ==="
echo "    out dir: $OUT"
echo "    repos:   $REPOS"
[[ "$installed_ver" == "grove 0.1.7" ]] || { echo "WARN: $GROVE_IMG is '$installed_ver', not grove 0.1.7" >&2; }
mkdir -p "$OUT"

MAXP="${MAXP:-5}"
MODEL_ARG=(); [[ -n "$MODEL" ]] && MODEL_ARG=(--model "$MODEL")

if [[ "$DRY" == 1 ]]; then
  for repo in $REPOS; do
    scene="opt-$repo-L2_callsites"
    echo "  [dry-run] run-race.sh $scene --baseline $BASELINE_IMG --grove $GROVE_IMG --out $OUT ${MODEL_ARG[*]:-}"
    echo "  [dry-run] extract-metrics.sh $scene --out $OUT"
  done
else
  # Run all repos in parallel, throttled to MAXP concurrent races.
  # Each race (baseline + grove sequentially) logs to out/r2-l2/<scene>.run.log.
  declare -a launched=()
  for repo in $REPOS; do
    scene="opt-$repo-L2_callsites"
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
  echo "waiting for ${#launched[@]} races (MAXP=$MAXP)..."
  wait
  echo
  for repo in "${launched[@]}"; do
    scene="opt-$repo-L2_callsites"
    echo "--- $repo ---"
    tail -5 "$OUT/$scene.run.log" 2>/dev/null
  done
fi

echo
echo "=== R2 L2 summary ==="
echo "metrics: $OUT/opt-*.claude.metrics.json"
echo "compare with R1: out/opt-<repo>-L2_callsites.claude.metrics.json"
echo "priority repos (R1 underperformers): rails redis laravel django"