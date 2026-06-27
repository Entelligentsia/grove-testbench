#!/usr/bin/env bash
# Runaway guard for L3 races. Polls every out/l3 side transcript; if one crosses
# MAXBYTES while still running (no result event yet), docker-kills the matching
# container. Maps a transcript file -> container by (image=side, repos/<repo> in
# the container's args).
#
# Usage: MAXBYTES=1500000 l3-watchdog.sh <out-dir> [repo ...]
#   stops when the race log shows "=== L3 summary ===" AND no race containers remain.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
OUT="${1:?usage: l3-watchdog.sh <out-dir> [repos...]}"; shift || true
REPOS=("$@")
MAXBYTES="${MAXBYTES:-1500000}"
RUNLOG="${RUNLOG:-$root/out/l3-rest.log}"
BASE_IMG="grove-testbench/base"
GROVE_IMG="grove-testbench/grove:v0.1.9"

echo "[watchdog] cutoff=${MAXBYTES}B  out=$OUT  repos=${REPOS[*]:-<all>}"

kill_for() {  # $1=repo  $2=side
  local repo="$1" side="$2" img cid args
  img=$([[ "$side" == grove ]] && echo "$GROVE_IMG" || echo "$BASE_IMG")
  for cid in $(docker ps -q --filter "ancestor=$img"); do
    args="$(docker inspect -f '{{json .Args}}' "$cid" 2>/dev/null)"
    if echo "$args" | grep -q "repos/$repo "; then
      echo "[watchdog] KILL $repo/$side (container $cid) — transcript exceeded ${MAXBYTES}B"
      docker kill "$cid" >/dev/null 2>&1
      return 0
    fi
  done
  echo "[watchdog] WARN $repo/$side over cutoff but no matching container found"
}

declare -A killed
while :; do
  for f in "$OUT"/opt-*-L3_flow.claude.*.jsonl; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    # opt-<repo>-L3_flow.claude.<side>.jsonl
    repo="$(echo "$base" | sed -E 's/^opt-(.*)-L3_flow\.claude\..*/\1/')"
    side="$(echo "$base" | sed -E 's/.*\.claude\.(baseline|grove)\.jsonl/\1/')"
    key="$repo/$side"
    [[ -n "${killed[$key]:-}" ]] && continue
    grep -q '"type":"result"' "$f" && continue          # already completed cleanly
    sz=$(stat -c%s "$f" 2>/dev/null || echo 0)
    if (( sz > MAXBYTES )); then
      kill_for "$repo" "$side"
      killed[$key]=1
    fi
  done
  # exit when batch done and no race containers remain
  if grep -q "=== L3 summary ===" "$RUNLOG" 2>/dev/null; then
    if [[ -z "$(docker ps -q --filter ancestor=$BASE_IMG)$(docker ps -q --filter ancestor=$GROVE_IMG)" ]]; then
      echo "[watchdog] batch finished; killed: ${!killed[*]:-none}"; exit 0
    fi
  fi
  sleep 8
done
