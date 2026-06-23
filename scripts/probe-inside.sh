#!/usr/bin/env bash
# Runs INSIDE the probe container. Line-accuracy check via `grove outline` — the
# file-scoped primitive (no cross-file resolution ambiguity). For each probe:
#   truth = grep -n <pat> <file>            (the real 1-based line)
#   got   = the outline row whose signature matches <pat>, its reported line
# Emits one TSV row to stdout:  repo<TAB>symbol<TAB>true<TAB>got<TAB>PASS|FAIL
# Pure grove CLI output assertion — no tokens, no agent.
#
# Usage (in-container): probe-inside.sh <probes.tsv>
set -uo pipefail
spec="${1:?probe spec tsv required}"
repos=/home/bench/repos

while IFS=$'\t' read -r symbol file pat; do
  [[ -z "${symbol// }" || "${symbol:0:1}" == "#" ]] && continue
  repo="${file%%/*}"
  full="$repos/$file"
  truth="$(grep -nE "$pat" "$full" 2>/dev/null | head -1 | cut -d: -f1)"
  spat="${pat#^}"   # outline signature isn't line-anchored; drop a leading ^
  row="$(grove outline "$full" 2>/dev/null | grep -E "$spat" | head -1)"
  got="$(grep -oE '[0-9]+:[0-9]+' <<<"$row" | head -1 | cut -d: -f1)"
  verdict=FAIL
  [[ -n "$truth" && "$got" == "$truth" ]] && verdict=PASS
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo" "$symbol" "${truth:-?}" "${got:-?}" "$verdict"
done < "$spec"
