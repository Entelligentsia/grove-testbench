#!/usr/bin/env bash
# Build evidence/<RUNG>.eval.json from the per-repo metrics files in out/.
#
# This is the aggregate the reports cite. It reads opt-<repo>-<rung>.claude.
# metrics.json (produced by extract-metrics.sh) and emits one row per repo plus
# a summary tally.
#
# context_tokens is the all-models value (incl. subagent work); each row also
# carries the subagent decomposition (subagent_ctx, delegated, parent/
# subagent tool counts). See extract-metrics.sh for the metric definition.
#
# Usage: build-eval.sh <rung-id> <repo> [<repo> ...]   (writes evidence/<rung>.eval.json)
#   <rung-id> e.g. L2_callsites  ->  evidence/L2_callsites.eval.json  (note: the
#   existing file is named L2.eval.json for the L2 rung; pass --out to override).
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
OUT="$root/out"; EVID="$root/evidence"
RUNG=""; OUTFILE=""; REPOS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUTFILE="$2"; shift 2 ;;
    -*)    echo "unknown $1" >&2; exit 2 ;;
    *)     if [[ -z "$RUNG" ]]; then RUNG="$1"; else REPOS+=("$1"); fi; shift ;;
  esac
done
[[ -n "$RUNG" && ${#REPOS[@]} -gt 0 ]] || { echo "usage: build-eval.sh <rung-id> <repo>..." >&2; exit 2; }
[[ -n "$OUTFILE" ]] || OUTFILE="$EVID/$RUNG.eval.json"
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

rows=()
for r in "${REPOS[@]}"; do
  m="$OUT/opt-$r-$RUNG.claude.metrics.json"
  [[ -s "$m" ]] || { echo "  ! missing $m" >&2; continue; }
  rows+=("$(jq -c --arg repo "$r" '
    .sides as $s
    | .delta_pct as $d
    | .winner as $w
    | {
        repo: $repo,
        baseline_context:         $s.baseline.context_tokens,
        grove_context:            $s.grove.context_tokens,
        baseline_subagent_ctx:    $s.baseline.subagent_context_tokens,
        grove_subagent_ctx:       $s.grove.subagent_context_tokens,
        baseline_delegated:       $s.baseline.delegated,
        grove_delegated:          $s.grove.delegated,
        ctx_delta_pct:            $d.context,
        ctx_winner:               $w.context,
        baseline_time_s:          ($s.baseline.duration_s | floor),
        grove_time_s:             ($s.grove.duration_s | floor),
        time_winner:              $w.time,
        baseline_turns:           $s.baseline.turns,
        grove_turns:              $s.grove.turns,
        baseline_tools:           $s.baseline.tool_calls,
        grove_tools:              $s.grove.tool_calls,
        baseline_parent_tools:    $s.baseline.parent_tool_calls,
        grove_parent_tools:       $s.grove.parent_tool_calls,
        baseline_subagent_tools:  $s.baseline.subagent_tool_calls,
        grove_subagent_tools:     $s.grove.subagent_tool_calls,
        tool_winner:              $w.tool_calls
      }' "$m")")
done

rows_arr="$(printf '%s\n' "${rows[@]}" | jq -s '.')"
jq -n --arg rung "$RUNG" --arg model "sonnet" --arg grove "fixed (post-#31)" \
  --argjson rs "$rows_arr" '
  $rs as $rs
  | {
      rung: $rung, model: $model, grove: $grove,
      repos: $rs,
      summary: {
        ctx_baseline_wins:  ([$rs[] | select(.ctx_winner=="baseline")] | length),
        ctx_grove_wins:     ([$rs[] | select(.ctx_winner=="grove")] | length),
        ctx_ties:           ([$rs[] | select(.ctx_winner=="tie")] | length),
        time_baseline_wins: ([$rs[] | select(.time_winner=="baseline")] | length),
        time_grove_wins:    ([$rs[] | select(.time_winner=="grove")] | length),
        tools_grove_wins:   ([$rs[] | select(.tool_winner=="grove")] | length),
        tools_baseline_wins:([$rs[] | select(.tool_winner=="baseline")] | length),
        grove_ctx_wins_on:  [$rs[] | select(.ctx_winner=="grove") | .repo],
        note: "context_tokens sums ALL models incl. subagents. subagent_ctx / delegated / *_subagent_tools decompose the hidden subagent work."
      }
    }' > "$OUTFILE"

echo "wrote $OUTFILE"
jq '.summary' "$OUTFILE"
