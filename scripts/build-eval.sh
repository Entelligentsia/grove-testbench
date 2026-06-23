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
        db_context:         $s.db.context_tokens,
        dg_context:         $s.dg.context_tokens,
        db_subagent_ctx:    $s.db.subagent_context_tokens,
        dg_subagent_ctx:    $s.dg.subagent_context_tokens,
        db_delegated:       $s.db.delegated,
        dg_delegated:       $s.dg.delegated,
        ctx_delta_pct:      $d.context,
        ctx_winner:         $w.context,
        db_time_s:          ($s.db.duration_s | floor),
        dg_time_s:          ($s.dg.duration_s | floor),
        time_winner:        $w.time,
        db_turns:           $s.db.turns,
        dg_turns:           $s.dg.turns,
        db_tools:           $s.db.tool_calls,
        dg_tools:           $s.dg.tool_calls,
        db_parent_tools:    $s.db.parent_tool_calls,
        dg_parent_tools:    $s.dg.parent_tool_calls,
        db_subagent_tools:  $s.db.subagent_tool_calls,
        dg_subagent_tools:  $s.dg.subagent_tool_calls,
        tool_winner:        $w.tool_calls
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
        ctx_db_wins:        ([$rs[] | select(.ctx_winner=="db")] | length),
        ctx_dg_wins:        ([$rs[] | select(.ctx_winner=="dg")] | length),
        ctx_ties:           ([$rs[] | select(.ctx_winner=="tie")] | length),
        time_db_wins:       ([$rs[] | select(.time_winner=="db")] | length),
        time_dg_wins:       ([$rs[] | select(.time_winner=="dg")] | length),
        tools_dg_wins:      ([$rs[] | select(.tool_winner=="dg")] | length),
        tools_db_wins:      ([$rs[] | select(.tool_winner=="db")] | length),
        dg_ctx_wins_on:     [$rs[] | select(.ctx_winner=="dg") | .repo],
        note: "context_tokens sums ALL models incl. subagents. subagent_ctx / delegated / *_subagent_tools decompose the hidden subagent work."
      }
    }' > "$OUTFILE"

echo "wrote $OUTFILE"
jq '.summary' "$OUTFILE"
