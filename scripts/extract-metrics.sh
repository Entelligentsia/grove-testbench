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
  local tool_calls
  tool_calls="$(jq -s '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="tool_use")] | length' "$jsonl")"
  jq -n \
    --argjson grove "$grove" \
    --argjson tc "${tool_calls:-0}" \
    --argjson r "$result" '
    ($r.usage // {}) as $u
    | ($u.input_tokens // 0) as $in
    | ($u.output_tokens // 0) as $out
    | ($u.cache_read_input_tokens // 0) as $cr
    | ($u.cache_creation_input_tokens // 0) as $cc
    | {
        grove: $grove, present: true,
        input_tokens: $in, output_tokens: $out,
        cache_read_tokens: $cr, cache_creation_tokens: $cc,
        # context = everything FED to the model (grove keeps this small by not
        # dumping whole files). With prompt caching, raw input_tokens ~ 0, so the
        # meaningful "tokens" comparison is the context, NOT input+output.
        context_tokens: ($in + $cr + $cc),
        output_tokens_only: $out,
        total_tokens: ($in + $cr + $cc + $out),
        turns: ($r.num_turns // 0),
        tool_calls: $tc,
        duration_ms: ($r.duration_ms // 0),
        duration_s: (($r.duration_ms // 0) / 1000),
        cost_usd: ($r.total_cost_usd // 0)
      }'
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
