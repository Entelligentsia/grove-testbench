# Cross-file go-to-def hit-rate — grove import-edge (ADR 0001 Step 2)

Measures how often grove's **import-edge resolution** (`grove definition --at`)
lands on the same definition a real language server resolves to, on a pinned
real-world repo. This is the go/no-go evidence the ADR asks for before any
heavier (stack-graphs) cross-file investment.

## Method

- **Repo:** `django` (pinned SHA in `repos.manifest`), the bench's Python repo.
- **Sites:** the first use of each name brought in by `from MODULE import NAME
  [as A]` — the population grove's import-edge resolution targets. 180 sites
  sampled deterministically (strided) across 850 files under `django/`.
- **Oracle (ground truth):** `pyright` (`textDocument/definition` at the exact
  position) — semantic resolution through the real import/type model.
- **grove:** `grove definition --at file:line:col -d <repo>` at the same
  position, with `GROVE_REGISTRY` pinned to the dev-stub registry (the one
  carrying `imports.scm` + `import_resolution`).
- **HIT:** grove returns a *single* definition in the same file the oracle
  resolved to (line-exact tracked separately).

Reproduce: `python3 measure.py --grove <bin> --registry <dir> --root
experiment/repos/django --max-sites 180 django` (see `measure.py`,
`lspclient.py`). Raw rows: `out/xfile-django.json`.

## Headline numbers (django, n=180)

| Metric | Value |
|---|---|
| Oracle cross-file sites | 148 / 180 |
| — symbol imports (grove's target) | 136 |
| — module/package imports (out of scope by design) | 12 |
| **grove recall on symbol imports (file)** | **92.6 %** (126/136) |
| grove recall on symbol imports (line-exact) | 92.6 % |
| grove recall over *all* cross-file sites | 85.1 % |
| grove hit on module imports | 0 % (expected) |
| Symbol-import misses | 10 |
| — right file present in grove's fallback list | **10 / 10 (100 %)** |
| avg dir-wide candidates when not resolved | 3.0 |

When grove resolves a symbol import, it is **line-exact** (file recall ==
line recall). grove is **never confidently wrong on an in-repo symbol import**:
every miss degrades to an ambiguous-but-correct fallback list (≤3 candidates that
*contain* the right file), never a single wrong answer.

## What the residual gap is

- **All 10 symbol-import misses are the re-export tail.** e.g. `from
  django.db.models import Q` — `Q` is defined in `query_utils.py` and
  re-exported through `models/__init__.py`. grove looks in `models/__init__.py`,
  sees `Q` is itself imported there (not defined), and falls back. Following
  **one more hop** (resolving a re-export in the target `__init__.py`) would
  convert most of these to hits — the clearest next increment.
- **The 3 apparent precision misses are not wrong in-repo resolutions:** one is a
  module import (`from django.utils import timezone` → `timezone.py`), two are
  stdlib imports (`urllib.parse`, `datetime`) the oracle resolves to typeshed
  *outside* the repo, where grove's dir-wide fallback coincidentally returned one
  same-named local def. Suppressing a fallback "single" on module/external
  imports would remove these.
- **Module/package imports (12)** — `from pkg import submodule` — are out of
  scope: grove looks for a *defined symbol*, not a submodule. 0 % by design.

## JavaScript: not yet measurable on the pinned repo

The bench's JS repo (`webpack`) is **100 % CommonJS `require()`** (0 ES `import`
statements across `lib/`). grove's `imports.scm` for JS matches **ES imports
only**, so import-edge does not fire on webpack; a `require()` use falls back to
the dir-wide list (verified: `new Cache()` in `lib/Compiler.js` returns 2
ambiguous candidates incl. the correct `lib/Cache.js`). **CommonJS `require()`
support is the top JS backlog item**; until then JS cross-file hit-rate on this
bench is effectively 0 and not meaningfully comparable to Python.

## Verdict

For Python, import-edge resolution **answers ~93 % of the cross-file symbol-import
go-to-def questions an agent would ask, line-exact, with no index and no wrong
single answers** — a strong return for a stateless, parse-on-demand feature. The
entire residual is the documented re-export tail, of which a large share is
reachable with a single extra hop. This does **not** yet justify a stack-graphs
tier; the cheaper wins (one-hop re-export, CommonJS `require()`) should be spent
first, then re-measured.

## Backlog (feeds grove GROVE-ISSUES.md)

1. **Re-export one-hop** — when the target module is a package `__init__.py` and
   the symbol is imported (not defined) there, follow that import one more hop.
   Would recover most of the 10 django misses.
2. **CommonJS `require()`** — add `const X = require("./y")` / `const { X } =
   require("./y")` patterns to JS `imports.scm`. Unlocks JS measurement.
3. **Suppress false-fire on module/external imports** — don't return a dir-wide
   "single" as if it were a resolution when import-edge found no target file.
4. **Rust `use_path`** — still unimplemented (falls back to dir-wide).
