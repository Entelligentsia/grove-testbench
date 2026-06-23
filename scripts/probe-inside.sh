#!/usr/bin/env bash
# Runs INSIDE the probe container. Tier-1 (agent-free, zero-token) assertions on
# grove's RAW output. Dispatches on the first TSV column (the `kind`):
#
#   line        symbol<TAB>file<TAB>grep-pattern   (GI-1/#31 line accuracy)
#               grove outline <file> must report the TRUE 1-based line.
#   nodecl      sym<TAB>dir<TAB>real-subpath<TAB>gen-subpath   (GI-5)
#               grove symbols <dir> --name <sym> --refs --json must include
#               real-subpath and must NOT include the generated gen-subpath.
#   callersmin  sym<TAB>dir<TAB>min-count   (GI-6)
#               grove callers <sym> -d <dir> --json must return >= min-count sites.
#
# Rows whose first column is not one of {line,nodecl,callersmin} are treated as a
# legacy `line` probe (symbol=col1, file=col2, pat=col3) so the original
# probes/line-accuracy.tsv keeps working unchanged.
#
# Emits one TSV row to stdout:  repo<TAB>symbol<TAB>truth<TAB>got<TAB>PASS|FAIL
set -uo pipefail
spec="${1:?probe spec tsv required}"
repos=/home/bench/repos

do_line() {  # symbol file pat
  local symbol="$1" file="$2" pat="$3"
  local repo="${file%%/*}"
  local full="$repos/$file"
  local truth got row verdict=FAIL
  truth="$(grep -nE "$pat" "$full" 2>/dev/null | head -1 | cut -d: -f1)"
  local spat="${pat#^}"
  row="$(grove outline "$full" 2>/dev/null | grep -E "$spat" | head -1)"
  got="$(grep -oE '[0-9]+:[0-9]+' <<<"$row" | head -1 | cut -d: -f1)"
  [[ -n "$truth" && "$got" == "$truth" ]] && verdict=PASS
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo" "$symbol" "${truth:-?}" "${got:-?}" "$verdict"
}

do_nodecl() {  # sym dir real gen
  local sym="$1" dir="$2" real="$3" gen="$4"
  local repo; repo="$(basename "$dir")"
  local out real_present=0 gen_present=0 verdict=FAIL got
  out="$(grove symbols "$dir" --name "$sym" --refs --json 2>/dev/null || true)"
  grep -qF "$real" <<<"$out" && real_present=1
  grep -qF "$gen"  <<<"$out" && gen_present=1
  got="real=$real_present gen=$gen_present"
  [[ "$real_present" == "1" && "$gen_present" == "0" ]] && verdict=PASS
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo" "$sym" "incl $real & excl $gen" "$got" "$verdict"
}

do_callersmin() {  # sym dir min
  local sym="$1" dir="$2" min="$3"
  local repo; repo="$(basename "$dir")"
  local out count verdict=FAIL
  out="$(grove callers "$sym" -d "$dir" --json 2>/dev/null || true)"
  # callers --json is a JSON array of call sites; count defensively.
  count="$(jq 'if type=="array" then length elif (.results|type)=="array" then (.results|length) else 0 end' <<<"$out" 2>/dev/null || echo 0)"
  [[ "${count:-0}" -ge "$min" ]] && verdict=PASS
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo" "$sym" ">= $min" "${count:-0}" "$verdict"
}

while IFS=$'\t' read -r f1 f2 f3 f4 _rest || [[ -n "${f1:-}" ]]; do
  [[ -z "${f1:-}" || "${f1:0:1}" == "#" ]] && continue
  case "$f1" in
    line)       do_line "$f2" "$f3" "$f4" ;;
    nodecl)     do_nodecl "$f2" "$f3" "$f4" "$_rest" ;;
    callersmin) do_callersmin "$f2" "$f3" "$f4" ;;
    *)          do_line "$f1" "$f2" "$f3" ;;   # legacy line-accuracy rows
  esac
done < "$spec"
