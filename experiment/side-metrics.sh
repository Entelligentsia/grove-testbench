#!/usr/bin/env bash
# Per-side metrics + engagement signals from ONE side's stream-json transcript.
# Pure jq + grep; no tokens. Emits a single JSON object for /runarm to consume,
# both for the verification gate (engagement, no harness error) and for recording
# metrics via statectl.
#
#   context_tokens : input+cache_read+cache_creation summed over ALL models
#                    (modelUsage in the result event — includes subagents)
#   has_result     : completed cleanly (not a DNF)
#   eacces         : count of the session-env Bash bug signal (must be 0)
#   bash_calls/reads/grove_tools/mcp_nongrove_tools : engagement, per arm
#
# Usage: experiment/side-metrics.sh <transcript.jsonl>
set -uo pipefail
f="${1:?usage: side-metrics.sh <transcript.jsonl>}"
[[ -f "$f" ]] || { echo "{\"error\":\"no such file: $f\"}"; exit 1; }

# grep -c prints the count AND exits 1 when 0 matches; `|| true` keeps the "0"
# without the echo doubling it. Default to 0 if grep produced nothing.
eacces=$(grep -c 'session-env' "$f" 2>/dev/null || true); eacces=${eacces:-0}

jq -s --argjson eacces "$eacces" '
  (map(select(.type=="result"))[0]) as $r
  | [ .[] | select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") ] as $tu
  | {
      has_result:     ($r != null),
      context_tokens: ([ ($r.modelUsage // {}) | to_entries[]
                         | (.value.inputTokens + .value.cacheReadInputTokens + .value.cacheCreationInputTokens) ] | add // 0),
      duration_s:     (($r.duration_ms // 0) / 1000),
      num_turns:      ($r.num_turns // 0),
      tool_calls:     ($tu | length),
      reads:          ([ $tu[] | select(.name=="Read") ] | length),
      bash_calls:     ([ $tu[] | select(.name=="Bash") ] | length),
      grove_tools:    ([ $tu[] | select(.name | startswith("mcp__grove__")) ] | length),
      mcp_nongrove_tools: ([ $tu[] | select((.name | startswith("mcp__")) and (.name | startswith("mcp__grove__") | not)) ] | length),
      eacces:         $eacces
    }
' "$f"
