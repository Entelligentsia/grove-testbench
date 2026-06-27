#!/usr/bin/env bash
# Run ONE side of one scene, foreground, headless stream-json. Deliberately
# simple: no backgrounding, no nested quoting, stderr NOT swallowed — so a
# failure is visible. Companion to extract-metrics.sh.
#
#   baseline = grove OFF (empty mcp config)
#   grove    = grove ON  (grove mcp config)
# Both sides get claude-md/<repo>.base.md as the repo CLAUDE.md (fair steering);
# the grove image's CLAUDE.md already carries the baked grove block.
#
# Usage:
#   scripts/run-side.sh <scene-id> <repo> <baseline|grove> [--model M] [--out DIR]
#     [--baseline IMG] [--grove IMG]
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

SCENE="${1:?usage: run-side.sh <scene> <repo> <side>}"; shift
REPO="${1:?need repo}"; shift
SIDE="${1:?need side: baseline|grove}"; shift
[[ "$SIDE" == baseline || "$SIDE" == grove ]] || { echo "side must be baseline|grove" >&2; exit 2; }

MODEL=""
OUT="$root/out/l4"
BASE_IMG="grove-testbench/base:latest"
GROVE_IMG="grove-testbench/grove:v0.1.8"
while [[ $# -gt 0 ]]; do case "$1" in
  --model)    MODEL="$2"; shift 2 ;;
  --out)      OUT="$2"; shift 2 ;;
  --baseline) BASE_IMG="$2"; shift 2 ;;
  --grove)    GROVE_IMG="$2"; shift 2 ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;; esac; done

command -v jq  >/dev/null || { echo "jq required" >&2; exit 1; }
command -v docker >/dev/null || { echo "docker required" >&2; exit 1; }
PROMPT_FILE="$root/scenes/$SCENE.prompt.txt"
[[ -f "$PROMPT_FILE" ]] || { echo "missing prompt: $PROMPT_FILE" >&2; exit 2; }
CREDS="${CLAUDE_CREDS:-$HOME/.claude/.credentials.json}"
[[ -f "$CREDS" ]] || { echo "missing creds: $CREDS" >&2; exit 1; }
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"   # docker volume mounts require an absolute path

# stage world-readable creds + mcp configs (container user bench=uid1001 can't
# read the host 0600 creds)
CFG="$OUT/.cfg"; mkdir -p "$CFG"
install -m 0644 "$CREDS" "$CFG/creds.json"
printf '{ "mcpServers": {} }\n' > "$CFG/empty-mcp.json"
printf '{ "mcpServers": { "grove": { "command": "grove", "args": ["serve"] } } }\n' > "$CFG/grove-mcp.json"

IMG="$BASE_IMG"; CFGNAME=empty-mcp.json
[[ "$SIDE" == grove ]] && { IMG="$GROVE_IMG"; CFGNAME=grove-mcp.json; }
CREPO="/home/bench/repos/$REPO"
OUTFILE="$OUT/$SCENE.claude.$SIDE.jsonl"

# fair base steering: baseline gets base.md as CLAUDE.md; grove prepends base.md
# to its baked grove block. No base file -> leave repo CLAUDE.md as-is.
BASEMD="$root/claude-md/$REPO.base.md"
INJECT=":"
if [[ -f "$BASEMD" ]]; then
  cp "$BASEMD" "$CFG/base.md"
  if [[ "$SIDE" == grove ]]; then
    INJECT="cat /cfg/base.md $CREPO/CLAUDE.md > /tmp/cm 2>/dev/null && cp /tmp/cm $CREPO/CLAUDE.md"
  else
    INJECT="cp /cfg/base.md $CREPO/CLAUDE.md"
  fi
fi

MODEL_ARG=(); [[ -n "$MODEL" ]] && MODEL_ARG=(--model "$MODEL")

echo "=== $SCENE / $SIDE (grove $([[ $SIDE == grove ]] && echo ON || echo OFF)) — $IMG ==="
echo "    repo dir: $CREPO   out: $OUTFILE"

docker run --rm \
  -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e COLORTERM=truecolor \
  -e RACE_PROMPT="$(cat "$PROMPT_FILE")" \
  -v "$CFG/creds.json:/home/bench/.claude/.credentials.json:ro" \
  -v "$CFG:/cfg:ro" \
  "$IMG" \
  bash -lc "cd $CREPO && $INJECT; claude -p \"\$RACE_PROMPT\" --output-format stream-json --verbose --dangerously-skip-permissions ${MODEL_ARG[*]} --strict-mcp-config --mcp-config /cfg/$CFGNAME" \
  > "$OUTFILE"

if [[ -s "$OUTFILE" ]] && grep -q '"type":"result"' "$OUTFILE"; then
  echo "    -> OK ($(wc -l <"$OUTFILE") events, $(stat -c%s "$OUTFILE") B)"
else
  echo "    -> WARN: no result event ($(stat -c%s "$OUTFILE" 2>/dev/null||echo 0) B)" >&2
fi
