#!/usr/bin/env bash
# Turn a race's headless stream-json into a metrics JSON for the results card.
# Source = the metrics pass from run-race.sh (`claude -p --output-format
# stream-json`), which carries exact usage in its final "result" event.
#
# Usage: extract-metrics.sh <scene-id> [--agent claude] [--out DIR]
#
# Reads (from --out):
#   <id>.<agent>.db.jsonl   (grove OFF stream-json)
#   <id>.<agent>.dg.jsonl   (grove ON  stream-json)
# Writes:
#   <id>.<agent>.metrics.json
#
# Metrics (lower is better): tokens (input+output), time (duration_ms),
# tool_calls, turns.
#
# Context accounting:
#   `context_tokens` (and input/cache/output) sum across ALL models in the
#   result event's `modelUsage` — the SDK's per-model cumulative billing source
#   of truth. This counts subagent work too: Agent/Task/Explore subagents run on
#   a different model than the orchestrator (e.g. claude-haiku or another
#   claude-sonnet instance), so their token cost lives in modelUsage under a
#   separate key. Summing all models gives the true tokens the agent *system*
#   ingested. `tool_calls` already counts subagent calls; context now matches
#   that scope, and `cost_usd` (total_cost_usd) already summed all models.
#   The decomposition is exposed as `orchestrator_context_tokens` (parent only) and
#   `subagent_context_tokens` (= context − orchestrator), plus `delegated`,
#   `parent_tool_calls`, `subagent_tool_calls` (linked via the transcript's
#   parent_tool_use_id / subagent_type fields).
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
AGENT=claude
OUT="$root/out"
REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --out)   OUT="$2"; shift 2 ;;
    -*)      echo "unknown flag: $1" >&2; exit 2 ;;
    *)       REPO="$1"; shift ;;
  esac
done
[[ -n "$REPO" ]] || { echo "usage: extract-metrics.sh <scene-id> [--agent claude]" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

parse_side() {
  local side="$1" grove="$2"
  local jsonl="$OUT/$REPO.$AGENT.$side.jsonl"
  if [[ ! -s "$jsonl" ]]; then
    jq -n --argjson grove "$grove" '{grove:$grove, present:false}'
    return
  fi
  local result; result="$(jq -c 'select(.type=="result")' "$jsonl" | tail -n1)"
  [[ -n "$result" ]] || result='{}'
  # Slurp the whole transcript once; jq computes tool-call counts AND the
  # delegation breakdown (parent vs subagent) from the parent_tool_use_id /
  # subagent_type linkage fields Claude Code writes on every row.
  local parsed
  parsed="$(jq -s --argjson grove "$grove" --argjson r "$result" '
    . as $all
    | ([$all[] | select(.type=="result")] | last // {}) as $r
    | ($r.usage // {}) as $u
    | ($r.modelUsage // {}) as $mu
    # parent (orchestrator) rows have no parent_tool_use_id
    | ([$all[] | select(.type=="assistant" and (.parent_tool_use_id | not))
             | .message.content[]? | select(.type=="tool_use")] | length) as $parent_tc
    # ids of Agent/Task/TaskCreate tool_uses issued by the PARENT = delegation points
    | ([$all[] | select(.type=="assistant" and (.parent_tool_use_id | not))
             | .message.content[]? | select(.type=="tool_use" and (.name=="Agent" or .name=="Task" or .name=="TaskCreate")) | .id]
       | unique) as $deleg_ids
    # subagent rows carry parent_tool_use_id in $deleg_ids
    | ([$all[] | select(.type=="assistant")
             | select(.parent_tool_use_id as $ptu | $deleg_ids | index($ptu))
             | .message.content[]? | select(.type=="tool_use")] | length) as $sub_tc
    # per-model cumulative context/output (authoritative; covers subagents)
    | ([$mu | to_entries[] | ((.value.inputTokens // 0) + (.value.cacheReadInputTokens // 0) + (.value.cacheCreationInputTokens // 0))] | add // 0) as $true_ctx
    | ([$mu | to_entries[] | (.value.outputTokens // 0)] | add // 0) as $true_out
    | ([$mu | to_entries[] | (.value.inputTokens // 0)] | add // ($u.input_tokens // 0)) as $true_in
    | ([$mu | to_entries[] | (.value.cacheReadInputTokens // 0)] | add // ($u.cache_read_input_tokens // 0)) as $true_cr
    | ([$mu | to_entries[] | (.value.cacheCreationInputTokens // 0)] | add // ($u.cache_creation_input_tokens // 0)) as $true_cc
    # orchestrator-only (the OLD metric; top-level usage = parent cumulative)
    | (($u.input_tokens // 0) + ($u.cache_read_input_tokens // 0) + ($u.cache_creation_input_tokens // 0)) as $orch_ctx
    | {
        grove: $grove, present: true,
        # context = everything FED to the model across ALL models incl. subagents
        # (the honest metric; the old orchestrator-only value is kept below).
        input_tokens: $true_in, output_tokens: $true_out,
        cache_read_tokens: $true_cr, cache_creation_tokens: $true_cc,
        context_tokens: $true_ctx,
        # decomposition of the subagent-accounting fix:
        orchestrator_context_tokens: $orch_ctx,
        subagent_context_tokens: ($true_ctx - $orch_ctx),
        delegated: ($deleg_ids | length > 0),
        parent_tool_calls: $parent_tc,
        subagent_tool_calls: $sub_tc,
        output_tokens_only: $true_out,
        total_tokens: ($true_ctx + $true_out),
        turns: ($r.num_turns // 0),
        tool_calls: ($parent_tc + $sub_tc),
        duration_ms: ($r.duration_ms // 0),
        duration_s: (($r.duration_ms // 0) / 1000),
        cost_usd: ($r.total_cost_usd // 0)
      }' "$jsonl")"
  echo "$parsed"
}

DB_JSON="$(parse_side db false)"
DG_JSON="$(parse_side dg true)"

OUT_FILE="$OUT/$REPO.$AGENT.metrics.json"
jq -n \
  --arg repo "$REPO" --arg agent "$AGENT" \
  --argjson db "$DB_JSON" --argjson dg "$DG_JSON" '
  def win(k):
    if ($db[k] != null and $dg[k] != null)
    then (if $dg[k] < $db[k] then "dg" elif $dg[k] > $db[k] then "db" else "tie" end)
    else null end;
  def delta(k):
    if ($db[k] != null and $dg[k] != null and $db[k] != 0)
    then (((($dg[k] - $db[k]) / $db[k]) * 100) | . * 100 | round / 100)
    else null end;
  {
    repo: $repo, agent: $agent,
    sides: { db: $db, dg: $dg },
    # context winner/delta use context_tokens (all models, incl. subagents).
    winner: {
      context:    win("context_tokens"),
      time:       win("duration_ms"),
      tool_calls: win("tool_calls"),
      turns:      win("turns")
    },
    delta_pct: {
      context:    delta("context_tokens"),
      time:       delta("duration_ms"),
      tool_calls: delta("tool_calls"),
      turns:      delta("turns")
    }
  }' > "$OUT_FILE"

echo "wrote $OUT_FILE"
jq . "$OUT_FILE"
