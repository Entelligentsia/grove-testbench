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
#   scripts/run-side.sh <scene-id> <repo> <baseline|grove|lsp> [--model M] [--out DIR]
#     [--prompt FILE] [--baseline IMG] [--grove IMG] [--lsp IMG] [--mcp-config FILE]
#
#   baseline = grove OFF (empty mcp config)        — text search
#   grove    = grove ON  (grove mcp config)        — structural
#   lsp      = LSP bridge (--mcp-config required)   — semantic
# --prompt overrides the default scenes/<scene>.prompt.txt (the experiment passes
# experiment/prompts/<repo>/<rung>.txt so genesis stays out of scenes/).
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

SCENE="${1:?usage: run-side.sh <scene> <repo> <side>}"; shift
REPO="${1:?need repo}"; shift
SIDE="${1:?need side: baseline|grove|lsp}"; shift
[[ "$SIDE" == baseline || "$SIDE" == grove || "$SIDE" == lsp ]] || { echo "side must be baseline|grove|lsp" >&2; exit 2; }

MODEL=""
OUT="$root/out/l4"
BASE_IMG="grove-testbench/base:latest"
GROVE_IMG="grove-testbench/grove:v0.1.8"
LSP_IMG="grove-testbench/lsp:latest"
MCP_CONFIG=""        # required for lsp: the per-repo MCP->LSP bridge config
PROMPT_OVERRIDE=""
while [[ $# -gt 0 ]]; do case "$1" in
  --model)      MODEL="$2"; shift 2 ;;
  --out)        OUT="$2"; shift 2 ;;
  --prompt)     PROMPT_OVERRIDE="$2"; shift 2 ;;
  --baseline)   BASE_IMG="$2"; shift 2 ;;
  --grove)      GROVE_IMG="$2"; shift 2 ;;
  --lsp)        LSP_IMG="$2"; shift 2 ;;
  --mcp-config) MCP_CONFIG="$2"; shift 2 ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;; esac; done

command -v jq  >/dev/null || { echo "jq required" >&2; exit 1; }
command -v docker >/dev/null || { echo "docker required" >&2; exit 1; }
PROMPT_FILE="${PROMPT_OVERRIDE:-$root/scenes/$SCENE.prompt.txt}"
[[ -f "$PROMPT_FILE" ]] || { echo "missing prompt: $PROMPT_FILE" >&2; exit 2; }
CREDS="${CLAUDE_CREDS:-$HOME/.claude/.credentials.json}"
[[ -f "$CREDS" ]] || { echo "missing creds: $CREDS" >&2; exit 1; }
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"   # docker volume mounts require an absolute path

# stage world-readable creds + mcp configs (container user bench=uid1001 can't
# read the host 0600 creds)
CFG="$OUT/.cfg"; mkdir -p "$CFG"
printf '{ "mcpServers": {} }\n' > "$CFG/empty-mcp.json"
printf '{ "mcpServers": { "grove": { "command": "grove", "args": ["serve"] } } }\n' > "$CFG/grove-mcp.json"
install -m 0644 "$CREDS" "$CFG/creds.json"   # copied into a fresh tmpfs .claude at container start

# /home/bench/.claude is a fresh PER-RUN tmpfs (mode 1777), seeded with only the
# creds. Two problems this solves at once:
#   1. The image has no /home/bench/.claude; bind-mounting the bare creds file made
#      docker create that dir owned by ROOT, so bench (uid 1001) couldn't
#      `mkdir .claude/session-env` and EVERY Bash tool call died with EACCES —
#      silently crippling the baseline into Read-only. A writable tmpfs fixes that.
#   2. claude writes config/session state into .claude (.claude.json, backups/,
#      projects/, sessions/). A shared host dir leaked that state across runs/arms,
#      and its container-uid-owned files couldn't be cleaned from the host. A tmpfs
#      is ephemeral: every cell starts from an identical clean .claude, nothing
#      persists to the host, no cross-arm contamination. (Creds copied in below.)

case "$SIDE" in
  baseline) IMG="$BASE_IMG";  CFGNAME=empty-mcp.json ;;
  grove)    IMG="$GROVE_IMG"; CFGNAME=grove-mcp.json ;;
  lsp)      IMG="$LSP_IMG";   CFGNAME=lsp-mcp.json
            [[ -n "$MCP_CONFIG" && -f "$MCP_CONFIG" ]] || { echo "lsp arm needs --mcp-config <bridge config file>" >&2; exit 2; }
            cp "$MCP_CONFIG" "$CFG/lsp-mcp.json" ;;
esac
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

echo "=== $SCENE / arm=$SIDE — $IMG ==="
echo "    prompt: $PROMPT_FILE"
echo "    repo dir: $CREPO   out: $OUTFILE"

docker run --rm \
  -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e COLORTERM=truecolor \
  -e RACE_PROMPT="$(cat "$PROMPT_FILE")" \
  --tmpfs /home/bench/.claude:rw,mode=1777 \
  -v "$CFG:/cfg:ro" \
  "$IMG" \
  bash -lc "cp /cfg/creds.json /home/bench/.claude/.credentials.json; cd $CREPO && $INJECT; claude -p \"\$RACE_PROMPT\" --output-format stream-json --verbose --dangerously-skip-permissions ${MODEL_ARG[*]} --strict-mcp-config --mcp-config /cfg/$CFGNAME" \
  > "$OUTFILE"

if [[ -s "$OUTFILE" ]] && grep -q '"type":"result"' "$OUTFILE"; then
  echo "    -> OK ($(wc -l <"$OUTFILE") events, $(stat -c%s "$OUTFILE") B)"
else
  echo "    -> WARN: no result event ($(stat -c%s "$OUTFILE" 2>/dev/null||echo 0) B)" >&2
fi
