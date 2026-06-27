#!/usr/bin/env bash
# Run one scene's prompt ONCE PER SIDE, headless, capturing claude's stream-json.
# That JSONL is BOTH the metrics source (extract-metrics.sh) and the visual
# source (synth-cast.py -> render.sh). No interactive TUI capture — reliable,
# no startup gates.
#
#   baseline side = grove OFF  (--strict-mcp-config + empty config)
#   grove     side = grove ON   (--strict-mcp-config + grove config)
#
# Backends:
#   --backend docker   (default) run inside baseline/grove images
#   --backend local              run host `claude` against --repo-dir (for testing)
#
# Host deps: jq (+ docker for docker backend; +claude for local).
#
# Usage:
#   run-race.sh <scene-id> [--agent claude] [--backend docker|local]
#               [--repo-dir DIR] [--baseline IMG] [--grove IMG] [--out DIR] [--model M]
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

AGENT=claude
BACKEND=docker
REPO_DIR=""
REPO_NAME=""          # underlying codebase (defaults to scene id); decouples
                      # a synthetic scene id (e.g. opt-redis-L3) from the repo
DB_IMG=grove-testbench/baseline:latest
DG_IMG=grove-testbench/grove:latest
OUT="$root/out"
MODEL=""              # pin a model for a consistent benchmark, e.g. opus / sonnet
REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)    AGENT="$2"; shift 2 ;;
    --backend)  BACKEND="$2"; shift 2 ;;
    --repo-dir) REPO_DIR="$2"; shift 2 ;;
    --repo-name) REPO_NAME="$2"; shift 2 ;;
    --baseline) DB_IMG="$2"; shift 2 ;;
    --grove)    DG_IMG="$2"; shift 2 ;;
    --out)      OUT="$2"; shift 2 ;;
    --model)    MODEL="$2"; shift 2 ;;
    -*)         echo "unknown flag: $1" >&2; exit 2 ;;
    *)          REPO="$1"; shift ;;
  esac
done
[[ -n "$REPO" ]] || { echo "usage: run-race.sh <scene-id> [--backend docker|local]" >&2; exit 2; }
REPO_NAME="${REPO_NAME:-$REPO}"

command -v jq >/dev/null || { echo "host dep missing: jq" >&2; exit 1; }
MODEL_ARG=""; [[ -n "$MODEL" ]] && MODEL_ARG="--model $MODEL"
# Auth: the baseline/grove images bake OAuth creds that EXPIRE (and the refresh
# token rotates, which breaks isolated --rm containers — first refresh wins, rest
# 401). Mount the host's live credentials read-only instead, so every container
# uses a valid token and nothing depends on the stale baked copy.
# Override with CLAUDE_CREDS.
CREDS="${CLAUDE_CREDS:-$HOME/.claude/.credentials.json}"
# Prefer the podman-as-docker shim when present (rootless; no daemon needed).
# Works whether the caller's PATH already includes it or not.
[[ -d /tmp/grove-podman-shim ]] && export PATH="/tmp/grove-podman-shim:$PATH"
# Same model + identical flags both sides; grove on/off is the only variable.
CAP_ENV='LANG=C.UTF-8 LC_ALL=C.UTF-8'
if [[ "$BACKEND" == docker ]]; then
  command -v docker >/dev/null || { echo "docker backend needs docker" >&2; exit 1; }
elif [[ "$BACKEND" == local ]]; then
  command -v claude >/dev/null || { echo "local backend needs claude" >&2; exit 1; }
  [[ -n "$REPO_DIR" ]] || { echo "local backend needs --repo-dir DIR" >&2; exit 1; }
  REPO_DIR="$(cd "$REPO_DIR" && pwd)"
else
  echo "unknown backend: $BACKEND" >&2; exit 1
fi

PROMPT_FILE="$root/scenes/$REPO.prompt.txt"
[[ -f "$PROMPT_FILE" ]] || { echo "missing prompt: $PROMPT_FILE" >&2; exit 2; }
PROMPT="$(cat "$PROMPT_FILE")"
mkdir -p "$OUT"

# --- MCP configs (grove on/off) -------------------------------------------
CFG="$OUT/.cfg"; mkdir -p "$CFG"
printf '{ "mcpServers": {} }\n' > "$CFG/empty-mcp.json"
printf '{ "mcpServers": { "grove": { "command": "grove", "args": ["serve"] } } }\n' > "$CFG/grove-mcp.json"

