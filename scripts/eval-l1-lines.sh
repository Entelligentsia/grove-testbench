#!/usr/bin/env bash
# Evaluate L1 single-symbol ANSWER LINE ACCURACY for both sides, deriving the
# TRUE line from the pinned source (grep -n) so it can't drift. Reusable for R1
# (buggy grove) and R2 (after grove#31 fix) — pass --label to tag the output.
#
# Usage: eval-l1-lines.sh [--label r2] [--dg-img grove-testbench/dg:latest] [--out DIR]
#
# Writes evidence/L1.lines.<label>.json and prints a per-repo table:
#   true line | db line (correct?) | dg line (correct? off-by-one?)
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
LABEL="r1"; DG_IMG="grove-testbench/dg:latest"; OUT="$root/out"
while [[ $# -gt 0 ]]; do case "$1" in
  --label) LABEL="$2"; shift 2;; --dg-img) DG_IMG="$2"; shift 2;; --out) OUT="$2"; shift 2;;
  *) echo "unknown $1">&2; exit 2;; esac; done

# repo | container relpath | grep -E pattern locating the definition's true line
read -r -d '' TABLE <<'TSV' || true
tokio	tokio/tokio/src/task/spawn.rs	pub fn spawn<
hugo	hugo/hugolib/site.go	^type Site struct
django	django/django/db/models/query.py	^class QuerySet
typescript	typescript/src/compiler/scanner.ts	function createScanner
webpack	webpack/lib/Compiler.js	^class Compiler
bitcoin	bitcoin/src/primitives/transaction.h	class CTransaction
spring-boot	spring-boot/core/spring-boot/src/main/java/org/springframework/boot/SpringApplication.java	public class SpringApplication
rails	rails/activerecord/lib/active_record/relation.rb	class Relation
laravel	laravel/src/Illuminate/Database/Eloquent/Model.php	abstract class Model
TSV

# 1) derive true lines from the dg image source (grep -n is 1-indexed)
cfg="$OUT/.cfg"; mkdir -p "$cfg"; printf '%s\n' "$TABLE" > "$cfg/l1table.tsv"
truths="$(sg docker -c "docker run --rm -v '$cfg:/cfg:ro' '$DG_IMG' bash -lc '
cd /home/bench/repos
while IFS=\$(printf \"\\t\") read -r repo file pat; do
  [ -n \"\$repo\" ] || continue
  ln=\$(grep -nE \"\$pat\" \"\$file\" 2>/dev/null | head -1 | cut -d: -f1)
  echo \"\$repo \$ln\"
done < /cfg/l1table.tsv
'" 2>/dev/null)"

# 2) parse each side's claimed line and compare
python3 - "$OUT" "$LABEL" "$root" <<PY
import json,re,sys,os
OUT,LABEL,root=sys.argv[1],sys.argv[2],sys.argv[3]
truth={}
for line in '''$truths'''.strip().splitlines():
    p=line.split()
    if len(p)==2 and p[1].isdigit(): truth[p[0]]=int(p[1])
def claimed(repo,side):
    f=os.path.join(OUT,f"opt-{repo}-L1_symbol.claude.{side}.jsonl")
    if not os.path.exists(f): return None
    txt=""
    for l in open(f):
        try:
            o=json.loads(l)
            if o.get("type")=="result": txt=o.get("result","") or ""
        except: pass
    # strong line-number patterns, earliest wins: "line N", ":N", "@N"
    best=None
    for m in re.finditer(r'(?:\bline\s*\**\s*|[:#@])(\d{1,6})', txt):
        if best is None or m.start()<best[0]: best=(m.start(),int(m.group(1)))
    return best[1] if best else None
repos="tokio hugo django typescript webpack bitcoin spring-boot rails laravel".split()
rows=[]
print(f"\n=== L1 line accuracy [{LABEL}] (dg img per --dg-img) ===")
print(f"{'repo':12} {'true':>5} | {'db':>5} {'ok':>3} | {'dg':>5} {'ok':>3} {'off-1?':>7}")
print("-"*54)
for r in repos:
    t=truth.get(r); db=claimed(r,"db"); dg=claimed(r,"dg")
    dbok = (db==t); dgok=(dg==t); off1=(dg is not None and t is not None and dg==t-1)
    rows.append(dict(repo=r,true_line=t,db_line=db,dg_line=dg,db_correct=dbok,dg_correct=dgok,dg_off_by_one=off1))
    print(f"{r:12} {str(t):>5} | {str(db):>5} {('Y' if dbok else 'N'):>3} | {str(dg):>5} {('Y' if dgok else 'N'):>3} {('YES' if off1 else ''):>7}")
summ=dict(label=LABEL,
          db_correct=sum(1 for x in rows if x['db_correct']),
          dg_correct=sum(1 for x in rows if x['dg_correct']),
          dg_off_by_one=[x['repo'] for x in rows if x['dg_off_by_one']],
          n=len(rows))
print("-"*54)
print(f"db correct {summ['db_correct']}/{summ['n']} · dg correct {summ['dg_correct']}/{summ['n']} · dg off-by-one: {summ['dg_off_by_one'] or 'none'}")
out=dict(summary=summ,repos=rows)
ev=os.path.join(root,"evidence",f"L1.lines.{LABEL}.json")
json.dump(out,open(ev,"w"),indent=2)
print("wrote",ev)
PY
rm -f "$cfg/l1table.tsv"
