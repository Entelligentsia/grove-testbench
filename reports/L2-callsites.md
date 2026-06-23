# L2 report — "definition + all call sites" across 10 repos

**Rung:** L2 (def + every reference/call site) · **Date:** 2026-06-23 ·
**Agent:** Claude, `--model sonnet` · **grove:** fixed, post-[#31](https://github.com/Entelligentsia/grove/issues/31) (`dg:r2`) ·
**Sides:** `db` = grove OFF, `dg` = grove ON (grove the only variable).

Evidence: [`evidence/L2.eval.json`](../evidence/L2.eval.json) (metrics),
[`evidence/L2.quality.json`](../evidence/L2.quality.json) (blind quality).
Raw transcripts: `out/opt-<repo>-L2_callsites.claude.{db,dg}.jsonl`.

---

## Headline

On "where is `X` defined and list every call site," with the off-by-one bug fixed:

| axis (lower/ better) | winner | tally |
|---|---|---|
| **context tokens** | baseline | **db 9/10** (dg only spring-boot) |
| **wall-clock time** | baseline | **db 8/10** |
| **tool calls** | **grove** | **dg 6/10** |
| **answer quality** (blind) | tie | **5–5** |

Grove buys **fewer tool calls and higher precision** at the cost of **more
tokens, more time, and uneven recall**. Its one context "win" (spring-boot) is an
artifact of doing *less* (see below), so the honest read is: **grove does not yet
pay for itself on the call-sites task.**

---

## Method

- **Prompt** (identical both sides): *"Where is `<symbol>` defined, and list every
  place it is referenced or called across the source tree, with file and line."*
- **Symbols** (one iconic per repo): redis `dictAdd`, tokio `Runtime`, hugo `Site`,
  django `QuerySet`, typescript `Scanner`, webpack `Compiler`, bitcoin
  `CMutableTransaction`, spring-boot `SpringApplication`, rails
  `ActiveRecord::Relation`, laravel Eloquent `Model`.
- **Fair baseline:** both sides get the same realistic `claude-md/<repo>.base.md`;
  `dg` additionally carries its `grove init` block. Grove is the only variable.
- **Context** = `input + cache_read + cache_creation` (what the model ingests).
- **Quality** = blind judge per repo, A/B unlabeled, **every cited location verified
  against the pinned `dg:r2` source** with `grep -n` / `sed -n`.
- **Run:** `MAXP=4 scripts/run-rung-parallel.sh L2_callsites sonnet <10 repos>`
  (throttled — 20 concurrent containers OOM a 16 GB box).

---

## Metrics (per repo)

| Repo | db ctx | dg ctx | ctx Δ | ctx win | db→dg time | time win | db→dg tools | tool win |
|---|---|---|---|---|---|---|---|---|
| redis | 53,198 | 81,566 | +53% | db | 19→41s | db | 1→3 | db |
| tokio | 51,188 | 127,490 | +149% | db | 126→79s | dg | 23→4 | dg |
| hugo | 76,293 | 142,497 | +87% | db | 110→110s | tie | 23→8 | dg |
| django | 84,808 | 120,692 | +42% | db | 86→218s | db | 14→15 | db |
| typescript | 50,272 | 138,879 | +176% | db | 115→144s | db | 34→6 | dg |
| webpack | 152,493 | 162,282 | +6% | db | 118→52s | dg | 23→5 | dg |
| bitcoin | 52,505 | 183,458 | +249% | db | 138→201s | db | 9→6 | dg |
| **spring-boot** | 127,046 | 110,651 | **−13%** | **dg** | 107→125s | db | 25→12 | dg |
| rails | 79,234 | 120,717 | +52% | db | 50→176s | db | 3→10 | db |
| laravel | 55,646 | 180,810 | +225% | db | 136→226s | db | 16→39 | db |

**Context:** db wins 9/10; grove is 1.5–3.5× heavier on most. The call-sites task
is grep-cheap for the baseline, so grove's `callers` + steering overhead still
costs more — the #31 fix was a *correctness* fix and does not change token volume.

**Tool calls (grove's edge):** dg wins 6/10, sometimes dramatically (typescript
34→6, tokio 23→4) — structural `callers`/`definition` replaces many greps. But it
can also blow up (laravel 16→**39**, a GI-3 over-read).

---

## Quality (blind judges, claims verified vs source)

Blind A=db / B=dg. **5–5**, but the *kind* of win differs.

| Repo | quality winner | why |
|---|---|---|
| redis | **dg** | strict superset; found vendored `deps/hiredis` call site + enclosing fn names; both 6/6 precision |
| tokio | **dg** | db **fabricated** aggregate counts ("50+", real 18); dg gave verified file:line, better recall |
| hugo | db | both 6/6 precision; db covered all 4 `Site` def variants + accurate ~497 count; dg undercounted ~3× |
| django | db | dg **fabricated** `query.py:304` (PreventQuerySetCloning ≠ QuerySet); undercovered source, buried in tests |
| typescript | db | dg pointed at generated `*.d.ts`; missed checker/parser/nodeFactory call sites (GI-5) |
| webpack | db | dg substituted `types.d.ts` for real `lib/`; silently dropped ~199 typedef refs (GI-5) |
| bitcoin | **dg** | higher recall (132 vs ~115 files), caught `interfaces/wallet.h` etc.; fewer wrong lines |
| spring-boot | db | dg precision-perfect but covered **<25%** of refs (GI-6); db broad categorical coverage |
| rails | **dg** | found bare-`Relation` refs db missed (subclasses, factory calls, constants) |
| laravel | **dg** | zero fabrications + unique real refs (Facade alias, DB-provider injection); db had a fabricated column |

**Pattern:**
- **Grove wins on precision + non-obvious references** — vendored copies,
  subclasses, factory calls, enclosing functions; and it fabricates less.
- **Grove loses on recall / wrong target** — two concrete, fixable defects below.

---

## Grove issues surfaced (→ [GROVE-ISSUES.md](../GROVE-ISSUES.md))

- **GI-3 — over-read / non-convergence:** laravel dg ran 39 tool calls / 226 s vs
  db 16 / 136 s. Present since L1; worst on broad asks.
- **GI-5 — references resolve to generated declaration files:** typescript refs
  landed in `tests/baselines/**/*.d.ts`, webpack in `types.d.ts`, instead of real
  source → the agent answers from the wrong file and drops real call sites.
- **GI-6 — `callers` under-covers common symbols:** spring-boot dg covered <25% of
  real references (only grove-tagged cross-refs); hugo/django undercounted ~3×.
  Precision-first, low recall on "every reference" asks.

### The spring-boot caveat (read before citing the context win)

spring-boot is grove's **only** L2 context win (−13%) — and the quality judge found
dg covered **<25%** of the real call sites. It was cheaper because it **did less**,
not because it was more efficient. **A context win is meaningless without a
coverage check** — this is why every rung pairs cost metrics with verified quality.

---

## Net verdict

For "list all call sites," grove (as of `dg:r2`):
- **costs more** (context 9/10, time 8/10 to the baseline),
- **issues fewer tool calls** (6/10) — its one robust advantage,
- **ties on answer quality** (5/5), trading higher precision for lower/uneven recall.

Fixing **GI-5** (stop indexing generated `.d.ts`) and **GI-6** (recall on `callers`)
is the most direct path to converting grove's precision edge into a real win:
4 of grove's 5 quality losses were recall/target failures, not precision failures.

---

## Caveats

- **n=1 per cell.** Variance is large (e.g. rails db 50 s vs dg 176 s; laravel dg
  blow-up). Treat single-cell results as directional; reproduce before citing.
- redis's first batch cell hit a transient 401 (expired baked creds) and was
  re-run single; see [FINDINGS.md](../FINDINGS.md) ops notes (auth + concurrency).

## Reproduce

```bash
# fixed grove into dg, then race + judge
GROVE_BIN=../grove/target/release/grove scripts/build-dg.sh
MAXP=4 scripts/run-rung-parallel.sh L2_callsites sonnet \
  redis tokio hugo django typescript webpack bitcoin spring-boot rails laravel
# metrics are in out/opt-<repo>-L2_callsites.claude.metrics.json
```
