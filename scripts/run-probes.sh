#!/usr/bin/env bash
# TIER-1 verification: assert grove's RAW output on the testbench repos, with NO
# agent and NO tokens. Bind-mounts the binary-under-test into the probe image, so
# the fix→verify loop is just `cargo build` + this script — no image rebuild.
#
#   GROVE_BIN=../grove/target/release/grove scripts/run-probes.sh --label r2
#   scripts/run-probes.sh                      # uses the binary baked in probe
#
# Flags: --label NAME · --spec FILE (default probes/line-accuracy.tsv)
#        --img IMG (default grove-testbench/probe:latest) · --out DIR
# Exit code is non-zero if any probe FAILS (CI-friendly gate before Tier-2 races).
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
LABEL="local"; SPEC="$root/probes/line-accuracy.tsv"; IMG="grove-testbench/probe:latest"; OUT="$root/out"
while [[ $# -gt 0 ]]; do case "$1" in
  --label) LABEL="$2"; shift 2;; --spec) SPEC="$2"; shift 2;;
  --img) IMG="$2"; shift 2;; --out) OUT="$2"; shift 2;;
  *) echo "unknown $1">&2; exit 2;; esac; done
[[ -f "$SPEC" ]] || { echo "missing spec: $SPEC" >&2; exit 2; }
command -v docker >/dev/null || { echo "docker required" >&2; exit 1; }

mount_bin=""
grove_bin="${GROVE_BIN:-}"
if [[ -n "$grove_bin" ]]; then
  grove_bin="$(cd "$(dirname "$grove_bin")" && pwd)/$(basename "$grove_bin")"
  [[ -x "$grove_bin" ]] || { echo "GROVE_BIN not executable: $grove_bin" >&2; exit 1; }
  mount_bin="-v $grove_bin:/usr/local/bin/grove:ro"
fi

echo "=== TIER-1 probes [$LABEL] · spec $(basename "$SPEC") · img $IMG ==="
[[ -n "$mount_bin" ]] && echo "binary-under-test: $grove_bin" || echo "binary: (baked in image)"

results="$(docker run --rm $mount_bin -v "$root:/work:ro" "$IMG" \
            bash /work/scripts/probe-inside.sh "/work/${SPEC#$root/}" 2>/dev/null)"

mkdir -p "$OUT" "$root/evidence"
printf '%-12s %-20s %6s %6s  %s\n' repo symbol true got verdict
printf '%s\n' "------------------------------------------------------------"
pass=0; fail=0
while IFS=$'\t' read -r repo symbol truth got verdict; do
  [[ -z "$repo" ]] && continue
  printf '%-12s %-20s %6s %6s  %s\n' "$repo" "$symbol" "$truth" "$got" "$verdict"
  [[ "$verdict" == PASS ]] && pass=$((pass+1)) || fail=$((fail+1))
done <<<"$results"
printf '%s\n' "------------------------------------------------------------"
echo "PASS $pass · FAIL $fail"

# evidence json
ev="$root/evidence/probes.$LABEL.json"
python3 - "$ev" "$LABEL" "$grove_bin" <<PY
import json,sys
ev,label,binp=sys.argv[1],sys.argv[2],sys.argv[3]
rows=[]
for ln in '''$results'''.strip().splitlines():
    p=ln.split('\t')
    if len(p)==5:
        rows.append(dict(repo=p[0],symbol=p[1],true_line=p[2],got_line=p[3],verdict=p[4]))
out=dict(label=label,binary=binp or "(baked)",
         passed=sum(1 for r in rows if r['verdict']=='PASS'),
         failed=sum(1 for r in rows if r['verdict']=='FAIL'),
         probes=rows)
json.dump(out,open(ev,'w'),indent=2); print("wrote",ev)
PY

[[ "$fail" -eq 0 ]]
