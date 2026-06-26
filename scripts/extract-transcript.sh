#!/usr/bin/env bash
# Render a claude stream-json (.jsonl) into a readable transcript:
# the prompt, each assistant text block and tool call in order (tool name +
# a one-line input summary), nested subagent (Task/Agent) tool calls, and the
# final result. Pure jq; no tokens. Companion to extract-metrics.sh.
#
# Usage: extract-transcript.sh <in.jsonl> [> out.md]
set -uo pipefail
f="${1:?usage: extract-transcript.sh <in.jsonl> [prompt-fallback]}"
[[ -f "$f" ]] || { echo "no such file: $f" >&2; exit 1; }
PROMPT_FALLBACK="${2:-}"

jq -rs --arg pf "$PROMPT_FALLBACK" '
  def oneline: tostring | gsub("\n";" ") | if length>160 then .[0:157]+"..." else . end;
  def toolargs($i):
    ( $i.pattern // $i.command // $i.file_path // $i.path // $i.query
      // $i.name_path // $i.symbol // $i.description // ($i|oneline) ) // "" ;

  ( [ .[] | select(.type=="user") | .message.content
      | if type=="string" then . else ([.[]? | select(.type=="text") | .text] | join(" ")) end
      | select(length>0) ] | .[0] ) as $firstprompt
  | "# transcript: " + ((($firstprompt // ($pf | select(length>0))) // "(prompt not in stream)") | oneline) + "\n"
  , ( .[]
      | if .type=="assistant" then
          ( .message.content[]?
            | if .type=="text" and (.text|length>0) then "\n💬 " + (.text|oneline)
              elif .type=="tool_use" then "  ▸ " + .name + "(" + (toolargs(.input)|oneline) + ")"
              else empty end )
        elif .type=="result" then
          "\n──────── RESULT ("
          + (.subtype // "?") + ", " + ((.duration_ms//0|tostring)) + "ms, "
          + ((.num_turns//0|tostring)) + " turns) ────────\n"
          + (.result // "(no result text)" )
        else empty end )
' "$f"
