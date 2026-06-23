#!/usr/bin/env bash
# Self-evaluating prompt-complexity sweep.
#
# Goal: find the prompt complexity at which grove (dg) wins on NET context tokens
# — i.e. dg.context_tokens < db.context_tokens. Grove's steering + tool-schema
# tax (~30k) is fixed; the baseline's cost grows with how much source it must
# read. So we climb a ladder of escalating reading breadth (single symbol →
# call sites → flow trace → subsystem summary → cross-cutting architecture) and
# race BOTH sides at each rung until grove's structural slicing beats reading
# whole files.
#
# Each rung is one real headless race per side (run-race.sh -> extract-metrics).
# The ladder is a TSV: `LABEL<TAB>PROMPT` per line (# comments / blanks ignored).
#
# Usage:
#   optimize-prompt.sh <repo> [--ladder FILE] [--model M] [--until-win]
#                       [--out DIR] [--keep]
#
#   --ladder FILE  default scenes/<repo>.ladder.tsv
#   --model  M     pin a model both sides (recommended, e.g. sonnet)
#   --until-win    stop at the first rung where dg wins context (default: run all)
#   --keep         keep the per-rung scene prompt files (default: clean up)
#
# Writes: out/<repo>.optimize.json   (full ladder + per-rung metrics + verdict)
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

REPO=""
LADDER=""
MODEL=""
UNTIL_WIN=0
KEEP=0
OUT="$root/out"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ladder)    LADDER="$2"; shift 2 ;;
    --model)     MODEL="$2"; shift 2 ;;
    --until-win) UNTIL_WIN=1; shift ;;
    --keep)      KEEP=1; shift ;;
    --out)       OUT="$2"; shift 2 ;;
    -*)          echo "unknown flag: $1" >&2; exit 2 ;;
    *)           REPO="$1"; shift ;;
  esac
done
[[ -n "$REPO" ]] || { echo "usage: optimize-prompt.sh <repo> [--ladder F] [--model M] [--until-win]" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }
LADDER="${LADDER:-$root/scenes/$REPO.ladder.tsv}"
[[ -f "$LADDER" ]] || { echo "missing ladder: $LADDER" >&2; exit 2; }
mkdir -p "$OUT"

MODEL_ARG=(); [[ -n "$MODEL" ]] && MODEL_ARG=(--model "$MODEL")
RESULTS="$OUT/$REPO.optimize.json"
ROWS=()         # accumulated jq objects
created=()      # synthetic scene files to clean up

printf '\n=== prompt-complexity sweep: %s ===\n' "$REPO"
printf 'goal: smallest rung where dg(grove) context < db(baseline) context\n'
[[ -n "$MODEL" ]] && printf 'model: %s\n' "$MODEL"
printf '%-14s %12s %12s %9s %9s  %s\n' RUNG db_ctx dg_ctx "delta%" winner verdict
printf '%s\n' "------------------------------------------------------------------------------"

win_found=0
while IFS=$'\t' read -r label prompt || [[ -n "$label" ]]; do
  # skip comments / blanks
  [[ -z "${label// }" ]] && continue
  [[ "${label:0:1}" == "#" ]] && continue
  [[ -z "${prompt// }" ]] && { echo "  ! rung '$label' has no prompt; skipping" >&2; continue; }

  sid="opt-$REPO-$label"
  pf="$root/scenes/$sid.prompt.txt"
  printf '%s\n' "$prompt" > "$pf"
  created+=("$pf")

  # one real race for this rung (both sides), then metrics
  "$here/run-race.sh" "$sid" --repo-name "$REPO" "${MODEL_ARG[@]}" >/dev/null 2>&1 || true
  "$here/extract-metrics.sh" "$sid" >/dev/null 2>&1 || true
  mfile="$OUT/$sid.claude.metrics.json"

  if [[ ! -s "$mfile" ]]; then
    printf '%-14s %12s %12s %9s %9s  %s\n' "$label" "-" "-" "-" "-" "NO METRICS"
    ROWS+=("$(jq -n --arg l "$label" --arg p "$prompt" '{label:$l, prompt:$p, ok:false}')")
    continue
  fi

  read -r dbc dgc dlt w <<<"$(jq -r '
    [ (.sides.db.context_tokens // "null"),
      (.sides.dg.context_tokens // "null"),
      (.delta_pct.context // "null"),
      (.winner.context // "null") ] | @tsv' "$mfile")"

  verdict="baseline cheaper"
  [[ "$w" == "dg" ]] && verdict="*** GROVE WINS ***"
  [[ "$w" == "tie" ]] && verdict="tie"

  printf '%-14s %12s %12s %8s%% %9s  %s\n' "$label" "$dbc" "$dgc" "$dlt" "$w" "$verdict"

  ROWS+=("$(jq -n --arg l "$label" --arg p "$prompt" \
      --slurpfile m "$mfile" \
      '{label:$l, prompt:$p, ok:true,
        db_context:$m[0].sides.db.context_tokens,
        dg_context:$m[0].sides.dg.context_tokens,
        delta_pct_context:$m[0].delta_pct.context,
        winner_context:$m[0].winner.context,
        db_tool_calls:$m[0].sides.db.tool_calls,
        dg_tool_calls:$m[0].sides.dg.tool_calls,
        winner_time:$m[0].winner.time,
        delta_pct_time:$m[0].delta_pct.time,
        db_turns:$m[0].sides.db.turns,
        dg_turns:$m[0].sides.dg.turns}')")

  if [[ "$w" == "dg" ]]; then
    win_found=1
    [[ "$UNTIL_WIN" == 1 ]] && { echo; echo "first grove context-win at rung: $label — stopping (--until-win)"; break; }
  fi
done < "$LADDER"

# assemble summary
printf '%s\n' "${ROWS[@]}" | jq -s --arg repo "$REPO" --arg model "$MODEL" '
  { repo:$repo, model:$model, rungs:.,
    first_grove_context_win:
      ( [ .[] | select(.winner_context=="dg") ] | (.[0].label // null) ),
    any_grove_context_win: ( any(.[]; .winner_context=="dg") )
  }' > "$RESULTS"

echo
echo "wrote $RESULTS"
if [[ "$win_found" == 1 ]]; then
  echo "verdict: grove achieves a NET context win at/after rung '$(jq -r '.first_grove_context_win' "$RESULTS")'."
else
  echo "verdict: no rung yet yields a net grove context win — climb the ladder higher (broader-reading prompts)."
fi

# cleanup synthetic scene files unless --keep
if [[ "$KEEP" != 1 ]]; then
  for f in "${created[@]}"; do rm -f "$f"; done
fi
