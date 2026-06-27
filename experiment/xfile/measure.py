#!/usr/bin/env python3
"""Cross-file go-to-def hit-rate for grove's import-edge resolution (ADR 0001
Step 2), measured on a pinned real-world repo against an LSP oracle.

Method
------
1. Sample *use-sites* of names brought in by `from MODULE import NAME [as A]`
   (Python) — the population grove's import-edge resolution targets. The first
   use of each bound name in its file is probed (not the import line itself).
2. Ground truth: a language server (pyright) resolves go-to-def at that exact
   position through its real import/type model.
3. grove: `grove definition --at file:line:col -d <root>` at the same position.
4. Compare. A site is a HIT when grove returns a single definition in the same
   file the oracle resolved to (and, for the strict metric, the same line).

The oracle also lets us bucket the population: an import whose target is a module
itself (`from pkg import submodule` → `__init__.py` line 1) is *out of scope* for
grove by design (it looks for a defined symbol, not a submodule), so it is
reported separately from symbol imports (grove's actual target).

Usage:
  measure.py --grove <bin> --registry <dir> --root <repo-root> \
             --lang python --server "pyright-langserver --stdio" \
             [--max-sites N] [--out report.json] [SUBDIR ...]
"""

import argparse
import ast
import json
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lspclient import LspClient


def py_sites(src):
    """Yield (use_line1, use_col0, module, srcname, bound) for the first use of
    each `from MODULE import NAME [as A]` binding in this file."""
    try:
        tree = ast.parse(src)
    except SyntaxError:
        return
    bindings = {}  # bound_name -> (module, srcname, import_lineno)
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module is not None and node.level == 0:
            for a in node.names:
                if a.name == "*":
                    continue
                bound = a.asname or a.name
                bindings.setdefault(bound, (node.module, a.name, node.lineno))
    if not bindings:
        return
    first_use = {}
    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and node.id in bindings:
            mod, srcname, imp_line = bindings[node.id]
            if node.lineno > imp_line:
                cur = first_use.get(node.id)
                if cur is None or node.lineno < cur[0]:
                    first_use[node.id] = (node.lineno, node.col_offset, mod, srcname)
    for bound, (l1, c0, mod, srcname) in first_use.items():
        yield (l1, c0, mod, srcname, bound)


def grove_def(grove, registry, root, path, line1, col1):
    env = dict(os.environ, GROVE_REGISTRY=registry)
    try:
        out = subprocess.run(
            [grove, "--json", "definition", "--at", f"{path}:{line1}:{col1}", "-d", root],
            capture_output=True, text=True, env=env, timeout=60,
        )
    except subprocess.TimeoutExpired:
        return None
    if out.returncode != 0:
        return []
    try:
        return json.loads(out.stdout)
    except json.JSONDecodeError:
        return []


