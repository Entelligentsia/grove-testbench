#!/usr/bin/env bash
# L4 (subsystem end-to-end) rung, baseline=base vs grove=v0.1.8.
#
# CAREFUL PROTOCOL (L4 is the heaviest rung yet — broad subsystem maps):
#   * ONE PAIR AT A TIME. Strictly serial: each repo's baseline then grove run
#     to completion before the next repo starts. No cross-repo parallelism, so a
#     runaway can never starve a sibling and the box never OOMs.
#   * KNOWN RUNAWAYS LAST. Repos are ordered lean -> heavy; the three that killed
#     the baseline at L3 (bitcoin, typescript, hugo) plus borderline webpack run
#     at the end, so we bank the cheap, reliable cells first.
#   * HARD 1.5 MB CUTOFF = DNF. scripts/l4-watchdog.sh polls each running side's
#     transcript and docker-kills any that crosses MAXBYTES. A killed side has no
#     result event and is reported as a DNF (runaway), not a win/loss.
#
# Scene ids are opt-<repo>-L4_subsystem, reading
# scenes/opt-<repo>-L4_subsystem.prompt.txt. Outputs to out/l4/.
#
# Usage:
#   scripts/l4-watchdog.sh out/l4 &        # arm the runaway guard first
#   scripts/run-l4.sh --all --model sonnet # all 10, lean -> runaway order
#   scripts/run-l4.sh --repos 'redis tokio' --model sonnet
#   scripts/run-l4.sh --dry-run --all
#
# Env: CLAUDE_CREDS (default ~/.claude/.credentials.json) must exist & be valid.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

MODEL=""
OUT="$root/out/l4"
# lean -> heavy. bitcoin/typescript/hugo killed the L3 baseline; webpack was
# borderline (1.54 MB). Bank the cheap reliable cells first, runaways last.
ALL_REPOS="laravel django spring-boot redis rails tokio webpack bitcoin typescript hugo"
REPOS="$ALL_REPOS"
BASELINE_IMG="grove-testbench/base:latest"
GROVE_IMG="grove-testbench/grove:v0.1.9"
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

installed_ver="$(docker run --rm "$GROVE_IMG" grove --version 2>/dev/null || echo '?')"
echo "=== L4_subsystem · grove $GROVE_IMG ($installed_ver) · baseline $BASELINE_IMG ==="
echo "    out dir: $OUT"
echo "    order:   $REPOS   (serial, one pair at a time)"
[[ "$installed_ver" == "grove 0.1.8" ]] || echo "WARN: $GROVE_IMG is '$installed_ver', not grove 0.1.8" >&2
mkdir -p "$OUT"

MODEL_ARG=(); [[ -n "$MODEL" ]] && MODEL_ARG=(--model "$MODEL")
RUNLOG="$OUT/run.log"; : > "$RUNLOG"

if [[ "$DRY" == 1 ]]; then
  for repo in $REPOS; do
    scene="opt-$repo-L4_subsystem"
    prompt="$root/scenes/$scene.prompt.txt"
    [[ -f "$prompt" ]] && echo "  [dry-run] $scene  (prompt OK)" \
                       || echo "  [dry-run] $scene  MISSING PROMPT $prompt"
  done
  exit 0
fi

for repo in $REPOS; do
  scene="opt-$repo-L4_subsystem"
  prompt="$root/scenes/$scene.prompt.txt"
  [[ -f "$prompt" ]] || { echo "skip $repo: no prompt $prompt" | tee -a "$RUNLOG" >&2; continue; }
  echo "=== [$repo] serial pair start ===" | tee -a "$RUNLOG"
  {
    bash "$here/run-race.sh" "$scene" --repo-name "$repo" \
         --baseline "$BASELINE_IMG" --grove "$GROVE_IMG" \
         --out "$OUT" "${MODEL_ARG[@]}"
    bash "$here/extract-metrics.sh" "$scene" --out "$OUT"
  } >"$OUT/$scene.run.log" 2>&1
  echo "--- [$repo] done ---" | tee -a "$RUNLOG"
  tail -4 "$OUT/$scene.run.log" 2>/dev/null | sed 's/^/    /'
done

echo | tee -a "$RUNLOG"
echo "=== L4 summary ===" | tee -a "$RUNLOG"
echo "metrics: $OUT/opt-*-L4_subsystem.claude.metrics.json" | tee -a "$RUNLOG"