# Stage a WRITABLE .claude dir (mode 0777) holding the live host creds, and mount
# the whole dir at /home/bench/.claude. Do NOT bind-mount the bare creds file into
# /home/bench/.claude/.credentials.json: the image has no /home/bench/.claude, so
# docker then creates it owned by ROOT, and the bench user (uid 1001) can't
# `mkdir /home/bench/.claude/session-env` — which makes EVERY Bash tool call die
# with EACCES and silently cripples the agent into Read-only (grep/find never run,
# baseline catastrophically, grove on the cells where it reaches for Bash).
# Mounting a 0777 dir keeps session-env writable AND creds readable.
HAVE_CREDS=0
DOTCLAUDE="$CFG/dotclaude"
if [[ -f "$CREDS" ]]; then
  mkdir -p "$DOTCLAUDE"; chmod 0777 "$DOTCLAUDE"
  install -m 0644 "$CREDS" "$DOTCLAUDE/.credentials.json" && HAVE_CREDS=1
fi

# --- realistic base steering (fair baseline) -------------------------------
# If claude-md/<repo>.base.md exists, BOTH sides get it as the repo's CLAUDE.md
# so the comparison is apples-to-apples: identical project guidance, and grove
# is the ONLY variable. baseline = base only; grove = base + its baked grove
# block (the <!-- grove:start -->..<!-- grove:end --> section grove init wrote).
# With no base file present, behaviour is unchanged (baseline vanilla, grove-only).
BASEMD="$root/claude-md/$REPO_NAME.base.md"
HAVE_BASE=0
if [[ -f "$BASEMD" ]]; then cp "$BASEMD" "$CFG/base.md"; HAVE_BASE=1; fi

slug_of() { echo "$1" | sed 's#/#-#g'; }

# --- capture one side ------------------------------------------------------
# ONE headless `claude -p --output-format stream-json` run per side. Its JSONL
# is BOTH the metrics source (extract-metrics.sh) and the visual source
# (synth-cast.py renders a clean branded animation from it). No TUI capture —
# reliable, no startup gates. Grove on/off = the only variable (empty vs grove
# mcp config, both --strict so ambient config can't leak in).
capture_side() {
  local side="$1"
  local mjson="$OUT/$REPO.$AGENT.$side.jsonl"
  local grove_state; grove_state=$([[ "$side" == grove ]] && echo ON || echo OFF)
  local cfgname; cfgname=$([[ "$side" == grove ]] && echo grove-mcp.json || echo empty-mcp.json)
  local inner

  if [[ "$BACKEND" == local ]]; then
    inner="cd '$REPO_DIR' && env -u ANTHROPIC_API_KEY -u TMUX $CAP_ENV claude -p \"\$RACE_PROMPT\" --output-format stream-json --verbose --dangerously-skip-permissions $MODEL_ARG --strict-mcp-config --mcp-config '$CFG/$cfgname'"
  else
    local img; img=$([[ "$side" == grove ]] && echo "$DG_IMG" || echo "$DB_IMG")
    local crepo="/home/bench/repos/$REPO_NAME"
    local denv="-e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e COLORTERM=truecolor"
    # live host creds over the image's expired baked ones (read-only; token is
    # valid for the session so no in-container refresh/rotation is needed)
    local credmount=""
    [[ "$HAVE_CREDS" == 1 ]] && credmount="-v '$DOTCLAUDE:/home/bench/.claude'"
    # inject the fair base steering, if provided: baseline gets base only; grove
    # gets base prepended to its baked grove block (both sides end up with the
    # same project guidance, grove side additionally steered to grove).
    local inject=""
    if [[ "$HAVE_BASE" == 1 ]]; then
      if [[ "$side" == grove ]]; then
        inject="cat /cfg/base.md $crepo/CLAUDE.md > /tmp/cm 2>/dev/null && cp /tmp/cm $crepo/CLAUDE.md; "
      else
        inject="cp /cfg/base.md $crepo/CLAUDE.md; "
      fi
    fi
    inner="docker run --rm $denv $credmount -e RACE_PROMPT -v '$CFG:/cfg:ro' '$img' bash -lc \"cd $crepo && ${inject}claude -p \\\"\\\$RACE_PROMPT\\\" --output-format stream-json --verbose --dangerously-skip-permissions $MODEL_ARG --strict-mcp-config --mcp-config /cfg/$cfgname\""
  fi

  echo ">> [$side] grove $grove_state — running (headless stream-json)"
  RACE_PROMPT="$PROMPT" bash -c "$inner" > "$mjson" 2>/dev/null || true
  if [[ -s "$mjson" ]] && grep -q '"type":"result"' "$mjson"; then
    echo "   -> $mjson ($(wc -l <"$mjson") events)"
  else
    echo "   WARN: no result event in $mjson" >&2
  fi
}

echo "=== RACE: $REPO ($AGENT, $BACKEND) — baseline (grove OFF) vs grove (grove ON) ==="
echo "    prompt: $PROMPT"
capture_side baseline
capture_side grove
echo
echo "stream-json: $OUT/$REPO.$AGENT.{baseline,grove}.jsonl"
echo "next:"
echo "  scripts/extract-metrics.sh $REPO --agent $AGENT"
echo "  scripts/render.sh $REPO --agent $AGENT      # synth casts -> video"