def collect_files(root, subdirs, ext):
    bases = [os.path.join(root, s) for s in subdirs] if subdirs else [root]
    files = []
    for base in bases:
        for dirpath, _, names in os.walk(base):
            if "/test" in dirpath or "/migrations" in dirpath:
                continue
            for n in sorted(names):
                if n.endswith(ext):
                    files.append(os.path.join(dirpath, n))
    files.sort()
    return files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--grove", required=True)
    ap.add_argument("--registry", required=True)
    ap.add_argument("--root", required=True)
    ap.add_argument("--lang", default="python")
    ap.add_argument("--server", default="pyright-langserver --stdio")
    ap.add_argument("--max-sites", type=int, default=200)
    ap.add_argument("--out", default=None)
    ap.add_argument("subdirs", nargs="*")
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    files = collect_files(root, args.subdirs, ".py")

    # Build the site list (bounded, deterministic: stride across files).
    sites = []
    for f in files:
        try:
            src = open(f, encoding="utf-8").read()
        except (OSError, UnicodeDecodeError):
            continue
        for (l1, c0, mod, srcname, bound) in py_sites(src):
            sites.append((f, src, l1, c0, mod, srcname, bound))
    if len(sites) > args.max_sites:
        stride = len(sites) / args.max_sites
        sites = [sites[int(i * stride)] for i in range(args.max_sites)]
    print(f"sampling {len(sites)} import-use sites across {len(files)} files", file=sys.stderr)

    oracle = LspClient(args.server.split(), root)
    oracle.initialize()
    opened = set()
    rows = []
    t0 = time.time()
    for i, (f, src, l1, c0, mod, srcname, bound) in enumerate(sites):
        if f not in opened:
            oracle.did_open(f, args.lang, src)
            opened.add(f)
        # oracle (0-based line/char)
        try:
            odefs = oracle.definition(f, l1 - 1, c0, timeout=90)
        except Exception:
            odefs = []
        ofile, oline0 = (odefs[0] if odefs else (None, None))
        in_repo = bool(ofile) and os.path.abspath(ofile).startswith(root)
        same_file = in_repo and os.path.realpath(ofile) == os.path.realpath(f)
        # Bucket: a *module/package* import (`from pkg import submod`) resolves to
        # the top of a file named after the symbol (or a package __init__) — grove
        # looks for a defined symbol, not a submodule, so these are out of scope by
        # design. A real symbol def lands deeper than line 1.
        stem = os.path.splitext(os.path.basename(ofile))[0] if ofile else ""
        base = os.path.basename(ofile) if ofile else ""
        is_module_target = in_repo and (oline0 or 0) <= 1 and (
            stem.lower() == srcname.lower() or base == "__init__.py"
        )

        # grove (1-based line/col)
        gdefs = grove_def(args.grove, args.registry, root, f, l1, c0 + 1)
        gdefs = gdefs if isinstance(gdefs, list) else []
        gcount = len(gdefs)
        gfiles = [os.path.realpath(d["file"]) for d in gdefs]
        gsingle = gcount == 1
        gfile = gfiles[0] if gsingle else None
        gline = gdefs[0]["line"] if gsingle else None
        gcross = gsingle and gfile != os.path.realpath(f)

        oreal = os.path.realpath(ofile) if ofile else None
        file_hit = bool(gsingle and in_repo and gfile == oreal)
        line_hit = bool(file_hit and gline == (oline0 + 1))
        # Did the dir-wide fallback at least *contain* the right file (ambiguously)?
        oracle_in_fallback = bool(in_repo and not gsingle and oreal in gfiles)

        rows.append({
            "file": f.split("/repos/")[-1], "line": l1, "col": c0 + 1,
            "bound": bound, "module": mod, "srcname": srcname,
            "oracle_file": (ofile.split("/repos/")[-1] if ofile else None),
            "oracle_line": (oline0 + 1) if oline0 is not None else None,
            "oracle_in_repo": in_repo, "oracle_same_file": same_file,
            "oracle_module_target": is_module_target,
            "grove_count": gcount, "grove_cross": gcross,
            "grove_files": [d["file"].split("/repos/")[-1] for d in gdefs],
            "grove_line": gline,
            "file_hit": file_hit, "line_hit": line_hit,
            "oracle_in_fallback": oracle_in_fallback,
        })
        if (i + 1) % 20 == 0:
            print(f"  {i+1}/{len(sites)}  ({time.time()-t0:.0f}s)", file=sys.stderr)
    oracle.shutdown()

    summarize(rows, args.out)


def summarize(rows, out_path):
    n = len(rows)
    oracle_xfile = [r for r in rows if r["oracle_in_repo"] and not r["oracle_same_file"]]
    sym = [r for r in oracle_xfile if not r["oracle_module_target"]]   # grove's target population
    mod = [r for r in oracle_xfile if r["oracle_module_target"]]        # out of scope by design

    def rate(rs, key):
        return (sum(1 for r in rs if r[key]) / len(rs)) if rs else 0.0

    grove_fired = [r for r in rows if r["grove_cross"]]  # grove returned a single cross-file def
    precision = (sum(1 for r in grove_fired if r["file_hit"]) / len(grove_fired)) if grove_fired else 0.0

    # On the symbol-import population grove missed, how often did the OLD behavior
    # (dir-wide fallback) at least surface the right file — but ambiguously, in a
    # multi-candidate list? This is the precision Step 2 converts to a single
    # answer when it fires.
    sym_miss = [r for r in sym if not r["file_hit"]]
    fallbacks = [r for r in sym if r["grove_count"] != 1]
    avg_fallback_cands = (sum(r["grove_count"] for r in fallbacks) / len(fallbacks)) if fallbacks else 0.0

    summary = {
        "sites": n,
        "oracle_cross_file": len(oracle_xfile),
        "symbol_imports": len(sym),
        "module_imports": len(mod),
        "grove_cross_file_recall_on_symbol_imports": rate(sym, "file_hit"),
        "grove_line_exact_on_symbol_imports": rate(sym, "line_hit"),
        "grove_recall_all_cross_file": rate(oracle_xfile, "file_hit"),
        "grove_cross_file_fired": len(grove_fired),
        "grove_cross_file_precision": precision,
        "grove_hit_on_module_imports": rate(mod, "file_hit"),
        "symbol_import_misses": len(sym_miss),
        "miss_right_file_in_ambiguous_fallback": rate(sym_miss, "oracle_in_fallback"),
        "avg_dirwide_candidates_when_not_resolved": avg_fallback_cands,
    }
    print("\n=== cross-file go-to-def hit-rate (grove import-edge vs pyright) ===")
    for k, v in summary.items():
        print(f"  {k:46s} {v:.3f}" if isinstance(v, float) else f"  {k:46s} {v}")

    if out_path:
        with open(out_path, "w") as fh:
            json.dump({"summary": summary, "rows": rows}, fh, indent=2)
        print(f"\nwrote {out_path}")


if __name__ == "__main__":
    main()
